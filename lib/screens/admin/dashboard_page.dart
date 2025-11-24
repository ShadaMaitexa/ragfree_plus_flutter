import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/activity_service.dart';
import '../../services/emergency_alert_service.dart';
import '../../services/complaint_service.dart';
import '../../services/auth_service.dart';
import '../../models/activity_model.dart';
import '../../models/complaint_model.dart';
import '../../models/user_model.dart';
import '../../utils/responsive.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ActivityService _activityService = ActivityService();
  final EmergencyAlertService _emergencyAlertService = EmergencyAlertService();
  final ComplaintService _complaintService = ComplaintService();
  final AuthService _authService = AuthService();

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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: Responsive.getPadding(context),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: Responsive.isDesktop(context) ? 1200 : double.infinity,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeCard(context, color),
                          const SizedBox(height: 24),
                          _buildStatsGrid(context, color),
                          const SizedBox(height: 24),
                          _buildQuickActions(context, color),
                          const SizedBox(height: 24),
                          _buildRecentActivity(context),
                          const SizedBox(height: 24),
                          _buildSystemStatus(context),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, Admin!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Consumer<AppState>(
                      builder: (context, appState, _) {
                        final userName = appState.currentUser?.name ?? 'Admin';
                        return Text(
                          userName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Monitor and manage the campus safety system. Keep students safe and secure.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ComplaintModel>>(
          stream: _complaintService.getAllComplaints(),
          builder: (context, complaintsSnapshot) {
            return StreamBuilder<List<UserModel>>(
              stream: _authService.getUsersByRole('student'),
              builder: (context, studentsSnapshot) {
                return StreamBuilder<List<UserModel>>(
                  stream: _authService.getUsersByRole('counsellor'),
                  builder: (context, counsellorsSnapshot) {
                    return StreamBuilder<List<UserModel>>(
                      stream: _authService.getUsersByRole('teacher'),
                      builder: (context, teachersSnapshot) {
                        final complaints = complaintsSnapshot.data ?? [];
                        final students = studentsSnapshot.data ?? [];
                        final counsellors = counsellorsSnapshot.data ?? [];
                        final teachers = teachersSnapshot.data ?? [];
                        
                        final totalComplaints = complaints.length;
                        final resolvedComplaints = complaints.where((c) => c.status == 'Resolved').length;
                        final pendingComplaints = complaints.where((c) => c.status == 'Pending').length;
                        final totalUsers = students.length + counsellors.length + teachers.length;
                        
                        // Calculate average response time (hours between created and updated)
                        double avgResponseTime = 0.0;
                        if (resolvedComplaints > 0) {
                          final resolved = complaints.where((c) => c.status == 'Resolved' && c.updatedAt != null).toList();
                          if (resolved.isNotEmpty) {
                            final totalHours = resolved.fold<double>(0.0, (sum, c) {
                              if (c.updatedAt != null) {
                                final diff = c.updatedAt!.difference(c.createdAt);
                                return sum + diff.inHours.toDouble();
                              }
                              return sum;
                            });
                            avgResponseTime = totalHours / resolved.length;
                          }
                        }

                        final stats = [
                          {
                            'label': 'Total Complaints',
                            'value': totalComplaints.toString(),
                            'icon': Icons.assignment,
                            'color': Colors.blue,
                            'change': '',
                            'changeColor': Colors.transparent,
                          },
                          {
                            'label': 'Resolved',
                            'value': resolvedComplaints.toString(),
                            'icon': Icons.check_circle,
                            'color': Colors.green,
                            'change': totalComplaints > 0 ? '${((resolvedComplaints / totalComplaints) * 100).toStringAsFixed(0)}%' : '0%',
                            'changeColor': Colors.green,
                          },
                          {
                            'label': 'Pending',
                            'value': pendingComplaints.toString(),
                            'icon': Icons.pending,
                            'color': Colors.orange,
                            'change': totalComplaints > 0 ? '${((pendingComplaints / totalComplaints) * 100).toStringAsFixed(0)}%' : '0%',
                            'changeColor': Colors.orange,
                          },
                          {
                            'label': 'Active Users',
                            'value': totalUsers.toString(),
                            'icon': Icons.people,
                            'color': Colors.purple,
                            'change': '',
                            'changeColor': Colors.transparent,
                          },
                          {
                            'label': 'Counsellors',
                            'value': counsellors.length.toString(),
                            'icon': Icons.psychology,
                            'color': Colors.teal,
                            'change': '',
                            'changeColor': Colors.transparent,
                          },
                          {
                            'label': 'Response Time',
                            'value': avgResponseTime > 0 ? '${avgResponseTime.toStringAsFixed(1)}h' : 'N/A',
                            'icon': Icons.timer,
                            'color': Colors.red,
                            'change': '',
                            'changeColor': Colors.transparent,
                          },
                        ];

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = Responsive.getGridCrossAxisCount(
                              context,
                              mobile: 2,
                              tablet: 3,
                              desktop: 3,
                            );
                            final childAspectRatio = Responsive.getGridAspectRatio(
                              context,
                              mobile: 1.4,
                              tablet: 1.3,
                              desktop: 1.1,
                            );

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: childAspectRatio,
                              ),
                              itemCount: stats.length,
                              itemBuilder: (context, index) {
                                final stat = stats[index];
                                return _buildStatCard(
                                  context,
                                  stat['icon'] as IconData,
                                  stat['label'] as String,
                                  stat['value'] as String,
                                  stat['color'] as Color,
                                  stat['change'] as String,
                                  stat['changeColor'] as Color,
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
    String change,
    Color changeColor,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(
                Responsive.isDesktop(context) ? 20 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          Responsive.isDesktop(context) ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.1),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: constraints.maxWidth > 600 ? 20 : 18,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.isDesktop(context) ? 8 : 6,
                          vertical: Responsive.isDesktop(context) ? 4 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          change,
                          style: TextStyle(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: Responsive.isDesktop(context) ? 12 : 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.isDesktop(context) ? 12 : 8),
                  Flexible(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      {
        'icon': Icons.people,
        'title': 'Manage Users',
        'subtitle': 'Students, Staff & Parents',
        'color': Colors.blue,
        'onTap': () => _navigateToUsers(context),
      },
      {
        'icon': Icons.apartment,
        'title': 'Departments',
        'subtitle': 'Manage Departments',
        'color': Colors.green,
        'onTap': () => _navigateToDepartments(context),
      },
      {
        'icon': Icons.notifications,
        'title': 'Send Alerts',
        'subtitle': 'Campus Notifications',
        'color': Colors.orange,
        'onTap': () => _sendAlert(context),
      },
      {
        'icon': Icons.analytics,
        'title': 'Analytics',
        'subtitle': 'View Reports',
        'color': Colors.purple,
        'onTap': () => _navigateToAnalytics(context),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = Responsive.getGridCrossAxisCount(
              context,
              mobile: 2,
              tablet: 3,
              desktop: 4,
            );
            final childAspectRatio = Responsive.getGridAspectRatio(
              context,
              mobile: 1.4,
              tablet: 1.3,
              desktop: 1.2,
            );

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return _buildActionCard(
                  context,
                  action['icon'] as IconData,
                  action['title'] as String,
                  action['subtitle'] as String,
                  action['color'] as Color,
                  action['onTap'] as VoidCallback,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        Responsive.isDesktop(context) ? 12 : 10,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.1),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: Responsive.isDesktop(context) ? 24 : 20,
                      ),
                    ),
                    SizedBox(height: Responsive.isDesktop(context) ? 8 : 6),
                    Flexible(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ActivityModel>>(
          stream: _activityService.getAllActivities(limit: 10),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ),
              );
            }
            final activities = snapshot.data ?? [];
            if (activities.isEmpty) {
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.history, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No Recent Activity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'System activities will appear here',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: activities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  return Column(
                    children: [
                      _buildActivityItemFromModel(context, activity),
                      if (index < activities.length - 1) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityItemFromModel(
    BuildContext context,
    ActivityModel activity,
  ) {
    Color color;
    IconData icon;
    switch (activity.type) {
      case 'complaint':
        color = Colors.blue;
        icon = Icons.assignment;
        break;
      case 'chat':
        color = Colors.green;
        icon = Icons.chat;
        break;
      case 'system':
        color = Colors.orange;
        icon = Icons.school;
        break;
      case 'user':
        color = Colors.purple;
        icon = Icons.person_add;
        break;
      default:
        color = Colors.grey;
        icon = Icons.history;
    }

    final timeAgo = _getTimeAgo(activity.timestamp);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        activity.title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(activity.description),
      trailing: Text(
        timeAgo,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildSystemStatus(BuildContext context) {
    final statuses = [
      {
        'service': 'Database',
        'status': 'Online',
        'color': Colors.green,
        'uptime': '99.9%',
      },
      {
        'service': 'API Server',
        'status': 'Online',
        'color': Colors.green,
        'uptime': '99.8%',
      },
      {
        'service': 'Notification Service',
        'status': 'Online',
        'color': Colors.green,
        'uptime': '99.7%',
      },
      {
        'service': 'File Storage',
        'status': 'Maintenance',
        'color': Colors.orange,
        'uptime': '98.5%',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Status',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: statuses.map((status) {
              return _buildStatusItem(context, status);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusItem(BuildContext context, Map<String, dynamic> status) {
    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: status['color'],
        ),
      ),
      title: Text(
        status['service'],
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Uptime: ${status['uptime']}'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: status['color'].withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          status['status'],
          style: TextStyle(
            color: status['color'],
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _navigateToUsers(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to user management...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _navigateToDepartments(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to departments...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendAlert(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedPriority = 'medium';
    final priorities = [
      {'value': 'low', 'label': 'Low'},
      {'value': 'medium', 'label': 'Medium'},
      {'value': 'high', 'label': 'High'},
      {'value': 'critical', 'label': 'Critical'},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Send Campus Alert'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Alert Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Alert Message',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.priority_high),
                ),
                items: priorities.map((priority) {
                  return DropdownMenuItem(
                    value: priority['value'],
                    child: Text(priority['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedPriority = value ?? 'medium';
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              titleController.dispose();
              messageController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (titleController.text.trim().isEmpty ||
                  messageController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final appState = Provider.of<AppState>(context, listen: false);
                final user = appState.currentUser;

                if (user != null) {
                  await _emergencyAlertService.createEmergencyAlert(
                    title: titleController.text.trim(),
                    message: messageController.text.trim(),
                    priority: selectedPriority,
                    createdBy: user.uid,
                  );

                  titleController.dispose();
                  messageController.dispose();

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Campus alert sent successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: ${e.toString().replaceAll('Exception: ', '')}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  void _navigateToAnalytics(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to analytics...'),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
