import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;
  final String chatId; // Conversation ID
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? messageType; // text, image, file

  ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.messageType = 'text',
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> data) {
    return ChatMessageModel(
      id: data['id'] ?? '',
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderRole: data['senderRole'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      messageType: data['messageType'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'messageType': messageType,
    };
  }

  ChatMessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? messageType,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
    );
  }
}

class ChatConversationModel {
  final String id;
  final String studentId;
  final String studentName;
  final String? counselorId;
  final String? counselorName;
  final String? complaintId;
  final String? complaintTitle;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final String? lastMessage;
  final int unreadCount;

  ChatConversationModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    this.counselorId,
    this.counselorName,
    this.complaintId,
    this.complaintTitle,
    required this.createdAt,
    this.lastMessageAt,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ChatConversationModel.fromMap(Map<String, dynamic> data) {
    return ChatConversationModel(
      id: data['id'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      counselorId: data['counselorId'],
      counselorName: data['counselorName'],
      complaintId: data['complaintId'],
      complaintTitle: data['complaintTitle'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessageAt: data['lastMessageAt'] != null
          ? (data['lastMessageAt'] as Timestamp).toDate()
          : null,
      lastMessage: data['lastMessage'],
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'counselorId': counselorId,
      'counselorName': counselorName,
      'complaintId': complaintId,
      'complaintTitle': complaintTitle,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt':
          lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'lastMessage': lastMessage,
      'unreadCount': unreadCount,
    };
  }

  ChatConversationModel copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? counselorId,
    String? counselorName,
    String? complaintId,
    String? complaintTitle,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    String? lastMessage,
    int? unreadCount,
  }) {
    return ChatConversationModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      counselorId: counselorId ?? this.counselorId,
      counselorName: counselorName ?? this.counselorName,
      complaintId: complaintId ?? this.complaintId,
      complaintTitle: complaintTitle ?? this.complaintTitle,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

