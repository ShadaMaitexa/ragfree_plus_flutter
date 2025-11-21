import 'package:cloud_firestore/cloud_firestore.dart';

class ParentStudentLinkModel {
  final String id;
  final String parentId;
  final String parentName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String relationship; // Mother, Father, Guardian, etc.
  final DateTime linkedAt;
  final bool isActive;
  final String? verificationCode; // For linking verification

  ParentStudentLinkModel({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.relationship,
    required this.linkedAt,
    this.isActive = true,
    this.verificationCode,
  });

  factory ParentStudentLinkModel.fromMap(Map<String, dynamic> data) {
    return ParentStudentLinkModel(
      id: data['id'] ?? '',
      parentId: data['parentId'] ?? '',
      parentName: data['parentName'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentEmail: data['studentEmail'] ?? '',
      relationship: data['relationship'] ?? 'Guardian',
      linkedAt: (data['linkedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
      verificationCode: data['verificationCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'parentId': parentId,
      'parentName': parentName,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'relationship': relationship,
      'linkedAt': Timestamp.fromDate(linkedAt),
      'isActive': isActive,
      'verificationCode': verificationCode,
    };
  }

  ParentStudentLinkModel copyWith({
    String? id,
    String? parentId,
    String? parentName,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? relationship,
    DateTime? linkedAt,
    bool? isActive,
    String? verificationCode,
  }) {
    return ParentStudentLinkModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      relationship: relationship ?? this.relationship,
      linkedAt: linkedAt ?? this.linkedAt,
      isActive: isActive ?? this.isActive,
      verificationCode: verificationCode ?? this.verificationCode,
    );
  }
}

