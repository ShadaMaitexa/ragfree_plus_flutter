import 'package:cloud_firestore/cloud_firestore.dart';
import 'activity_service.dart';

class EmergencyAlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ActivityService _activityService = ActivityService();

  // Get all active global alerts
  Stream<List<Map<String, dynamic>>> getActiveGlobalAlerts() {
    return _firestore
        .collection('global_alerts')
        .where('isActive', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  // Get recent global alerts (including inactive ones)
  Stream<List<Map<String, dynamic>>> getRecentGlobalAlerts({int limit = 5}) {
    return _firestore
        .collection('global_alerts')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  // Get current emergency status
  Future<String> getCurrentAlertStatus() async {
    try {
      final activeAlerts = await _firestore
          .collection('global_alerts')
          .where('isActive', isEqualTo: true)
          .where('priority', isEqualTo: 'critical')
          .limit(1)
          .get();

      if (activeAlerts.docs.isNotEmpty) {
        return 'Active Emergency';
      }

      final recentAlerts = await _firestore
          .collection('global_alerts')
          .limit(1)
          .get();

      if (recentAlerts.docs.isNotEmpty) {
        final alert = recentAlerts.docs.first.data();
        final createdAt = alert['createdAt'] as Timestamp?;
        if (createdAt != null) {
          final hoursSinceAlert = DateTime.now().difference(createdAt.toDate()).inHours;
          if (hoursSinceAlert < 24) {
            return 'Recent Alert';
          }
        }
      }

      return 'All Clear';
    } catch (e) {
      return 'All Clear';
    }
  }

  // Create global alert/notification (for admin/police)
  Future<void> createGlobalAlert({
    required String title,
    required String message,
    required String priority, // 'low', 'medium', 'high', 'critical'
    required String createdBy,
    String? location,
    List<String> targetRoles = const ['all'],
  }) async {
    try {
      // Create alert
      await _firestore.collection('global_alerts').add({
        'title': title,
        'message': message,
        'priority': priority,
        'createdBy': createdBy,
        'location': location,
        'targetRoles': targetRoles,
        'isActive': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Notify target users
      await _notifyTargetUsers(title, message, priority, targetRoles);
    } catch (e) {
      throw Exception('Failed to create global alert: ${e.toString()}');
    }
  }

  // Notify target users about global alert
  Future<void> _notifyTargetUsers(
    String title,
    String message,
    String priority,
    List<String> targetRoles,
  ) async {
    try {
      QuerySnapshot users;
      
      if (targetRoles.contains('all') || targetRoles.isEmpty) {
        // Get all users
        users = await _firestore.collection('users').get();
      } else {
        // Get users with specific roles
        users = await _firestore
            .collection('users')
            .where('role', whereIn: targetRoles)
            .get();
      }

      final batch = _firestore.batch();
      final timestamp = Timestamp.now();

      for (var userDoc in users.docs) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'id': notificationRef.id,
          'userId': userDoc.id,
          'title': title,
          'message': message,
          'type': priority == 'critical' ? 'error' : 'info',
          'createdAt': timestamp,
          'isRead': false,
          'relatedType': 'global_alert',
        });
      }

      await batch.commit();
    } catch (e) {
      // Handle error silently - notification creation shouldn't fail the alert
    }
  }

  // Deactivate global alert
  Future<void> deactivateAlert(String alertId) async {
    try {
      await _firestore.collection('global_alerts').doc(alertId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to deactivate alert: ${e.toString()}');
    }
  }

  // Send SOS alert (student specific)
  Future<void> sendSOSAlert({
    required String studentId,
    required String studentName,
    String? message,
    String? location,
  }) async {
    try {
      final alertTitle = 'SOS: Emergency Help Required';
      final alertMessage = message ?? '$studentName has triggered an emergency SOS alert. Please respond immediately.';
      
      await createGlobalAlert(
        title: alertTitle,
        message: alertMessage,
        priority: 'critical',
        createdBy: studentId,
        location: location,
      );

      // Log activity
      await _activityService.createSOSActivity(
        userId: studentId,
        studentName: studentName,
        message: message,
      );
    } catch (e) {
      throw Exception('Failed to send SOS: ${e.toString()}');
    }
  }
}
