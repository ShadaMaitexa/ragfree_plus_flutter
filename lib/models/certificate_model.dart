import 'package:cloud_firestore/cloud_firestore.dart';

class CertificateModel {
  final String id;
  final String studentName;
  final String course;
  final DateTime issueDate;
  final String status; // 'Issued', 'Pending'

  CertificateModel({
    required this.id,
    required this.studentName,
    required this.course,
    required this.issueDate,
    required this.status,
  });

  factory CertificateModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CertificateModel(
      id: doc.id,
      studentName: data['studentName'] ?? '',
      course: data['course'] ?? '',
      issueDate: (data['issueDate'] as Timestamp).toDate(),
      status: data['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'studentName': studentName,
      'course': course,
      'issueDate': Timestamp.fromDate(issueDate),
      'status': status,
    };
  }

  CertificateModel copyWith({
    String? id,
    String? studentName,
    String? course,
    DateTime? issueDate,
    String? status,
  }) {
    return CertificateModel(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      course: course ?? this.course,
      issueDate: issueDate ?? this.issueDate,
      status: status ?? this.status,
    );
  }
}
