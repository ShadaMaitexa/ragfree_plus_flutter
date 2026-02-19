import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Get activities for admin (all activities)
  Stream<List<ActivityModel>> getAllActivities({int limit = 10}) {
    return _firestore
        .collection('activities')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ActivityModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }
}
