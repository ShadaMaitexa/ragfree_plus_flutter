import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/app_state.dart';
import '../../services/parent_student_service.dart';
import '../../services/notification_service.dart';
import '../../services/activity_service.dart';
import '../../services/complaint_service.dart';
import '../../services/emergency_alert_service.dart';
import '../../models/parent_student_link_model.dart';
import '../../models/notification_model.dart';
import '../../models/activity_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_widgets.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ParentStudentService _parentStudentService = ParentStudentService();
  final NotificationService _notificationService = NotificationService();
  final ActivityService _activityService = ActivityService();
  final ComplaintService _complaintService = ComplaintService();
  final EmergencyAlertService _emergencyAlertService = EmergencyAlertService();

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
                          _buildChildSafetySummary(context, color),
                          const SizedBox(height: 24),
                          _buildQuickActions(context, color),
                          const SizedBox(height: 24),
                          _buildNotifications(context),
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
    return AnimatedWidgets.hoverCard(
      elevation: 12,
      hoverElevation: 20,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedWidgets.bounceIn(
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.family_restroom,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedWidgets.slideIn(
                        beginOffset: const Offset(0.2, 0),
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          'Welcome back!',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Consumer<AppState>(
                        builder: (context, appState, _) {
                          final userName = appState.currentUser?.name ?? 'User';
                          final userId = appState.currentUser?.uid ?? '';
                          return AnimatedWidgets.slideIn(
                            beginOffset: const Offset(0.2, 0),
                            delay: const Duration(milliseconds: 400),
                            child: Column(
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
                                if (userId.isNotEmpty)
                                  Text(
                                    'ID: $userId',
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                  ),
                              ],
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
            AnimatedWidgets.fadeIn(
              delay: const Duration(milliseconds: 500),
              child: Text(
                'Stay connected with your child\'s safety and wellbeing on campus.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildSafetySummary(BuildContext context, Color color) {
    return AnimatedWidgets.fadeIn(
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Child Safety Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                ),
              ),
              AnimatedWidgets.bounceIn(
                delay: const Duration(milliseconds: 800),
                child: AnimatedWidgets.scaleButton(
                  child: IconButton(
                    icon: Icon(Icons.add_circle, color: color, size: 28),
                    onPressed: () => _showLinkStudentDialog(context),
                    tooltip: 'Link Student',
                  ),
                  onPressed: () => _showLinkStudentDialog(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedWidgets.hoverCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AnimatedWidgets.bounceIn(
                    delay: const Duration(milliseconds: 1000),
                    child: Icon(
                      Icons.link_off,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedWidgets.slideIn(
                    beginOffset: const Offset(0, 0.2),
                    delay: const Duration(milliseconds: 1100),
                    child: Text(
                      'No Linked Students',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedWidgets.slideIn(
                    beginOffset: const Offset(0, 0.2),
                    delay: const Duration(milliseconds: 1200),
                    child: Text(
                      'Link your child\'s account to monitor their safety',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedWidgets.slideIn(
                    beginOffset: const Offset(0, 0.3),
                    delay: const Duration(milliseconds: 1300),
                    child: AnimatedWidgets.scaleButton(
                      child: FilledButton.icon(
                        onPressed: () => _showLinkStudentDialog(context),
                        icon: const Icon(Icons.link),
                        label: const Text('Link Student Account'),
                      ),
                      onPressed: () => _showLinkStudentDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      {
        'icon': Icons.assignment,
        'title': 'View Reports',
        'subtitle': 'Child Complaints',
        'color': Colors.blue,
        'onTap': () => _navigateToReports(context),
      },
      {
        'icon': Icons.chat,
        'title': 'Chat',
        'subtitle': 'With Counselors',
        'color': Colors.green,
        'onTap': () => _navigateToChat(context),
      },
      {
        'icon': Icons.school,
        'title': 'Awareness',
        'subtitle': 'Safety Tips',
        'color': Colors.orange,
        'onTap': () => _navigateToAwareness(context),
      },
      {
        'icon': Icons.notifications,
        'title': 'Alerts',
        'subtitle': 'Emergency',
        'color': Colors.red,
        'onTap': () => _showEmergencyAlerts(context),
      },
    ];

    return AnimatedWidgets.fadeIn(
      delay: const Duration(milliseconds: 1400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(-0.2, 0),
            delay: const Duration(milliseconds: 1500),
            child: Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
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
                  return AnimatedWidgets.slideIn(
                    beginOffset: const Offset(0, 0.2),
                    delay: Duration(milliseconds: 1600 + (index * 100)),
                    child: AnimatedWidgets.hoverCard(
                      child: _buildActionCard(
                        context,
                        action['icon'] as IconData,
                        action['title'] as String,
                        action['subtitle'] as String,
                        action['color'] as Color,
                        action['onTap'] as VoidCallback,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
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
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
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

  Widget _buildNotifications(BuildContext context) {
    return AnimatedWidgets.fadeIn(
      delay: const Duration(milliseconds: 2000),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(-0.2, 0),
            delay: const Duration(milliseconds: 2100),
            child: Text(
              'Recent Notifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedWidgets.hoverCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    AnimatedWidgets.bounceIn(
                      delay: const Duration(milliseconds: 2300),
                      child: Icon(
                        Icons.notifications_none,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.2),
                      delay: const Duration(milliseconds: 2400),
                      child: Text(
                        'No Notifications',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.2),
                      delay: const Duration(milliseconds: 2500),
                      child: Text(
                        'You\'ll see notifications here when there are updates',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return AnimatedWidgets.fadeIn(
      delay: const Duration(milliseconds: 2600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(-0.2, 0),
            delay: const Duration(milliseconds: 2700),
            child: Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedWidgets.hoverCard(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    AnimatedWidgets.bounceIn(
                      delay: const Duration(milliseconds: 2900),
                      child: Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.2),
                      delay: const Duration(milliseconds: 3000),
                      child: Text(
                        'No Recent Activity',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.2),
                      delay: const Duration(milliseconds: 3100),
                      child: Text(
                        'Your recent activities will appear here',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLinkStudentDialog(BuildContext context) async
