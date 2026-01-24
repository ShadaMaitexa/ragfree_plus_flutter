import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ragfree_plus_flutter/services/complaint_service.dart';
import 'package:ragfree_plus_flutter/services/app_state.dart';
import 'package:ragfree_plus_flutter/services/chat_service.dart';
import 'package:ragfree_plus_flutter/models/complaint_model.dart';
import 'package:ragfree_plus_flutter/models/chat_message_model.dart';
import 'package:ragfree_plus_flutter/screens/teacher/chat_page.dart';
import 'package:intl/intl.dart';
import 'package:ragfree_plus_flutter/widgets/add_complaint_dialog.dart';

class TeacherComplaintsPage extends StatefulWidget {
  const TeacherComplaintsPage({super.key});

  @override
  State<TeacherComplaintsPage> createState() => _TeacherComplaintsPageState();
}

class _TeacherComplaintsPageState extends State<TeacherComplaintsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ComplaintService _complaintService = ComplaintService();
  String _selectedFilter = 'All';

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

    // Set default filter to 'My Department' if teacher has a department
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AppState>(context, listen: false).currentUser;
      if (user?.department != null && user!.department!.isNotEmpty) {
        setState(() {
          _selectedFilter = 'My Department';
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Scaffold(
          body: FadeTransition(
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
                  _buildFilterChips(context),
                  Expanded(child: _buildComplaintsList(context)),
                ],
              ),
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
            child: Icon(Icons.assignment, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Complaints',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Monitor and respond to student safety complaints',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;
    final hasDepartment =
        user?.department != null && user!.department!.isNotEmpty;

    final filters = [
      'All',
      if (hasDepartment) 'My Department',
      'Pending',
      'In Progress',
      'Resolved',
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplaintsList(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;
    final institutionNormalized = user?.institutionNormalized ?? '';
    final department = user?.department ?? '';

    return StreamBuilder<List<ComplaintModel>>(
      stream: _selectedFilter == 'My Department'
          ? _complaintService.getComplaintsByDepartment(
              institutionNormalized,
              department,
            )
          : _complaintService.getComplaintsByInstitution(institutionNormalized),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final complaints = snapshot.data ?? [];
        final filteredComplaints =
            (_selectedFilter == 'All' || _selectedFilter == 'My Department')
            ? complaints
            : complaints.where((c) {
                if (_selectedFilter == 'In Progress') {
                  return c.status == 'In Progress' || c.status == 'Verified' || c.status == 'Accepted';
                }
                return c.status == _selectedFilter;
              }).toList();

        if (filteredComplaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  _selectedFilter == 'My Department'
                      ? 'No Department Complaints'
                      : 'No Complaints',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedFilter == 'My Department'
                      ? 'Try switching to "All" to see institution-wide complaints'
                      : 'No complaints found for the selected filter',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: filteredComplaints.length,
          itemBuilder: (context, index) {
            final complaint = filteredComplaints[index];
            return _buildComplaintCard(context, complaint);
          },
        );
      },
    );
  }

  Widget _buildComplaintCard(BuildContext context, ComplaintModel complaint) {
    Color statusColor;
    switch (complaint.status) {
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Accepted':
        statusColor = Colors.purple;
        break;
      case 'Verified':
        statusColor = Colors.orange;
        break;
      case 'Pending':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(Icons.assignment, color: statusColor, size: 20),
        ),
        title: Text(
          complaint.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student: ${complaint.studentName ?? "Anonymous"}'),
            Text(
              DateFormat('MMM dd, yyyy').format(complaint.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            complaint.status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description:',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(complaint.description),
                if (complaint.mediaUrls.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Media Attachments:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: complaint.mediaUrls.map((url) {
                      return Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image);
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _showForwardDialog(context, complaint),
                        icon: const Icon(Icons.forward),
                        label: const Text('Forward'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () =>
                            _handleComplaintChat(context, complaint),
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (complaint.status == 'Pending')
                        FilledButton.icon(
                          onPressed: () =>
                              _showVerifyDialog(context, complaint),
                          icon: const Icon(Icons.verified),
                          label: const Text('Verify'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleComplaintChat(
    BuildContext context,
    ComplaintModel complaint,
  ) async {
    try {
      if (complaint.studentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot chat with anonymous reporter')),
        );
        return;
      }

      final appState = Provider.of<AppState>(context, listen: false);
      final user = appState.currentUser;
      if (user == null) return;

      final chatService = ChatService();
      final chatId = await chatService.getOrCreateConversation(
        studentId: complaint.studentId!,
        studentName: complaint.studentName ?? 'Student',
        counselorId: user.uid,
        counselorName: user.name,
        complaintId: complaint.id,
        complaintTitle: complaint.title,
      );

      final conversation = ChatConversationModel(
        id: chatId,
        studentId: complaint.studentId!,
        studentName: complaint.studentName ?? 'Student',
        counselorId: user.uid,
        counselorName: user.name,
        complaintId: complaint.id,
        complaintTitle: complaint.title,
        createdAt: DateTime.now(),
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TeacherChatPage(initialConversation: conversation),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }



  void _showVerifyDialog(BuildContext context, ComplaintModel complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Complaint'),
        content: const Text(
          'Are you sure you want to verify this complaint as authentic?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                final appState = Provider.of<AppState>(context, listen: false);
                final user = appState.currentUser;
                if (user == null) throw Exception('User not logged in');

                await _complaintService.verifyComplaint(
                  complaintId: complaint.id,
                  verifierId: user.uid,
                  verifierName: user.name,
                  verifierRole: user.role,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complaint verified successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _showForwardDialog(BuildContext context, ComplaintModel complaint) {
    String selectedRole = 'police';
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Forward Complaint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select where to forward this complaint:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Forward To',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'police', child: Text('Police')),
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('College Admin'),
                  ),
                  DropdownMenuItem(value: 'warden', child: Text('Warden')),
                  DropdownMenuItem(
                    value: 'counsellor',
                    child: Text('Counsellor'),
                  ),
                ],
                onChanged: (val) => setDialogState(() => selectedRole = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Forward Description',
                  hintText: 'Add a note for the recipient...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  final appState = Provider.of<AppState>(
                    context,
                    listen: false,
                  );
                  final user = appState.currentUser;
                  if (user == null) throw Exception('User not logged in');

                  await _complaintService.forwardToRole(
                    complaintId: complaint.id,
                    forwardToRole: selectedRole,
                    forwarderId: user.uid,
                    forwarderName: user.name,
                    description: descriptionController.text.trim(),
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Forwarded to $selectedRole'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Forward'),
            ),
          ],
        ),
      ),
    );
  }
}
