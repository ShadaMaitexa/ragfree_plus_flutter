import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/material_model.dart';

class MaterialService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MaterialModel>> getMaterials() {
    return _firestore
        .collection('study_materials')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MaterialModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addMaterial(MaterialModel material) async {
    await _firestore.collection('study_materials').add(material.toFirestore());
  }

  Future<void> deleteMaterial(String id) async {
    await _firestore.collection('study_materials').doc(id).delete();
  }
}
