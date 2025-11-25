import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/chat_service.dart';
import '../../services/app_state.dart';
import '../../models/chat_message_model.dart';
import 'package:intl/intl.dart';

class TeacherChatPage extends StatefulWidget {
  const TeacherChatPage({super.key});

  @override
  State<TeacherChatPage> createState() => _TeacherChatPageState();
}

class _TeacherChatPageState extends State<TeacherChatPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [color.withOpacity(0.05), Colors.transparent]
                    : [Colors.grey.shade50, Colors.white],
              ),
            ),
            child: Column(
              children: [
                _buildHeader(context, color),
                Expanded(
                  child: _buildConversationsContent(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.chat, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat with Students & Staff',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Communicate with students and colleagues',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsContent(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    if (user == null) {
      return const Center(child: Text('Please login to access chat'));
    }

    return StreamBuilder<List<ChatConversationModel>>(
      stream: _chatService.getTeacherConversations(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final conversations = snapshot.data ?? [];

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Conversations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'No student conversations available yet',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            return _buildConversationCard(context, conversation);
          },
        );
      },
    );
  }

  Widget _buildConversationCard(BuildContext context, ChatConversationModel conversation) {
    final lastMessageTime = conversation.lastMessageAt;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.person,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          conversation.studentName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          conversation.lastMessage ?? 'No messages yet',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: lastMessageTime != null
            ? Text(
                DateFormat('MMM dd').format(lastMessageTime),
                style: Theme.of(context).textTheme.bodySmall,
              )
            : null,
        onTap: () {
          // Navigate to chat detail - can be implemented later
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chat with ${conversation.studentName}'),
            ),
          );
        },
      ),
    );
  }
}

