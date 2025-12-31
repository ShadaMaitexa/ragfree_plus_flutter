import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/awareness_model.dart';

class AwarenessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get awareness content for a specific role.
  /// If role is 'all', returns content for all roles.
  Stream<List<AwarenessModel>> getAwarenessForRole(String role) {
    Query collection = _firestore.collection('awareness');

    if (role != 'all') {
      collection = collection.where('role', whereIn: [role, 'all']);
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

  Future<void> addAwareness(AwarenessModel model) async {
    await _firestore.collection('awareness').add(model.toMap());
  }

  Future<void> updateAwareness(AwarenessModel model) async {
    if (model.id.isEmpty) return;
    await _firestore.collection('awareness').doc(model.id).update(model.toMap());
  }

  Future<void> deleteAwareness(String id) async {
    await _firestore.collection('awareness').doc(id).delete();
  }
}
