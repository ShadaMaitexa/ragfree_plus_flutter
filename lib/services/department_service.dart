import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getDepartments() {
    return _firestore.collection('departments').snapshots().asyncMap((snapshot) async {
      final departments = snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();

      // Fetch student counts
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      final studentCounts = <String, int>{};
      for (var doc in studentsSnapshot.docs) {
        final dept = doc.data()['department'] as String?;
        if (dept != null && dept.isNotEmpty) {
          final normalized = dept.trim();
          // Case-insensitive counting matching
          final key = studentCounts.keys.firstWhere(
            (k) => k.toLowerCase() == normalized.toLowerCase(),
            orElse: () => normalized,
          );
          studentCounts[key] = (studentCounts[key] ?? 0) + 1;
        }
      }

      // Update departments with real counts
      for (var dept in departments) {
        final name = dept['name'] as String;
        // Find matching count
        final countKey = studentCounts.keys.firstWhere(
          (k) => k.toLowerCase() == name.toLowerCase(),
          orElse: () => '',
        );
        dept['students'] = countKey.isNotEmpty ? studentCounts[countKey] : 0;
      }

      return departments;
    });
  }

  Stream<List<String>> getDepartmentNames() {
    return _firestore.collection('departments').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList()
          ..sort();
    });
  }

  Future<void> addDepartment(Map<String, dynamic> department) async {
    try {
      final docRef = _firestore.collection('departments').doc();
      await docRef.set({
        ...department,
        'id': docRef.id,
      });
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
