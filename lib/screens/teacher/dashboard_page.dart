import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/complaint_service.dart';
import '../../services/notification_service.dart';
import '../../services/activity_service.dart';
import '../../models/activity_model.dart';
import '../../utils/responsive.dart';

class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ComplaintService _complaintService = ComplaintService();
  final NotificationService _notificationService = NotificationService();
  final ActivityService _activityService = ActivityService();

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
                        maxWidth: Responsive.isDesktop(context)
                            ? 1200
                            : double.infinity,
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
                          _buildRecentNotifications(context),
                          const SizedBox(height: 24),
                          _buildRecentActivity(context),
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
                  Icons.person_outline,
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
                      'Welcome back!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Consumer<AppState>(
                      builder: (context, appState, _) {
                        final userName = appState.currentUser?.name ?? 'Teacher';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${appState.currentUser?.uid ?? ""}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
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
            'Monitor student safety and support campus wellbeing.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    return StreamBuilder<List<dynamic>>(
      stream: user != null
          ? _complaintService.getAllComplaints().map((complaints) => [
                complaints.length,
                complaints.where((c) => c.status == 'Resolved').length,
                complaints.where((c) => c.status != 'Resolved').length,
              ])
          : Stream.value([0, 0, 0]),
      builder: (context, snapshot) {
        final total = snapshot.data?[0] ?? 0;
        final resolved = snapshot.data?[1] ?? 0;
        final active = snapshot.data?[2] ?? 0;

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = Responsive.getGridCrossAxisCount(
              context,
              mobile: 1,
              tablet: 2,
              desktop: 3,
            );
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(context, 'Total Complaints', '$total', Colors.blue,
                    Icons.assignment),
                _buildStatCard(context, 'Resolved', '$resolved', Colors.green,
                    Icons.check_circle),
                _buildStatCard(context, 'Active', '$active', Colors.orange,
                    Icons.pending),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      {
        'icon': Icons.assignment,
        'title': 'View Complaints',
        'subtitle': 'Student Reports',
        'color': Colors.blue,
        'onTap': () => DefaultTabController.of(context).animateTo(1),
      },
      {
        'icon': Icons.chat,
        'title': 'Chat',
        'subtitle': 'With Students',
        'color': Colors.green,
        'onTap': () => DefaultTabController.of(context).animateTo(2),
      },
      {
        'icon': Icons.school,
        'title': 'Awareness',
        'subtitle': 'Safety Tips',
        'color': Colors.orange,
        'onTap': () => DefaultTabController.of(context).animateTo(3),
      },
      {
        'icon': Icons.notifications,
        'title': 'Notifications',
        'subtitle': 'Updates',
        'color': Colors.purple,
        'onTap': () {},
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.1),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ),
                const SizedBox(height: 6),
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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


