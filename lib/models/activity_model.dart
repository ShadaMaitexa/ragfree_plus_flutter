import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String userId;
  final String type; // complaint, chat, system, user
  final String title;
  final String description;
  final DateTime timestamp;
  final String? relatedId; // ID of related complaint, chat, etc.
  final Map<String, dynamic>? metadata; // Additional data

  ActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.relatedId,
    this.metadata,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> data) {
    return ActivityModel(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'system',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      relatedId: data['relatedId'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'timestamp': Timestamp.fromDate(timestamp),
      'relatedId': relatedId,
      'metadata': metadata,
    };
  }
}

