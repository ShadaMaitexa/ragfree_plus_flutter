import 'package:cloud_firestore/cloud_firestore.dart';

class AwarenessModel {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String role; // student, parent, teacher, admin, police, counsellor, warden, all
  final String? authorId;
  final String? authorRole;
  final String? category;
  final int views;
  final int likes;
  final DateTime createdAt;

  AwarenessModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.role,
    this.authorId,
    this.authorRole,
    this.category,
    this.views = 0,
    this.likes = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AwarenessModel.fromMap(Map<String, dynamic> map) {
    return AwarenessModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      content: map['content'] as String? ?? '',
      role: map['role'] as String? ?? 'all',
      authorId: map['authorId'] as String?,
      authorRole: map['authorRole'] as String?,
      category: map['category'] as String?,
      views: (map['views'] as num?)?.toInt() ?? 0,
      likes: (map['likes'] as num?)?.toInt() ?? 0,
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'content': content,
      'role': role,
      'authorId': authorId,
      'authorRole': authorRole,
      'category': category,
      'views': views,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AwarenessModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? content,
    String? role,
    String? authorId,
    String? authorRole,
    String? category,
    int? views,
    int? likes,
    DateTime? createdAt,
  }) {
    return AwarenessModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      content: content ?? this.content,
      role: role ?? this.role,
      authorId: authorId ?? this.authorId,
      authorRole: authorRole ?? this.authorRole,
      category: category ?? this.category,
      views: views ?? this.views,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
