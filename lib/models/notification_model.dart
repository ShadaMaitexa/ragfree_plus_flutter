import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type; // success, warning, info, error
  final DateTime createdAt;
  final bool isRead;
  final String? relatedId; // ID of related complaint, chat, etc.
  final String? relatedType; // complaint, chat, system, etc.

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.relatedId,
    this.relatedType,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data) {
    return NotificationModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'info',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      relatedId: data['relatedId'],
      relatedType: data['relatedType'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'relatedId': relatedId,
      'relatedType': relatedType,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    DateTime? createdAt,
    bool? isRead,
    String? relatedId,
    String? relatedType,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
    );
  }
}

