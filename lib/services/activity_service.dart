import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/activity_model.dart';
import '../models/complaint_model.dart';
import '../models/chat_message_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get recent activities for a user
  Stream<List<ActivityModel>> getUserActivities(
    String userId, {
    int limit = 5,
  }) {
    if (userId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map(
                (doc) => ActivityModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList();
          // Sort in memory since we removed orderBy
          docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return docs.take(limit).toList();
        });
  }

  // Get activities for multiple users (e.g., Parent + Children)
  Stream<List<ActivityModel>> getMultiUserActivities(
    List<String> userIds, {
    int limit = 10,
  }) {
    if (userIds.isEmpty) return Stream.value([]);

    // Firestore whereIn supports max 10 IDs
    final limitedIds = userIds.length > 10 ? userIds.sublist(0, 10) : userIds;

    return _firestore
        .collection('activities')
        .where('userId', whereIn: limitedIds)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map(
                (doc) => ActivityModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList();
          // Sort in memory since we removed orderBy
          docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return docs.take(limit).toList();
        });
  }

  // Create activity from complaint
  Future<void> createActivityFromComplaint({
    required String userId,
    required ComplaintModel complaint,
    required String activityType, // 'created', 'updated', 'resolved'
  }) async {
    try {
      String title;
      String description;

      switch (activityType) {
        case 'created':
          title = complaint.isAnonymous
              ? 'New complaint filed'
              : '${complaint.studentName ?? "Student"} filed a new complaint';
          description = complaint.title;
          break;
        case 'updated':
          title = 'Complaint updated';
          description = '${complaint.title} - Status: ${complaint.status}';
          break;
        case 'resolved':
          title = 'Complaint resolved';
          description = '${complaint.title} has been resolved';
          break;
        default:
          title = 'Complaint activity';
          description = complaint.title;
      }

      final docRef = _firestore.collection('activities').doc();
      await docRef.set({
        'id': docRef.id,
        'userId': userId,
        'type': 'complaint',
        'title': title,
        'description': description,
        'timestamp': Timestamp.now(),
        'relatedId': complaint.id,
        'metadata': {
          'complaintId': complaint.id,
          'status': complaint.status,
          'priority': complaint.priority,
        },
      });
    } catch (e) {
      throw Exception('Failed to create activity: ${e.toString()}');
    }
  }

  // Create activity from chat message
  Future<void> createActivityFromChat({
    required String userId,
    required ChatMessageModel message,
    required String senderName,
  }) async {
    try {
      final docRef = _firestore.collection('activities').doc();
      await docRef.set({
        'id': docRef.id,
        'userId': userId,
        'type': 'chat',
        'title': 'New message from $senderName',
        'description': message.message,
        'timestamp': Timestamp.now(),
        'relatedId': message.chatId,
        'metadata': {'chatId': message.chatId, 'senderId': message.senderId},
      });
    } catch (e) {
      throw Exception('Failed to create activity: ${e.toString()}');
    }
  }

  // Create custom activity
  Future<void> createActivity({
    required String userId,
    required String title,
    required String description,
    required String type, // complaint, chat, system, user
    String? relatedId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final docRef = _firestore.collection('activities').doc();
      await docRef.set({
        'id': docRef.id,
        'userId': userId,
        'type': type,
        'title': title,
        'description': description,
        'timestamp': Timestamp.now(),
        if (relatedId != null) 'relatedId': relatedId,
        if (metadata != null) 'metadata': metadata,
      });
    } catch (e) {
      throw Exception('Failed to create activity: ${e.toString()}');
    }
  }

  // Create system activity
  Future<void> createSystemActivity({
    required String userId,
    required String title,
    required String description,
  }) async {
    try {
      final docRef = _firestore.collection('activities').doc();
      await docRef.set({
        'id': docRef.id,
        'userId': userId,
        'type': 'system',
        'title': title,
        'description': description,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to create activity: ${e.toString()}');
    }
  }

  // Get relevant activities for a counsellor (own + SOS + Role-based Notifications)
  Stream<List<ActivityModel>> getCounsellorActivities(
    String userId, {
    int limit = 10,
  }) {
    if (userId.isEmpty) return Stream.value([]);

    // Get own activities
    final ownStream = _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .snapshots();

    // Get SOS activities (system activities with SOS in title)
    final sosStream = _firestore
        .collection('activities')
        .where('type', isEqualTo: 'system')
        .snapshots();

    // Get Role-based Notifications
    final broadNotificationStream = _firestore
        .collection('notifications')
        .where('audience', whereIn: ['Counselors', 'Counsellors', 'All Users', 'counsellor', 'all'])
        .snapshots();

    // Get Personal Notifications
    final personalNotificationStream = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots();

    return Rx.combineLatest4<QuerySnapshot, QuerySnapshot, QuerySnapshot, QuerySnapshot,
        List<ActivityModel>>(
      ownStream,
      sosStream,
      broadNotificationStream,
      personalNotificationStream,
      (ownSnap, sosSnap, broadSnap, personalSnap) {
        final List<ActivityModel> activities = [];

        // Add activities
        for (var doc in [...ownSnap.docs, ...sosSnap.docs]) {
          activities.add(
            ActivityModel.fromMap({
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }),
          );
        }

        // Add notifications and map to ActivityModel
        for (var doc in [...broadSnap.docs, ...personalSnap.docs]) {
          final data = doc.data() as Map<String, dynamic>;
          activities.add(
            ActivityModel(
              id: doc.id,
              userId: data['userId'] ?? '',
              type: data['relatedType'] == 'global_alert' ? 'system' : 'notification',
              title: data['title'] ?? 'Notification',
              description: data['message'] ?? '',
              timestamp: (data['createdAt'] as Timestamp).toDate(),
              relatedId: data['relatedId'],
              metadata: {
                'source': 'notification',
                'isRead': data['isRead'] ?? false,
              },
            ),
          );
        }

        // Dedupe by id (crucial because a notification might be in both broad and personal if we're not careful)
        final seenIds = <String>{};
        final deduped = activities.where((a) => seenIds.add(a.id)).toList();

        // Sort
        deduped.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return deduped.take(limit).toList();
      },
    );
  }

  // Create SOS activity
  Future<void> createSOSActivity({
    required String userId,
    required String studentName,
    String? message,
  }) async {
    try {
      final docRef = _firestore.collection('activities').doc();
      await docRef.set({
        'id': docRef.id,
        'userId': userId,
        'type': 'system', // or 'emergency' if we add it
        'title': '🚨 EMERGENCY SOS TRIGGERED',
        'description':
            '$studentName has triggered an SOS alert: ${message ?? 'No message provided'}',
        'timestamp': Timestamp.now(),
        'metadata': {'isEmergency': true, 'priority': 'critical'},
      });
    } catch (e) {
      // Handle error silently
    }
  }

  // Get SOS activities for a user/counsellor
  Stream<List<ActivityModel>> getSOSActivities(
    String userId, {
    int limit = 10,
  }) {
    return _firestore
        .collection('activities')
        .where('type', isEqualTo: 'system')
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
              .map(
                (doc) => ActivityModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .where((activity) => activity.title.contains('SOS'))
              .toList();
          docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return docs.take(limit).toList();
        });
  }

  // Get activities for admin (all activities)
  Stream<List<ActivityModel>> getAllActivities({int limit = 10}) {
    return _firestore.collection('activities').snapshots().map((snapshot) {
      final docs = snapshot.docs
          .map((doc) => ActivityModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
      docs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return docs.take(limit).toList();
    });
  }
}
