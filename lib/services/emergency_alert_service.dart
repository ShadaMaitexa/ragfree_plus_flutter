import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyAlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all active emergency alerts
  Stream<List<Map<String, dynamic>>> getActiveEmergencyAlerts() {
    return _firestore
        .collection('emergency_alerts')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  // Get recent emergency alerts (including inactive ones)
  Stream<List<Map<String, dynamic>>> getRecentEmergencyAlerts({int limit = 5}) {
    return _firestore
        .collection('emergency_alerts')
        .orderBy('createdAt', descending: true)
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
  Future<String> getCurrentEmergencyStatus() async {
    try {
      final activeAlerts = await _firestore
          .collection('emergency_alerts')
          .where('isActive', isEqualTo: true)
          .where('priority', isEqualTo: 'critical')
          .limit(1)
          .get();

      if (activeAlerts.docs.isNotEmpty) {
        return 'Active Emergency';
      }

      final recentAlerts = await _firestore
          .collection('emergency_alerts')
          .orderBy('createdAt', descending: true)
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

  // Create emergency alert (for admin/police)
  Future<void> createEmergencyAlert({
    required String title,
    required String message,
    required String priority, // 'low', 'medium', 'high', 'critical'
    required String createdBy,
    String? location,
  }) async {
    try {
      // Create alert
      await _firestore.collection('emergency_alerts').add({
        'title': title,
        'message': message,
        'priority': priority,
        'createdBy': createdBy,
        'location': location,
        'isActive': true,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      // Notify all users (students, parents, staff)
      await _notifyAllUsers(title, message, priority);
    } catch (e) {
      throw Exception('Failed to create emergency alert: ${e.toString()}');
    }
  }

  // Notify all users about emergency alert
  Future<void> _notifyAllUsers(
    String title,
    String message,
    String priority,
  ) async {
    try {
      // Get all users
      final users = await _firestore.collection('users').get();

      final batch = _firestore.batch();
      final timestamp = Timestamp.now();

      for (var userDoc in users.docs) {
        final notificationRef = _firestore.collection('notifications').doc();
        batch.set(notificationRef, {
          'userId': userDoc.id,
          'title': title,
          'message': message,
          'type': priority == 'critical' ? 'error' : 'warning',
          'createdAt': timestamp,
          'isRead': false,
          'relatedType': 'emergency_alert',
        });
      }

      await batch.commit();
    } catch (e) {
      // Handle error silently - notification creation shouldn't fail the alert
    }
  }

  // Deactivate emergency alert
  Future<void> deactivateAlert(String alertId) async {
    try {
      await _firestore.collection('emergency_alerts').doc(alertId).update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to deactivate alert: ${e.toString()}');
    }
  }
}

