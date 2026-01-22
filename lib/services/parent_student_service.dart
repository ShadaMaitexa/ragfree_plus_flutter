import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/parent_student_link_model.dart';

class ParentStudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Link parent with student using student email
  Future<ParentStudentLinkModel> linkStudent({
    required String parentId,
    required String parentName,
    required String studentEmail,
    required String relationship,
  }) async {
    try {
      // Find student by email
      final studentQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: studentEmail)
          .where('role', isEqualTo: 'student')
          .limit(1)
          .get();

      if (studentQuery.docs.isEmpty) {
        throw Exception('Student not found with email: $studentEmail');
      }

      final studentData = studentQuery.docs.first.data();
      final studentId = studentQuery.docs.first.id;
      final studentName = studentData['name'] ?? '';

      // Check if link already exists
      final existingLink = await _firestore
          .collection('parent_student_links')
          .where('parentId', isEqualTo: parentId)
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();

      if (existingLink.docs.isNotEmpty) {
        throw Exception('Student is already linked to this parent');
      }

      // Create link
      final link = ParentStudentLinkModel(
        id: '',
        parentId: parentId,
        parentName: parentName,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        relationship: relationship,
        linkedAt: DateTime.now(),
      );

      // Create link document reference to get ID
      final docRef = _firestore.collection('parent_student_links').doc();
      final updatedLink = link.copyWith(id: docRef.id);

      await docRef.set(updatedLink.toMap());

      return updatedLink;
    } catch (e) {
      throw Exception('Failed to link student: ${e.toString()}');
    }
  }

  // Get linked students for a parent
  Stream<List<ParentStudentLinkModel>> getLinkedStudents(String parentId) {
    return _firestore
        .collection('parent_student_links')
        .where('parentId', isEqualTo: parentId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParentStudentLinkModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get parent links for a student
  Stream<List<ParentStudentLinkModel>> getStudentParents(String studentId) {
    return _firestore
        .collection('parent_student_links')
        .where('studentId', isEqualTo: studentId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ParentStudentLinkModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Unlink student
  Future<void> unlinkStudent(String linkId) async {
    try {
      await _firestore.collection('parent_student_links').doc(linkId).update({
        'isActive': false,
      });
    } catch (e) {
      throw Exception('Failed to unlink student: ${e.toString()}');
    }
  }
}

