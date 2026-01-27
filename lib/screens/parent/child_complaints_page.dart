import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/complaint_service.dart';
import '../../services/parent_student_service.dart';
import '../../services/app_state.dart';
import '../../models/complaint_model.dart';
import '../../models/user_model.dart';
import 'package:intl/intl.dart';
import '../../widgets/add_complaint_dialog.dart';

class ParentChildComplaintsPage extends StatefulWidget {
  const ParentChildComplaintsPage({super.key});

  @override
  State<ParentChildComplaintsPage> createState() =>
      _ParentChildComplaintsPageState();
}

class _ParentChildComplaintsPageState extends State<ParentChildComplaintsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ComplaintService _complaintService = ComplaintService();
  final ParentStudentService _parentStudentService = ParentStudentService();
  int _currentTab = 0;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
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
                        ? [color.withValues(alpha: 0.05), Colors.transparent]
                        : [Colors.grey.shade50, Colors.white],
                  ),
                ),
                child: Column(
                  children: [
                    _buildHeader(context, color),
                    TabBar(
                      onTap: (index) => setState(() => _currentTab = index),
                      tabs: const [
                        Tab(text: 'My Children', icon: Icon(Icons.family_restroom)),
                        Tab(text: 'Campus Feed', icon: Icon(Icons.public)),
                      ],
                      indicatorColor: color,
                      labelColor: color,
                      unselectedLabelColor: Colors.grey,
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildComplaintsContent(context),
                          _buildCampusFeedContent(context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: _currentTab == 0 ? FloatingActionButton(
          onPressed: () => _showAddComplaintDialog(context),
          backgroundColor: color,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ) : null,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    final user = Provider.of<AppState>(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
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
                      _currentTab == 0 ? 'Child Complaints' : 'Campus Safety Feed',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      _currentTab == 0 
                          ? 'Monitor your children\'s safety reports'
                          : 'Recent reports from other students in your campus',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_currentTab == 0)
            StreamBuilder<List<UserModel>>(
              stream: _parentStudentService.getStudentsByParentEmail(user.email),
              builder: (context, studentsSnapshot) {
                final students = studentsSnapshot.data ?? [];
                if (students.isEmpty) return const SizedBox.shrink();
                
                final List<String> studentIds = students.map((s) => s.uid).toList().cast<String>();
                return StreamBuilder<List<ComplaintModel>>(
                  stream: _complaintService.getParentChildComplaints(studentIds),
                  builder: (context, snapshot) {
                    final complaints = snapshot.data ?? [];
                    return Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(context, 'Total Reports', '${complaints.length}', Icons.assignment, Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(context, 'Resolved', '${complaints.where((c) => c.status == 'Resolved').length}', Icons.check_circle, Colors.green),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(context, 'Pending', '${complaints.where((c) => c.status == 'Pending').length}', Icons.pending, Colors.orange),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCampusFeedContent(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;
    if (user == null || user.institutionNormalized == null) {
      return _buildEmptyState(context, Colors.grey, text: 'No institution data found');
    }

    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getComplaintsByInstitution(user.institutionNormalized!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final complaints = snapshot.data ?? [];
        if (complaints.isEmpty) {
          return _buildEmptyState(context, Colors.grey, text: 'No reports from your campus yet');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            // Anonymize for campus feed
            return _buildComplaintCard(
              context, 
              complaint, 
              'Student at ${user.institution}', 
              index, 
              {},
              isPublic: true,
            );
          },
        );
      },
    );
  }

  void _showAddComplaintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddComplaintDialog(
        isParent: true,
        onComplaintAdded: () {
          // Stream will automatically update
        },
      ),
    );
  }


  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color color, {String? text}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(Icons.assignment_outlined, size: 64, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            'No Complaints Yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            text ?? 'Your children\'s safety reports will appear here',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }


  Widget _buildComplaintsContent(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;
    if (user == null) return const Center(child: Text('User not found'));

    return StreamBuilder<List<UserModel>>(
      stream: _parentStudentService.getStudentsByParentEmail(user.email),
      builder: (context, studentsSnapshot) {
        if (studentsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final students = studentsSnapshot.data ?? [];
        if (students.isEmpty) {
          return _buildNoLinkedStudentsState(context);
        }

        final List<String> studentIds = students.map((s) => s.uid).toList().cast<String>();
        
        return StreamBuilder<List<ComplaintModel>>(
          stream: _complaintService.getParentChildComplaints(studentIds),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final complaints = snapshot.data ?? [];
            if (complaints.isEmpty) {
              return _buildEmptyState(context, Theme.of(context).colorScheme.primary);
            }
            return _buildComplaintsList(context, complaints, students);
          },
        );
      },
    );
  }



  Widget _buildNoLinkedStudentsState(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final parentEmail = Provider.of<AppState>(context, listen: false).currentUser?.email ?? '';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(Icons.link_off, size: 64, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            'No Linked Students',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Students linked to your email ($parentEmail) will appear here. Ask your child to provide your email in their profile.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsList(
    BuildContext context,
    List<ComplaintModel> complaints,
    List<UserModel> students,
  ) {
    // Create a map of uid to name
    final Map<String, String> studentMap = {for (var s in students) s.uid: s.name};
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView.builder(
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? 40 : 20,
          ),
          itemCount: complaints.length,
          itemBuilder: (context, index) {
            final complaint = complaints[index];
            final childName = complaint.studentId != null
                ? (studentMap[complaint.studentId!] ?? complaint.studentName ?? 'Anonymous')
                : 'Anonymous';
            return _buildComplaintCard(context, complaint, childName, index, studentMap);
          },
        );
      },
    );
  }

  Widget _buildComplaintCard(
    BuildContext context,
    ComplaintModel complaint,
    String childName,
    int index,
    Map<String, String> studentMap, {
    bool isPublic = false,
  }) {
    final status = complaint.status;

    Color statusColor;
    switch (status) {
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    // Priority color logic removed as we are showing incident type which uses primary color

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _showComplaintDetails(context, complaint, childName, isPublic: isPublic),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        complaint.incidentType,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM dd, yyyy').format(complaint.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        childName
                            .split(' ')
                            .map((n) => n.isNotEmpty ? n[0] : '')
                            .join()
                            .toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        childName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (complaint.isAnonymous)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.visibility_off, size: 12, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              'Anonymous',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  complaint.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  complaint.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (complaint.mediaUrls.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: complaint.mediaUrls.length,
                      itemBuilder: (context, idx) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              complaint.mediaUrls[idx],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        complaint.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (complaint.assignedToName != null) ...[
                      const Spacer(),
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          complaint.assignedToName!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'ID: ${complaint.id.substring(0, 8)}...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontFamily: 'monospace',
                      ),
                    ),
                    const Spacer(),
                    if (complaint.updatedAt != null)
                      Text(
                        'Updated: ${DateFormat('MMM dd').format(complaint.updatedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

   void _showComplaintDetails(
    BuildContext context,
    ComplaintModel complaint,
    String childName, {
    bool isPublic = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                childName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join().toUpperCase(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                complaint.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Child: $childName',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(complaint.description),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Status: ',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    complaint.status,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Type: ',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    complaint.incidentType,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (complaint.assignedToName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Assigned to: ',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      complaint.assignedToName!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('Date: ', style: Theme.of(context).textTheme.titleSmall),
                  Text(
                    DateFormat('MMM dd, yyyy').format(complaint.createdAt),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if (complaint.updatedAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Last Update: ',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(complaint.updatedAt!),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
              if (complaint.mediaUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Media:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: complaint.mediaUrls.map((url) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.broken_image);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (!isPublic && complaint.assignedToName != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _contactCounselor(context, complaint);
              },
              child: const Text('Contact Counselor'),
            ),
        ],
      ),
    );
  }

  void _contactCounselor(BuildContext context, ComplaintModel complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Counselor'),
        content: Text(
          'Would you like to start a conversation with ${complaint.assignedToName} about this complaint?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to chat - you can implement this
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chat feature coming soon...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }

}
