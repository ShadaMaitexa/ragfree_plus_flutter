import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getDepartments() {
    return _firestore.collection('departments').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    });
  }

  Future<void> addDepartment(Map<String, dynamic> department) async {
    try {
      await _firestore.collection('departments').add(department);
    } catch (e) {
      throw Exception('Failed to add department: $e');
    }
  }

  Future<void> updateDepartment(String id, Map<String, dynamic> department) async {
    try {
      await _firestore.collection('departments').doc(id).update(department);
    } catch (e) {
      throw Exception('Failed to update department: $e');
    }
  }

  Future<void> deleteDepartment(String id) async {
    try {
      await _firestore.collection('departments').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete department: $e');
    }
  }
}
