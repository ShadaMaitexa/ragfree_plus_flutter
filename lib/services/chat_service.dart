import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get conversation between student and counselor
  Future<String> getOrCreateConversation({
    required String studentId,
    required String studentName,
    String? counselorId,
    String? counselorName,
  }) async {
    try {
      // Check if conversation already exists
      QuerySnapshot existing = await _firestore
          .collection('chat_conversations')
          .where('studentId', isEqualTo: studentId)
          .where('counselorId', isEqualTo: counselorId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }

      // Create new conversation
      final conversation = ChatConversationModel(
        id: '',
        studentId: studentId,
        studentName: studentName,
        counselorId: counselorId,
        counselorName: counselorName,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('chat_conversations')
          .add(conversation.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create conversation: ${e.toString()}');
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String senderRole,
    required String message,
  }) async {
    try {
      final messageModel = ChatMessageModel(
        id: '',
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        senderRole: senderRole,
        message: message,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('chat_conversations')
          .doc(chatId)
          .collection('messages')
          .add(messageModel.toMap());

      // Update conversation last message
      await _firestore.collection('chat_conversations').doc(chatId).update({
        'lastMessage': message,
        'lastMessageAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  // Get messages for a conversation
  Stream<List<ChatMessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chat_conversations')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessageModel.fromMap(doc.data()))
            .toList());
  }

  // Get conversations for a student
  Stream<List<ChatConversationModel>> getStudentConversations(
      String studentId) {
    return _firestore
        .collection('chat_conversations')
        .where('studentId', isEqualTo: studentId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatConversationModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Get conversations for a counselor
  Stream<List<ChatConversationModel>> getCounselorConversations(
      String counselorId) {
    return _firestore
        .collection('chat_conversations')
        .where('counselorId', isEqualTo: counselorId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatConversationModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }))
            .toList());
  }

  // Mark messages as read
  Future<void> markAsRead(String chatId, String userId) async {
    try {
      final messages = await _firestore
          .collection('chat_conversations')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isNotEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark as read: ${e.toString()}');
    }
  }
}

