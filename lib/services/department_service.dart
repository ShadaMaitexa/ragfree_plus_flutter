import 'package:cloud_firestore/cloud_firestore.dart';

class DepartmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getDepartments() {
    return _firestore.collection('departments').snapshots().asyncMap((
      snapshot,
    ) async {
      final departments = snapshot.docs.map((doc) {
        return {...doc.data(), 'id': doc.id};
      }).toList();

      // Fetch all users to count students and staff per department
      // We fetch all because we need to count for multiple departments
      final usersSnapshot = await _firestore.collection('users').get();

      final studentCounts = <String, int>{};
      final staffCounts = <String, int>{};

      for (var doc in usersSnapshot.docs) {
        final data = doc.data();
        final role = data['role'] as String?;
        final dept = data['department'] as String?;
        final isApproved = data['isApproved'] == true;

        if (dept != null && dept.trim().isNotEmpty && isApproved) {
          final normalizedDept = dept.trim().toLowerCase();

          if (role == 'student') {
            studentCounts[normalizedDept] =
                (studentCounts[normalizedDept] ?? 0) + 1;
          } else if (role != 'parent' && role != 'admin' && role != null) {
            // Count as staff if not student, parent, or admin
            staffCounts[normalizedDept] =
                (staffCounts[normalizedDept] ?? 0) + 1;
          }
        }
      }

      // Update departments with real counts
      for (var dept in departments) {
        final name = dept['name'] as String;
        final normalizedName = name.trim().toLowerCase();

        // Find matching count by normalized name if possible, or try direct match
        // The dictionary keys are normalized
        dept['students'] = studentCounts[normalizedName] ?? 0;
        dept['staff'] = staffCounts[normalizedName] ?? 0;
      }

      return departments;
    });
  }

  Stream<List<String>> getDepartmentNames() {
    return _firestore.collection('departments').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()['name'] as String).toList()
        ..sort();
    });
  }

  Future<void> addDepartment(Map<String, dynamic> department) async {
    try {
      final docRef = _firestore.collection('departments').doc();
      await docRef.set({...department, 'id': docRef.id});
    } catch (e) {
      throw Exception('Failed to add department: $e');
    }
  }

  Future<void> updateDepartment(
    String id,
    Map<String, dynamic> department,
  ) async {
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
