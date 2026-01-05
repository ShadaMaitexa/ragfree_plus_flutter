import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintModel {
  final String id;
  final String? studentId; // null if anonymous
  final String? studentName; // null if anonymous
  final String title;
  final String description;
  final String category;
  final String priority;
  final String incidentType; // Hostel, College, Other
  final String status; // Pending, In Progress, Resolved, Rejected
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> mediaUrls; // URLs of uploaded images/videos
  final String? assignedTo; // Counselor/Admin ID
  final String? assignedToName;
  final String? location;
  final Map<String, dynamic>? metadata; // Additional data
  final bool isAnonymous;

  ComplaintModel({
    required this.id,
    this.studentId,
    this.studentName,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.incidentType,
    this.status = 'Pending',
    required this.createdAt,
    this.updatedAt,
    this.mediaUrls = const [],
    this.assignedTo,
    this.assignedToName,
    this.location,
    this.metadata,
    this.isAnonymous = false,
  });

  factory ComplaintModel.fromMap(Map<String, dynamic> data) {
    return ComplaintModel(
      id: data['id'] ?? '',
      studentId: data['studentId'],
      studentName: data['studentName'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      priority: data['priority'] ?? 'Medium',
      incidentType: data['incidentType'] ?? 'College',
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      assignedTo: data['assignedTo'],
      assignedToName: data['assignedToName'],
      location: data['location'],
      metadata: data['metadata'],
      isAnonymous: data['isAnonymous'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'incidentType': incidentType,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'mediaUrls': mediaUrls,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'location': location,
      'metadata': metadata,
      'isAnonymous': isAnonymous,
    };
  }

  ComplaintModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? incidentType,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? mediaUrls,
    String? assignedTo,
    String? assignedToName,
    String? location,
    Map<String, dynamic>? metadata,
    bool? isAnonymous,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      incidentType: incidentType ?? this.incidentType,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}

