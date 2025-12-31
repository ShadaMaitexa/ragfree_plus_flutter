import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'emailjs_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EmailJSService _emailJSService = EmailJSService();

  // Get notifications for a user
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    NotificationModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get unread notifications count
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  // Create a notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
    String? relatedId,
    String? relatedType,
    bool sendEmail = true,
  }) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'message': message,
        'type': type,
        'createdAt': Timestamp.now(),
        'isRead': false,
        'relatedId': relatedId,
        'relatedType': relatedType,
      });

      // Send email notification if enabled
      if (sendEmail) {
        try {
          final userEmail = await _emailJSService.getUserEmail(userId);
          if (userEmail != null) {
            final userDoc = await _firestore
                .collection('users')
                .doc(userId)
                .get();
            final userName = userDoc.data()?['name'] as String? ?? 'User';

            await _emailJSService.sendNotificationEmail(
              userEmail: userEmail,
              userName: userName,
              notificationTitle: title,
              notificationMessage: message,
              notificationType: type,
            );
          }
        } catch (e) {
          // Email sending failed, but notification was created - continue silently
          print('Email notification failed: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to create notification: ${e.toString()}');
    }
  }

  // Create notification for multiple users (e.g., all parents)
  Future<void> createNotificationForUsers({
    required List<String> userIds,
    required String title,
    required String message,
    required String type,
    String? relatedId,
    String? relatedType,
  }) async {
    try {
      final batch = _firestore.batch();
      final timestamp = Timestamp.now();

      for (var userId in userIds) {
        final docRef = _firestore.collection('notifications').doc();
        batch.set(docRef, {
          'userId': userId,
          'title': title,
          'message': message,
          'type': type,
          'createdAt': timestamp,
          'isRead': false,
          'relatedId': relatedId,
          'relatedType': relatedType,
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create notifications: ${e.toString()}');
    }
  }
}
