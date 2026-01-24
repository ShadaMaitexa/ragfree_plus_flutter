import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ragfree_plus_flutter/services/app_state.dart';
import 'package:ragfree_plus_flutter/services/complaint_service.dart';
import 'package:ragfree_plus_flutter/services/notification_service.dart';
import 'package:ragfree_plus_flutter/services/activity_service.dart';
import 'package:ragfree_plus_flutter/models/activity_model.dart';
import 'package:ragfree_plus_flutter/models/complaint_model.dart';
import 'package:ragfree_plus_flutter/utils/responsive.dart';
import 'package:ragfree_plus_flutter/widgets/animated_widgets.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  final ComplaintService _complaintService = ComplaintService();
  final NotificationService _notificationService = NotificationService();
  final ActivityService _activityService = ActivityService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;
    final color = Theme.of(context).primaryColor;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [color.withOpacity(0.08), Colors.transparent, color.withOpacity(0.04)]
                : [Colors.white, color.withOpacity(0.02), color.withOpacity(0.05)],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.isMobile(context) ? 16 : 32,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedWidgets.fadeDown(
                  child: _buildWelcomeCard(context, user, color),
                ),
                const SizedBox(height: 32),
                AnimatedWidgets.fadeUp(
                  delay: const Duration(milliseconds: 200),
                  child: _buildStatsGrid(context, color),
                ),
                const SizedBox(height: 32),
                AnimatedWidgets.fadeUp(
                  delay: const Duration(milliseconds: 400),
                  child: _buildRecentActivity(context, user?.uid ?? ''),
                ),
                const SizedBox(height: 32),
                AnimatedWidgets.fadeUp(
                  delay: const Duration(milliseconds: 600),
                  child: _buildNotifications(context, user?.uid ?? ''),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, dynamic user, Color color) {
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
            colors: [color, color.withOpacity(0.85)],
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
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(Icons.school, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                      Text(
                        user?.name ?? 'Teacher',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              user?.department != null 
                ? 'Department of ${user.department}'
                : 'Manage your students and assigned complaints',
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    final user = Provider.of<AppState>(context).currentUser;
    final institutionNormalized = user?.institutionNormalized ?? '';
    final department = user?.department ?? '';

    return StreamBuilder<List<ComplaintModel>>(
      stream: (department.isNotEmpty)
          ? _complaintService.getComplaintsByDepartment(
              institutionNormalized,
              department,
            )
          : _complaintService.getComplaintsByInstitution(institutionNormalized),
      builder: (context, snapshot) {
        final complaints = snapshot.data ?? [];
        final total = complaints.length;
        final resolved = complaints.where((x) => x.status == 'Resolved').length;
        final active = total - resolved;

        final stats = [
          {
            'label': department.isNotEmpty
                ? '$department Cases'
                : 'Case Reported',
            'value': '$total',
            'icon': Icons.assignment_rounded,
            'color': Colors.blue,
          },
          {
            'label': 'Resolved',
            'value': '$resolved',
            'icon': Icons.task_alt_rounded,
            'color': Colors.green,
          },
          {
            'label': 'Active Cases',
            'value': '$active',
            'icon': Icons.warning_amber_rounded,
            'color': Colors.orange,
          },
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isMobile(context) ? 1 : 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: Responsive.isMobile(context) ? 4 : 1.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            final statColor = stat['color'] as Color;
            
            return AnimatedWidgets.hoverCard(
              elevation: 0,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: statColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statColor.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: statColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat['label'] as String,
                            style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            stat['value'] as String,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: statColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                // Navigate to activity log
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ActivityModel>>(
          stream: _activityService.getUserActivities(userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final activities = snapshot.data!;
            if (activities.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.history, color: Theme.of(context).disabledColor, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No recent activity',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.2), indent: 72),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getActivityColor(
                          activity.type,
                        ).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getActivityIcon(activity.type),
                        color: _getActivityColor(activity.type),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      activity.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.description,
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(activity.timestamp),
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotifications(BuildContext context, String userId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Notifications',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (userId.isNotEmpty)
              StreamBuilder<int>(
                stream: _notificationService.getUnreadCount(userId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == 0)
                    return const SizedBox.shrink();
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${snapshot.data} New',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<dynamic>>( // List<NotificationModel> needs import, using dynamic to avoid import issues if not already imported or alias conflict
          stream: _notificationService.getUserNotifications(userId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final notifications = snapshot.data!;
            if (notifications.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.notifications_none,
                      color: Theme.of(context).disabledColor,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No new notifications',
                      style: TextStyle(color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.2), indent: 72),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  // If passing dynamic, we need to access fields carefully or cast
                  // assuming NotificationModel structure
                  return ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead
                            ? FontWeight.normal
                            : FontWeight.w700,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.message,
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(notification.createdAt.toDate()),
                          style: TextStyle(
                            color: Theme.of(context).hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                       _notificationService.markAsRead(notification.id);
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'complaint':
        return Icons.assignment_late_rounded;
      case 'chat':
        return Icons.chat_rounded;
      case 'appointment':
        return Icons.event_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'complaint':
        return Colors.red;
      case 'chat':
        return Colors.blue;
      case 'appointment':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
