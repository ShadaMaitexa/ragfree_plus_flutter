import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  final String id;
  final String userId;
  final String userName;
  final String userRole; // Student, Teacher, etc.
  final String content;
  final double rating;
  final DateTime createdAt;
  final String? category;

  FeedbackModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.content,
    required this.rating,
    required this.createdAt,
    this.category,
  });

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userRole: map['userRole'] ?? '',
      content: map['content'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'content': content,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'category': category,
    };
  }

  FeedbackModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userRole,
    String? content,
    double? rating,
    DateTime? createdAt,
    String? category,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
    );
  }
}
