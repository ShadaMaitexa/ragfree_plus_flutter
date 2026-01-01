import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialModel {
  final String id;
  final String title;
  final String category;
  final String type; // 'Document', 'Video', 'Guidance', 'Policy'
  final String url;
  final String size;
  final DateTime updatedAt;

  MaterialModel({
    required this.id,
    required this.title,
    required this.category,
    required this.type,
    required this.url,
    required this.size,
    required this.updatedAt,
  });

  factory MaterialModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MaterialModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      type: data['type'] ?? '',
      url: data['url'] ?? '',
      size: data['size'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'category': category,
      'type': type,
      'url': url,
      'size': size,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
