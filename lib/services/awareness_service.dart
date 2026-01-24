import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/awareness_model.dart';

class AwarenessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get awareness content for a specific role.
  /// If role is 'all', returns content for all roles.
  Stream<List<AwarenessModel>> getAwarenessForRole(String role) {
    Query collection = _firestore.collection('awareness');

    if (role != 'all') {
      List<String> targetRoles = [role, 'all'];
      if (['student', 'parent', 'teacher', 'admin'].contains(role)) {
        targetRoles.add('public');
      }
      if (role == 'public') {
        targetRoles = ['public', 'all'];
      }
      collection = collection.where('role', whereIn: targetRoles);
    }

    return collection.snapshots().map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AwarenessModel.fromMap(
                  {
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  },
                ),
              )
              .toList(),
        );
  }

  Stream<List<AwarenessModel>> getAwarenessByAuthor(String authorId) {
    return _firestore
        .collection('awareness')
        .where('authorId', isEqualTo: authorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AwarenessModel.fromMap(
                  {
                    ...doc.data() as Map<String, dynamic>,
                    'id': doc.id,
                  },
                ),
              )
              .toList(),
        );
  }

  Future<void> addAwareness(AwarenessModel model) async {
    final docRef = _firestore.collection('awareness').doc();
    final updatedModel = model.copyWith(id: docRef.id);
    await docRef.set(updatedModel.toMap());
  }

  Future<void> updateAwareness(AwarenessModel model) async {
    if (model.id.isEmpty) return;
    await _firestore.collection('awareness').doc(model.id).update(model.toMap());
  }

  Future<void> deleteAwareness(String id) async {
    await _firestore.collection('awareness').doc(id).delete();
  }
}
