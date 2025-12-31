import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SOSService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(initSettings);
  }

  // Send SOS alert
  Future<void> sendSOSAlert({
    required String studentId,
    required String studentName,
    String? message,
  }) async {
    try {
      // Get current location
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      } catch (e) {
        // Location permission denied or unavailable
      }

      // Create SOS alert
      final alert = {
        'id': '',
        'studentId': studentId,
        'studentName': studentName,
        'message': message ?? 'Emergency SOS Alert',
        'location': position != null
            ? {
                'latitude': position.latitude,
                'longitude': position.longitude,
              }
            : null,
        'timestamp': Timestamp.now(),
        'status': 'Active',
        'respondedBy': null,
      };

      final docRef = await _firestore.collection('sos_alerts').add(alert);

      // Notify authorities
      await _notifyAuthorities(docRef.id, studentName, position);

      // Send notification to linked parents
      await _notifyParents(studentId, studentName);
    } catch (e) {
      throw Exception('Failed to send SOS alert: ${e.toString()}');
    }
  }

  // Notify authorities (admin, warden, police)
  Future<void> _notifyAuthorities(
      String alertId, String studentName, Position? position) async {
    try {
      // Get all admin, warden, and police users
      final authorities = await _firestore
          .collection('users')
          .where('role', whereIn: ['admin', 'warden', 'police'])
          .get();

      // Create notifications for each authority
      final batch = _firestore.batch();
      for (var doc in authorities.docs) {
        final notificationRef = _firestore
            .collection('users')
            .doc(doc.id)
            .collection('notifications')
            .doc();
        batch.set(notificationRef, {
          'type': 'sos_alert',
          'alertId': alertId,
          'title': 'SOS Alert from $studentName',
          'message': position != null
              ? 'Emergency alert at ${position.latitude}, ${position.longitude}'
              : 'Emergency SOS alert received',
          'timestamp': Timestamp.now(),
          'isRead': false,
        });
      }
      await batch.commit();

      // Show local notification
      await _notifications.show(
        0,
        'SOS Alert',
        'Emergency alert from $studentName',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sos_channel',
            'SOS Alerts',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (e) {
      // Handle error silently
    }
  }

  // Notify linked parents
  Future<void> _notifyParents(String studentId, String studentName) async {
    try {
      final links = await _firestore
          .collection('parent_student_links')
          .where('studentId', isEqualTo: studentId)
          .where('isActive', isEqualTo: true)
          .get();

      final batch = _firestore.batch();
      for (var link in links.docs) {
        final parentId = link.data()['parentId'];
        final notificationRef = _firestore
            .collection('users')
            .doc(parentId)
            .collection('notifications')
            .doc();
        batch.set(notificationRef, {
          'type': 'sos_alert',
          'title': 'SOS Alert from $studentName',
          'message': 'Your child has sent an emergency SOS alert',
          'timestamp': Timestamp.now(),
          'isRead': false,
        });
      }
      await batch.commit();
    } catch (e) {
      // Handle error silently
    }
  }

  // Get active SOS alerts
  Stream<List<Map<String, dynamic>>> getActiveSOSAlerts() {
    return _firestore
        .collection('sos_alerts')
        .where('status', isEqualTo: 'Active')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList());
  }

  // Respond to SOS alert
  Future<void> respondToSOS(String alertId, String responderId) async {
    try {
      await _firestore.collection('sos_alerts').doc(alertId).update({
        'status': 'Responded',
        'respondedBy': responderId,
        'respondedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to respond to SOS: ${e.toString()}');
    }
  }
}
