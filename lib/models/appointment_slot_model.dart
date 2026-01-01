import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentSlotModel {
  final String id;
  final String counselorId;
  final String counselorName;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status; // 'available', 'booked', 'completed', 'cancelled'
  final String? studentId;
  final String? studentName;
  final DateTime createdAt;

  AppointmentSlotModel({
    required this.id,
    required this.counselorId,
    required this.counselorName,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = 'available',
    this.studentId,
    this.studentName,
    required this.createdAt,
  });

  factory AppointmentSlotModel.fromMap(Map<String, dynamic> data) {
    return AppointmentSlotModel(
      id: data['id'] ?? '',
      counselorId: data['counselorId'] ?? '',
      counselorName: data['counselorName'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      status: data['status'] ?? 'available',
      studentId: data['studentId'],
      studentName: data['studentName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'counselorId': counselorId,
      'counselorName': counselorName,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
      'studentId': studentId,
      'studentName': studentName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
