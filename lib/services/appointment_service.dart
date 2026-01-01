import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_slot_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new slot
  Future<void> createSlot(AppointmentSlotModel slot) async {
    try {
      await _firestore.collection('appointment_slots').add(slot.toMap());
    } catch (e) {
      throw Exception('Failed to create slot: ${e.toString()}');
    }
  }

  // Get slots for a specific counselor
  Stream<List<AppointmentSlotModel>> getCounselorSlots(String counselorId) {
    return _firestore
        .collection('appointment_slots')
        .where('counselorId', isEqualTo: counselorId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentSlotModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get all available slots for a counselor (for students)
  Stream<List<AppointmentSlotModel>> getAvailableSlots(String counselorId) {
    // Note: Use a composite index on [counselorId, status, date] if needed
    // For now simple filtering
    return _firestore
        .collection('appointment_slots')
        .where('counselorId', isEqualTo: counselorId)
        .where('status', isEqualTo: 'available')
        .where('date', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentSlotModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Book a slot
  Future<void> bookSlot(String slotId, String studentId, String studentName) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final docRef = _firestore.collection('appointment_slots').doc(slotId);
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Slot does not exist');
        }

        final status = snapshot.data()?['status'];
        if (status != 'available') {
          throw Exception('Slot is no longer available');
        }

        transaction.update(docRef, {
          'status': 'booked',
          'studentId': studentId,
          'studentName': studentName,
        });
      });
    } catch (e) {
      throw Exception('Failed to book slot: ${e.toString()}');
    }
  }

  // Cancel a slot (by counselor or system)
  Future<void> deleteSlot(String slotId) async {
    try {
      await _firestore.collection('appointment_slots').doc(slotId).delete();
    } catch (e) {
      throw Exception('Failed to delete slot: ${e.toString()}');
    }
  }
}
