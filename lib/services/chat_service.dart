import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or get conversation
  Future<String> getOrCreateConversation({
    required String studentId,
    required String studentName,
    String? counselorId,
    String? counselorName,
    String? counselorRole,
    String? complaintId,
    String? complaintTitle,
  }) async {
    try {
      // Check if conversation already exists
      Query query = _firestore
          .collection('chat_conversations')
          .where('studentId', isEqualTo: studentId);

      if (counselorId != null && counselorId.isNotEmpty) {
        query = query.where('counselorId', isEqualTo: counselorId);
      } else {
        // Handle cases where counselorId is not provided
      }

      if (complaintId != null && complaintId.isNotEmpty) {
        query = query.where('complaintId', isEqualTo: complaintId);
      }

      final existing = await query.get();

      if (existing.docs.isNotEmpty) {
        // If searching specifically for a complaint, we want that exact one
        if (complaintId != null && complaintId.isNotEmpty) {
          final complaintConvo = existing.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['complaintId'] == complaintId;
          }).toList();
          if (complaintConvo.isNotEmpty) {
            // Update the existing conversation with current counselor info if available
            if (counselorId != null &&
                (counselorName != null || counselorRole != null)) {
              final docRef = complaintConvo.first.reference;
              final updates = <String, dynamic>{};
              if (counselorName != null)
                updates['counselorName'] = counselorName;
              if (counselorRole != null)
                updates['counselorRole'] = counselorRole;
              if (updates.isNotEmpty) {
                await docRef.update(updates);
              }
            }
            return complaintConvo.first.id;
          }
        } else {
          // If no complaintId provided, prefer a general one, but take ANY existing one if it's the only one
          final generalConvo = existing.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['complaintId'] == null || data['complaintId'] == '';
          }).toList();

          if (generalConvo.isNotEmpty) {
            // Update the existing conversation with current counselor info if available
            if (counselorId != null &&
                (counselorName != null || counselorRole != null)) {
              final docRef = generalConvo.first.reference;
              final updates = <String, dynamic>{};
              if (counselorName != null)
                updates['counselorName'] = counselorName;
              if (counselorRole != null)
                updates['counselorRole'] = counselorRole;
              if (updates.isNotEmpty) {
                await docRef.update(updates);
              }
            }
            return generalConvo.first.id;
          }

          // If no general conversation but there is a complaint conversation, use it
          // This solves the issue where student sent messages via complaint but teacher clicks "New Chat"
          // Also update counselor info if available
          if (existing.docs.isNotEmpty) {
            final docRef = existing.docs.first.reference;
            if (counselorId != null &&
                (counselorName != null || counselorRole != null)) {
              final updates = <String, dynamic>{};
              if (counselorName != null)
                updates['counselorName'] = counselorName;
              if (counselorRole != null)
                updates['counselorRole'] = counselorRole;
              if (updates.isNotEmpty) {
                await docRef.update(updates);
              }
            }
            return existing.docs.first.id;
          }
        }
      }

      // Create new conversation document reference to get ID
      final docRef = _firestore.collection('chat_conversations').doc();

      final conversation = ChatConversationModel(
        id: docRef.id,
        studentId: studentId,
        studentName: studentName,
        counselorId: counselorId,
        counselorName: counselorName,
        counselorRole: counselorRole,
        complaintId: complaintId,
        complaintTitle: complaintTitle,
        createdAt: DateTime.now(),
      );

      await docRef.set(conversation.toMap());

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

      final docRef = _firestore
          .collection('chat_conversations')
          .doc(chatId)
          .collection('messages')
          .doc();

      final updatedMessage = messageModel.copyWith(id: docRef.id);

      await docRef.set(updatedMessage.toMap());

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
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    ChatMessageModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }

  // Get conversations for a student
  Stream<List<ChatConversationModel>> getStudentConversations(
    String studentId,
  ) {
    return _firestore
        .collection('chat_conversations')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map(
                (doc) => ChatConversationModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }),
              )
              .toList();
          // Sort by lastMessageAt or createdAt
          list.sort((a, b) {
            final aTime = a.lastMessageAt ?? a.createdAt;
            final bTime = b.lastMessageAt ?? b.createdAt;
            return bTime.compareTo(aTime);
          });
          return list;
        });
  }

  // Get conversations for a counselor
  Stream<List<ChatConversationModel>> getCounselorConversations(
    String counselorId,
  ) {
    return _firestore
        .collection('chat_conversations')
        .where('counselorId', isEqualTo: counselorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ChatConversationModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }),
              )
              .toList(),
        );
  }

  // Get a single conversation
  Future<ChatConversationModel> getConversation(String chatId) async {
    final doc = await _firestore
        .collection('chat_conversations')
        .doc(chatId)
        .get();
    if (!doc.exists) throw Exception('Conversation not found');
    return ChatConversationModel.fromMap({...doc.data()!, 'id': doc.id});
  }

  // Get conversations for a teacher (only those they are participating in)
  Stream<List<ChatConversationModel>> getTeacherConversations(
    String teacherId,
  ) {
    return _firestore
        .collection('chat_conversations')
        .where('counselorId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map(
                (doc) => ChatConversationModel.fromMap({
                  ...doc.data(),
                  'id': doc.id,
                }),
              )
              .toList();
          // Sort by lastMessageAt or createdAt
          list.sort((a, b) {
            final aTime = a.lastMessageAt ?? a.createdAt;
            final bTime = b.lastMessageAt ?? b.createdAt;
            return bTime.compareTo(aTime);
          });
          return list;
        });
  }

  // Get all students in an institution to start a new chat
  Future<List<Map<String, dynamic>>> getInstitutionStudents(
    String institution,
  ) async {
    try {
      final institutionNormalized = institution
          .trim()
          .replaceAll(RegExp(r'\s+'), '')
          .toLowerCase();
      final students = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .where('institutionNormalized', isEqualTo: institutionNormalized)
          .where('isApproved', isEqualTo: true)
          .get();

      return students.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Student',
          'department': data['department'] ?? 'General',
          'email': data['email'],
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get students: ${e.toString()}');
    }
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

  // Get available counselors
  Future<List<Map<String, dynamic>>> getAvailableCounselors() async {
    try {
      final counselors = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'counsellor')
          .where('isApproved', isEqualTo: true)
          .get();

      return counselors.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Counselor',
          'department': data['department'],
          'email': data['email'],
          'role': 'counsellor',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get counselors: ${e.toString()}');
    }
  }

  // Get available chat recipients (Counselors + Teachers in student's department)
  Future<List<Map<String, dynamic>>> getAvailableChatRecipients(
    String? department,
  ) async {
    try {
      // 1. Get all Counselors (independent of department)
      final counselorsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'counsellor')
          .where('isApproved', isEqualTo: true)
          .get();

      final counselors = counselorsQuery.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Counselor',
          'department': data['department'],
          'email': data['email'],
          'role': 'counsellor',
        };
      }).toList();

      // 2. Get Teachers. If department provided, filter by it; otherwise get all teachers.
      List<Map<String, dynamic>> teachers = [];
      final teachersQueryBase = _firestore
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .where('isApproved', isEqualTo: true);
      Query teachersQuery;
      if (department != null && department.isNotEmpty) {
        teachersQuery = teachersQueryBase.where(
          'department',
          isEqualTo: department,
        );
      } else {
        teachersQuery = teachersQueryBase;
      }

      final teachersQuerySnapshot = await teachersQuery.get();
      teachers = teachersQuerySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Teacher',
          'department': data['department'],
          'email': data['email'],
          'role': 'teacher',
        };
      }).toList();

      // Combine lists
      return [...counselors, ...teachers];
    } catch (e) {
      throw Exception('Failed to get chat recipients: ${e.toString()}');
    }
  }

  // Clear chat messages
  Future<void> clearChat(String chatId) async {
    try {
      final messages = await _firestore
          .collection('chat_conversations')
          .doc(chatId)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Update conversation last message
      batch.update(_firestore.collection('chat_conversations').doc(chatId), {
        'lastMessage': 'Chat cleared',
        'lastMessageAt': Timestamp.now(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear chat: ${e.toString()}');
    }
  }
}
