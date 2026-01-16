import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../services/chat_service.dart';
import '../../models/chat_message_model.dart';
import '../../services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class WardenStudentsPage extends StatefulWidget {
  const WardenStudentsPage({super.key});

  @override
  State<WardenStudentsPage> createState() => _WardenStudentsPageState();
}

class _WardenStudentsPageState extends State<WardenStudentsPage> {
  final AuthService _authService = AuthService();
  String _searchQuery = '';
  String _selectedDepartment = 'All';

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      'Computer Science',
                      'Electronics',
                      'Mechanical',
                      'Civil',
                      'Other'
                    ].map((dept) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(dept, style: TextStyle(fontSize: 12)),
                        selected: _selectedDepartment == dept,
                        onSelected: (val) => setState(() => _selectedDepartment = dept),
                        selectedColor: color.withOpacity(0.2),
                        checkmarkColor: color,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _authService.getUsersByRole('student'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          var students = snapshot.data ?? [];
          
          // Apply filters
          students = students.where((s) {
            final matchesSearch = s.name.toLowerCase().contains(_searchQuery) || 
                                (s.email?.toLowerCase().contains(_searchQuery) ?? false);
            final matchesDept = _selectedDepartment == 'All' || s.department == _selectedDepartment;
            return matchesSearch && matchesDept;
          }).toList();

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text('No students found', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: color.withOpacity(0.1),
                      child: Text(
                        student.name[0].toUpperCase(),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    title: Text(
                      student.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.apartment, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(student.department ?? 'No Department', style: TextStyle(color: Colors.grey.shade600)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(student.email, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      icon: const Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'details', child: Row(children: [Icon(Icons.info_outline), SizedBox(width: 8), Text('Details')])),
                        const PopupMenuItem(value: 'chat', child: Row(children: [Icon(Icons.chat_bubble_outline), SizedBox(width: 8), Text('Chat')])),
                        const PopupMenuItem(value: 'call', child: Row(children: [Icon(Icons.phone_outlined), SizedBox(width: 8), Text('Call')])),
                        const PopupMenuItem(value: 'email', child: Row(children: [Icon(Icons.mail_outline), SizedBox(width: 8), Text('Email')])),
                      ],
                      onSelected: (value) => _handleAction(value, student),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleAction(String value, UserModel student) {
    switch (value) {
      case 'details':
        _showStudentDetails(student);
        break;
      case 'chat':
        _handleChat(student);
        break;
      case 'call':
        if (student.phone != null) {
          launchUrl(Uri.parse('tel:${student.phone}'));
        }
        break;
      case 'email':
        launchUrl(Uri.parse('mailto:${student.email}'));
        break;
    }
  }

  Future<void> _handleChat(UserModel student) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user == null) return;

    try {
      final chatService = ChatService();
      final chatId = await chatService.getOrCreateConversation(
        studentId: student.uid,
        studentName: student.name,
        counselorId: user.uid,
        counselorName: user.name,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WardenChatDetailPage(
              chatId: chatId,
              peerName: student.name,
              peerRole: 'student',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting chat: $e')),
        );
      }
    }
  }

  void _showStudentDetails(UserModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(child: Text(student.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(Icons.email, 'Email', student.email),
            _detailRow(Icons.phone, 'Phone', student.phone ?? 'N/A'),
            _detailRow(Icons.apartment, 'Department', student.department ?? 'N/A'),
            _detailRow(Icons.verified_user, 'Status', student.isApproved ? 'Approved' : 'Pending'),
            _detailRow(Icons.calendar_today, 'Joined', 'Recent'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

class WardenChatDetailPage extends StatefulWidget {
  final String chatId;
  final String peerName;
  final String peerRole;

  const WardenChatDetailPage({
    super.key,
    required this.chatId,
    required this.peerName,
    required this.peerRole,
  });

  @override
  State<WardenChatDetailPage> createState() => _WardenChatDetailPageState();
}

class _WardenChatDetailPageState extends State<WardenChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.peerName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessageModel>>(
              stream: _chatService.getMessages(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == user.uid;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          msg.message,
                          style: TextStyle(color: isMe ? Colors.white : Colors.black),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (_messageController.text.isEmpty) return;
                    await _chatService.sendMessage(
                      chatId: widget.chatId,
                      senderId: user.uid,
                      senderName: user.name,
                      senderRole: user.role,
                      message: _messageController.text,
                    );
                    _messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
