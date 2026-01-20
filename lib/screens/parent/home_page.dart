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

class _ParentHomePageState extends State<ParentHomePage> {
  final ParentStudentService _parentStudentService = ParentStudentService();
  final NotificationService _notificationService = NotificationService();
  final ActivityService _activityService = ActivityService();
  final ComplaintService _complaintService = ComplaintService();
  final EmergencyAlertService _emergencyAlertService = EmergencyAlertService();

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
                child: _buildChildSafetySummary(context, color),
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
                  child: const Icon(Icons.family_restroom_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Guardian Dashboard', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                      Consumer<AppState>(
                        builder: (context, appState, _) {
                          final userName = appState.currentUser?.name ?? 'Guardian';
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
              'Your child\'s safety is our priority. Monitor real-time activities and receive instant alerts.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildSafetySummary(BuildContext context, Color color) {
    final user = Provider.of<AppState>(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Monitored Students', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        StreamBuilder<List<ParentStudentLinkModel>>(
          stream: _parentStudentService.getLinkedStudents(user.uid),
          builder: (context, snapshot) {
            final linkedStudents = snapshot.data ?? [];
            
            if (linkedStudents.isEmpty) {
              return _buildEmptyState(context, Icons.link_off_rounded, 'No linked accounts found. Connect with your child to start monitoring.');
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: Responsive.getGridCrossAxisCount(context, mobile: 1, tablet: 2, desktop: 2),
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                mainAxisExtent: 100,
              ),
              itemCount: linkedStudents.length,
              itemBuilder: (context, index) {
                final link = linkedStudents[index];
                return _buildStudentLinkCard(context, link, color);
              },
            );
          },
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: AnimatedWidgets.scaleButton(
            onPressed: () => _showLinkStudentDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: color.withOpacity(0.3), width: 2),
                borderRadius: BorderRadius.circular(16),
                color: color.withOpacity(0.05),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_link_rounded, color: color),
                  const SizedBox(width: 12),
                  Text('Link Student Account', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentLinkCard(BuildContext context, ParentStudentLinkModel link, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: color.withOpacity(0.1))),
      child: Center(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.person_rounded, color: color),
          ),
          title: Text(link.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(link.studentEmail),
          trailing: IconButton(
            icon: const Icon(Icons.link_off_rounded, color: Colors.grey),
            onPressed: () => _unlinkStudent(context, link.id),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      {'icon': Icons.assignment_rounded, 'title': 'Reports', 'color': Colors.blue, 'target': 1},
      {'icon': Icons.forum_rounded, 'title': 'Chat', 'color': Colors.green, 'target': 2},
      {'icon': Icons.school_rounded, 'title': 'Awareness', 'color': Colors.orange, 'target': 3},
      {'icon': Icons.admin_panel_settings_rounded, 'title': 'Child Profile', 'color': Colors.purple, 'target': 4},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Proactive Safety', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
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
            return AnimatedWidgets.scaleButton(
              onPressed: () => Provider.of<AppState>(context, listen: false).setNavIndex(action['target'] as int),
              child: AnimatedWidgets.hoverCard(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [(action['color'] as Color).withOpacity(0.15), (action['color'] as Color).withOpacity(0.05)],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: (action['color'] as Color).withOpacity(0.1)),
                        child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(action['title'] as String, style: TextStyle(fontWeight: FontWeight.w800, color: action['color'] as Color, fontSize: 13)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Safety Log', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        StreamBuilder<List<ActivityModel>>(
          stream: _activityService.getUserActivities(user.uid, limit: 5),
          builder: (context, snapshot) {
            final activities = snapshot.data ?? [];
            if (activities.isEmpty) return _buildEmptyState(context, Icons.history_rounded, 'No recent activity recorded.');

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_active_rounded, size: 18),
                    ),
                    title: Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(activity.description),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String text) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.2), width: 1.5, style: BorderStyle.solid)),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(icon, size: 48, color: Theme.of(context).hintColor.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text(text, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14, height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- ACTIONS --------------------

  Future<void> _unlinkStudent(BuildContext context, String linkId) async {
    try {
      await _parentStudentService.unlinkStudent(linkId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account unlinked successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  void _showLinkStudentDialog(BuildContext context) {
    final emailController = TextEditingController();
    final relationshipController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Link Child\'s Account', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your child\'s registered email to securely link their safety monitoring.', style: TextStyle(fontSize: 14, height: 1.4)),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Student Email',
                  prefixIcon: const Icon(Icons.email_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: relationshipController,
                decoration: InputDecoration(
                  labelText: 'Relationship (Parent/Guardian)',
                  prefixIcon: const Icon(Icons.family_restroom_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: isLoading
                  ? null
                  : () async {
                      if (emailController.text.trim().isEmpty || relationshipController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
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
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accounts linked! Monitoring started.'), backgroundColor: Colors.green));
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red));
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Link Account'),
            ),
          ],
        ),
      ),
    );
  }
}
