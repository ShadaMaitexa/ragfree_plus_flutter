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
      ),
    );
  }

  Widget _buildChildSafetySummary(BuildContext context, Color color) {
    final user = Provider.of<AppState>(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    return AnimatedWidgets.hoverCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            StreamBuilder<List<ParentStudentLinkModel>>(
              stream: _parentStudentService.getLinkedStudents(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                
                final linkedStudents = snapshot.data ?? [];
                
                if (linkedStudents.isEmpty) {
                  return Column(
                    children: [
                      Icon(Icons.link_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text('No Linked Students',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Link your child\'s account to monitor their safety.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: color),
                        const SizedBox(width: 8),
                        Text(
                          'Monitored Students',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...linkedStudents.map((link) => ListTile(
                      leading: CircleAvatar(
                        child: Text(link.studentName.isNotEmpty ? link.studentName[0] : 'S'),
                      ),
                      title: Text(link.studentName),
                      subtitle: Text(link.studentEmail),
                      trailing: IconButton(
                        icon: const Icon(Icons.link_off, color: Colors.red),
                        tooltip: 'Unlink',
                        onPressed: () => _unlinkStudent(context, link.id),
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
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

  Future<void> _unlinkStudent(BuildContext context, String linkId) async {
     try {
       await _parentStudentService.unlinkStudent(linkId);
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Student unlinked')),
         );
       }
     } catch (e) {
       if (context.mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
         );
       }
     }
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
        childAspectRatio: 1.5,
      ),
      itemBuilder: (_, i) => actions[i],
    );
  }

  Widget _action(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifications(BuildContext context) {
    // Basic placeholder for now, would be similar to AdminNotificationsPage
     return _emptyState(
      context,
      Icons.notifications_none,
      'No Notifications',
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ActivityModel>>(
          stream: _activityService.getUserActivities(user.uid, limit: 5),
          builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator());
             }
             final activities = snapshot.data ?? [];
             if (activities.isEmpty) {
               return _emptyState(context, Icons.history, 'No Recent Activity');
             }
             return Card(
               child: Column(
                 children: activities.map((activity) => ListTile(
                   leading: Icon(Icons.history, color: Colors.grey),
                   title: Text(activity.title),
                   subtitle: Text(activity.description),
                 )).toList(),
               ),
             );
          },
        ),
      ],
    );
  }

  Widget _emptyState(
      BuildContext context, IconData icon, String text) {
    return AnimatedWidgets.hoverCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              Text(text,
                  style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- ACTIONS --------------------

  void _navigateToReports() {
    DefaultTabController.of(context).animateTo(1);
    // Assuming Tab structure, but ParentDashboard uses PageView.
    // Since this is inside HomePage which is inside PageView, we'd need to access ParentDashboardState.
    // For now we just show a snackbar or TODO.
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Complaints tab below')));
  }
  void _navigateToChat() {
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Chat tab below')));
  }
  void _navigateToAwareness() {
     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select Awareness tab below')));
  }
  
  void _showEmergencyAlerts() {
    // Show dialog with active alerts
  }

  void _showLinkStudentDialog(BuildContext context) {
    final emailController = TextEditingController();
    final relationshipController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Link Student Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the email address registered by your child to link their account.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Student Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: relationshipController,
                decoration: const InputDecoration(
                  labelText: 'Relationship (e.g., Father, Mother)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.family_restroom),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (emailController.text.trim().isEmpty || relationshipController.text.trim().isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill all fields')),
                        );
                        return;
                      }

                      setState(() => isLoading = true);
                      try {
                        final user = Provider.of<AppState>(context, listen: false).currentUser;
                        if (user != null) {
                          await _parentStudentService.linkStudent(
                            parentId: user.uid,
                            parentName: user.name,
                            studentEmail: emailController.text.trim(),
                            relationship: relationshipController.text.trim(),
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Student linked successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                         if (context.mounted) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
                           );
                         }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Link Student'),
            ),
          ],
        ),
      ),
    );
  }
}
