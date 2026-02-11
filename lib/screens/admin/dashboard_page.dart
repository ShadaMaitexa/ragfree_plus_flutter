import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/activity_service.dart';
import '../../services/emergency_alert_service.dart';
import '../../services/complaint_service.dart';
import '../../services/auth_service.dart';
import '../../services/department_service.dart';
import '../../models/activity_model.dart';
import '../../models/complaint_model.dart';
import '../../models/user_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_widgets.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final ActivityService _activityService = ActivityService();
  final EmergencyAlertService _emergencyAlertService = EmergencyAlertService();
  final ComplaintService _complaintService = ComplaintService();
  final AuthService _authService = AuthService();
  final DepartmentService _departmentService = DepartmentService();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  color.withValues(alpha: 0.08),
                  Colors.transparent,
                  color.withValues(alpha: 0.04),
                ]
              : [
                  Colors.white,
                  color.withValues(alpha: 0.02),
                  color.withValues(alpha: 0.05),
                ],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.getPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmergencyBanner(context),
              AnimatedWidgets.slideIn(
                beginOffset: const Offset(0, 0.2),
                child: _buildWelcomeCard(context, color),
              ),
              const SizedBox(height: 32),
              AnimatedWidgets.slideIn(
                beginOffset: const Offset(0, 0.2),
                delay: const Duration(milliseconds: 100),
                child: _buildStatsGrid(context, color),
              ),
              const SizedBox(height: 32),
              AnimatedWidgets.slideIn(
                beginOffset: const Offset(0, 0.2),
                delay: const Duration(milliseconds: 200),
                child: _buildQuickActions(context, color),
              ),
              const SizedBox(height: 32),
              AnimatedWidgets.slideIn(
                beginOffset: const Offset(0, 0.2),
                delay: const Duration(milliseconds: 300),
                child: _buildRecentActivity(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyBanner(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _emergencyAlertService.getActiveGlobalAlerts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final criticalAlerts = snapshot.data!
            .where((a) => a['priority'] == 'critical')
            .toList();
        if (criticalAlerts.isEmpty) return const SizedBox.shrink();

        return AnimatedWidgets.pulsing(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.redAccent, Colors.red],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: criticalAlerts.map((alert) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emergency_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  title: Text(
                    alert['title'] ?? 'EmergencySOS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    '${alert['message']}\nLocation: ${alert['location'] ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () =>
                        _emergencyAlertService.deactivateAlert(alert['id']),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(BuildContext context, Color color) {
    return AnimatedWidgets.hoverCard(
      elevation: 8,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withValues(alpha: 0.85)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'System Administrator',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Consumer<AppState>(
                        builder: (context, appState, _) {
                          final userName =
                              appState.currentUser?.name ?? 'Admin';
                          return Text(
                            userName,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Master control center for campus safety. Real-time monitoring and management active.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Real-time Analytics',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        StreamBuilder<List<ComplaintModel>>(
          stream: _complaintService.getAllComplaints(),
          builder: (context, complaintsSnapshot) {
            return StreamBuilder<List<UserModel>>(
              stream: _authService.getUsersByRole('student'),
              builder: (context, studentsSnapshot) {
                return StreamBuilder<List<String>>(
                  stream: _departmentService.getDepartmentNames(),
                  builder: (context, deptsSnapshot) {
                    final complaints = complaintsSnapshot.data ?? [];
                    final students = studentsSnapshot.data ?? [];
                    final departmentCount = deptsSnapshot.data?.length ?? 0;

                    final stats = [
                      {
                        'label': 'Total Complaints',
                        'value': '${complaints.length}',
                        'icon': Icons.assignment_rounded,
                        'color': Colors.blue,
                      },
                      {
                        'label': 'Departments',
                        'value': '$departmentCount',
                        'icon': Icons.apartment_rounded,
                        'color': Colors.teal,
                      },
                      {
                        'label': 'Action Required',
                        'value':
                            '${complaints.where((c) => c.status == 'Pending').length}',
                        'icon': Icons.warning_amber_rounded,
                        'color': Colors.orange,
                      },
                      {
                        'label': 'Total Students',
                        'value': '${students.length}',
                        'icon': Icons.people_alt_rounded,
                        'color': Colors.purple,
                      },
                    ];

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: Responsive.getGridCrossAxisCount(
                          context,
                          mobile: 2,
                          tablet: 4,
                          desktop: 4,
                        ),
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.3,
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
  ) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            AnimatedWidgets.counterText(
              count: int.tryParse(value) ?? 0,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      {
        'icon': Icons.people_rounded,
        'title': 'Users',
        'color': Colors.blue,
        'onTap': () => _navigateToUsers(context),
      },
      {
        'icon': Icons.apartment_rounded,
        'title': 'Divisions',
        'color': Colors.green,
        'onTap': () => _navigateToDepartments(context),
      },
      {
        'icon': Icons.notifications_active_rounded,
        'title': 'Global Notification',
        'color': Colors.orange,
        'onTap': () => _sendAlert(context),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Management Tools',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.getGridCrossAxisCount(
              context,
              mobile: 2,
              tablet: 4,
              desktop: 4,
            ),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              context,
              action['icon'] as IconData,
              action['title'] as String,
              action['color'] as Color,
              action['onTap'] as VoidCallback,
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
    Color color,
    VoidCallback onTap,
  ) {
    return AnimatedWidgets.scaleButton(
      onPressed: onTap,
      child: AnimatedWidgets.hoverCard(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
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
                  child: Center(child: Text('Error: ${snapshot.error}')),
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
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
                      if (index < activities.length - 1)
                        const Divider(height: 1),
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
          color: color.withValues(alpha: 0.1),
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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

  void _navigateToUsers(BuildContext context) {
    Provider.of<AppState>(context, listen: false).setNavIndex(1);
  }

  void _navigateToDepartments(BuildContext context) {
    Provider.of<AppState>(context, listen: false).setNavIndex(3);
  }

  void _sendAlert(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedPriority = 'medium';
    List<String> selectedRoles = ['all'];

    final availableRoles = [
      {'value': 'all', 'label': 'All Users'},
      {'value': 'student', 'label': 'Students'},
      {'value': 'teacher', 'label': 'Teachers'},
      {'value': 'parent', 'label': 'Parents'},
      {'value': 'counsellor', 'label': 'Counsellors'},
      {'value': 'warden', 'label': 'Wardens'},
      {'value': 'police', 'label': 'Police'},
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.dashboard_customize_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text('Send Global Notification'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.message),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Recipients',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableRoles.map((role) {
                      final isSelected = selectedRoles.contains(role['value']);
                      return FilterChip(
                        label: Text(role['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (role['value'] == 'all') {
                              if (selected) {
                                selectedRoles = ['all'];
                              } else {
                                selectedRoles = [];
                              }
                            } else {
                              if (selected) {
                                selectedRoles.remove('all');
                                selectedRoles.add(role['value']!);
                              } else {
                                selectedRoles.remove(role['value']);
                              }
                              // Optionally logic to re-select 'all' if empty
                              if (selectedRoles.isEmpty) {
                                selectedRoles = ['all'];
                              }
                            }
                          });
                        },
                        selectedColor: Colors.orange.withValues(alpha: 0.2),
                        checkmarkColor: Colors.orange,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.orange : Colors.grey[700],
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      );
                    }).toList(),
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

                  if (selectedRoles.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please select at least one recipient type',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    final appState = Provider.of<AppState>(
                      context,
                      listen: false,
                    );
                    final user = appState.currentUser;

                    if (user != null) {
                      await _emergencyAlertService.createGlobalAlert(
                        title: titleController.text.trim(),
                        message: messageController.text.trim(),
                        priority: selectedPriority,
                        createdBy: user.uid,
                        targetRoles: selectedRoles,
                      );

                      titleController.dispose();
                      messageController.dispose();

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Global notification sent successfully!',
                            ),
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
                style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Send'),
              ),
            ],
          );
        },
      ),
    );
  }
}
