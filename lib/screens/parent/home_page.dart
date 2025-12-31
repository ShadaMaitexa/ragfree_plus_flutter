// ignore_for_file: unused_import

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
  final EmergencyAlertService _emergencyAlertService =
      EmergencyAlertService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
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
      builder: (context, _) {
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
              child: SingleChildScrollView(
                padding: Responsive.getPadding(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth:
                        Responsive.isDesktop(context) ? 1200 : double.infinity,
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
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------- UI SECTIONS --------------------

  Widget _buildWelcomeCard(BuildContext context, Color color) {
    return AnimatedWidgets.hoverCard(
      elevation: 12,
      hoverElevation: 20,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Consumer<AppState>(
          builder: (context, appState, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  appState.currentUser?.name ?? 'User',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChildSafetySummary(BuildContext context, Color color) {
    return AnimatedWidgets.hoverCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.link_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text('No Linked Students',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _showLinkStudentDialog(context),
              icon: const Icon(Icons.link),
              label: const Text('Link Student Account'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      _action(Icons.assignment, 'View Reports', _navigateToReports),
      _action(Icons.chat, 'Chat', _navigateToChat),
      _action(Icons.school, 'Awareness', _navigateToAwareness),
      _action(Icons.notifications, 'Alerts', _showEmergencyAlerts),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Responsive.isDesktop(context) ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (_, i) => actions[i],
    );
  }

  Widget _action(IconData icon, String title, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotifications(BuildContext context) {
    return _emptyState(
      context,
      Icons.notifications_none,
      'No Notifications',
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return _emptyState(
      context,
      Icons.history,
      'No Recent Activity',
    );
  }

  Widget _emptyState(
      BuildContext context, IconData icon, String text) {
    return AnimatedWidgets.hoverCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(text,
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  // -------------------- ACTIONS --------------------

  void _navigateToReports() {}
  void _navigateToChat() {}
  void _navigateToAwareness() {}
  void _showEmergencyAlerts() {}

  void _showLinkStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Link Student'),
        content: Text('Student linking flow goes here'),
      ),
    );
  }
}
