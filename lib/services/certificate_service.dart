import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/certificate_model.dart';

class CertificateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CertificateModel>> getCertificates() {
    return _firestore
        .collection('certificates')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CertificateModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> issueCertificate(CertificateModel cert) async {
    final docRef = _firestore.collection('certificates').doc();
    final updatedCert = cert.copyWith(id: docRef.id);
    await docRef.set(updatedCert.toFirestore());
  }

  Future<void> updateStatus(String id, String status) async {
    await _firestore.collection('certificates').doc(id).update({
      'status': status,
    });
  }

  Future<void> deleteCertificate(String id) async {
    await _firestore.collection('certificates').doc(id).delete();
  }
}
