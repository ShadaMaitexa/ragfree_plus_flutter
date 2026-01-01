import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/activity_model.dart';
import '../models/complaint_model.dart';
import '../models/chat_message_model.dart';

class ActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get recent activities for a user
  Stream<List<ActivityModel>> getUserActivities(String userId, {int limit = 5}) {
    return _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
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

      await _firestore.collection('activities').add({
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
      await _firestore.collection('activities').add({
        'userId': userId,
        'type': 'chat',
        'title': 'New message from $senderName',
        'description': message.message,
        'timestamp': Timestamp.now(),
        'relatedId': message.chatId,
        'metadata': {
          'chatId': message.chatId,
          'senderId': message.senderId,
        },
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
      await _firestore.collection('activities').add({
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
      await _firestore.collection('activities').add({
        'userId': userId,
        'type': 'system', // or 'emergency' if we add it
        'title': '🚨 EMERGENCY SOS TRIGGERED',
        'description': '$studentName has triggered an SOS alert: ${message ?? 'No message provided'}',
        'timestamp': Timestamp.now(),
        'metadata': {
          'isEmergency': true,
          'priority': 'critical',
        },
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
        .map((snapshot) => snapshot.docs
            .map((doc) => ActivityModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }
}
