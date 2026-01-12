import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/complaint_service.dart';
import '../../services/notification_service.dart';
import '../../services/activity_service.dart';
import '../../models/activity_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_widgets.dart';

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
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [color.withOpacity(0.08), Colors.transparent, color.withOpacity(0.04)]
              : [Colors.white, color.withOpacity(0.02), color.withOpacity(0.05)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: Responsive.getPadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: _buildRecentNotifications(context),
              ),
              const SizedBox(height: 32),
              AnimatedWidgets.slideIn(
                beginOffset: const Offset(0, 0.2),
                delay: const Duration(milliseconds: 400),
                child: _buildRecentActivity(context),
              ),
            ],
          ),
        ),
      ),
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
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Campus Educator', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                      Consumer<AppState>(
                        builder: (context, appState, _) {
                          final userName = appState.currentUser?.name ?? 'Teacher';
                          return Text(
                            userName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
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
              'Supporting student wellbeing and maintaining campus safety. Monitor active reports and engage with students.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    return StreamBuilder<List<dynamic>>(
      stream: _complaintService.getAllComplaints().map((c) => [
            c.length,
            c.where((x) => x.status == 'Resolved').length,
            c.where((x) => x.status != 'Resolved').length,
          ]),
      builder: (context, snapshot) {
        final stats = [
          {'label': 'Case Reports', 'value': '${snapshot.data?[0] ?? 0}', 'icon': Icons.assignment_rounded, 'color': Colors.blue},
          {'label': 'Resolved', 'value': '${snapshot.data?[1] ?? 0}', 'icon': Icons.task_alt_rounded, 'color': Colors.green},
          {'label': 'Active Cases', 'value': '${snapshot.data?[2] ?? 0}', 'icon': Icons.warning_amber_rounded, 'color': Colors.orange},
          {'label': 'Integrity Index', 'value': '98%', 'icon': Icons.verified_rounded, 'color': Colors.purple},
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.getGridCrossAxisCount(context, mobile: 2, tablet: 4, desktop: 4),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.3,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(context, stat['icon'] as IconData, stat['label'] as String, stat['value'] as String, stat['color'] as Color);
          },
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label, String value, Color color) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: color.withOpacity(0.1))),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const Spacer(),
            AnimatedWidgets.counterText(
              count: int.tryParse(value.replaceAll('%', '')) ?? 0,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
              suffix: value.contains('%') ? '%' : '',
            ),
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      {'icon': Icons.assignment_rounded, 'title': 'Reports', 'color': Colors.blue, 'target': 1},
      {'icon': Icons.forum_rounded, 'title': 'Student Hub', 'color': Colors.green, 'target': 2},
      {'icon': Icons.tips_and_updates_rounded, 'title': 'Wellness', 'color': Colors.orange, 'target': 3},
      {'icon': Icons.notifications_active_rounded, 'title': 'Alerts', 'color': Colors.purple, 'target': 0},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Mentorship Tools', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.getGridCrossAxisCount(context, mobile: 2, tablet: 4, desktop: 4),
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
              action['target'] as int,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, Color color, int targetIndex) {
    return AnimatedWidgets.scaleButton(
      onPressed: () => DefaultTabController.of(context).animateTo(targetIndex),
      child: AnimatedWidgets.hoverCard(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 16),
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentNotifications(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Notifications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        StreamBuilder(
          stream: _notificationService.getUserNotifications(user.uid),
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
            final notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
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
                        Icon(Icons.notifications_none, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No Notifications',
                          style: Theme.of(context).textTheme.titleMedium,
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
                children: notifications.take(5).map((notification) {
                  return ListTile(
                    leading: Icon(Icons.notifications, color: Colors.blue),
                    title: Text(notification.title),
                    subtitle: Text(notification.message),
                    trailing: Text(
                      _getTimeAgo(notification.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ActivityModel>>(
          stream: _activityService.getUserActivities(user.uid, limit: 5),
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
                children: activities.map((activity) {
                  return ListTile(
                    leading: Icon(Icons.history, color: Colors.blue),
                    title: Text(activity.title),
                    subtitle: Text(activity.description),
                    trailing: Text(
                      _getTimeAgo(activity.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
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
}


