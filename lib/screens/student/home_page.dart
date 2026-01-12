import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'book_appointment_page.dart';
import 'feedback_page.dart';
import '../../services/app_state.dart';
import '../../services/complaint_service.dart';
import '../../services/activity_service.dart';
import '../../services/emergency_alert_service.dart';
import '../../models/activity_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_widgets.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final ComplaintService _complaintService = ComplaintService();
  final ActivityService _activityService = ActivityService();
  final EmergencyAlertService _emergencyService = EmergencyAlertService();
  bool _isSendingSOS = false;

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
                child: _buildQuickActions(context, color),
              ),
              const SizedBox(height: 32),
              AnimatedWidgets.slideIn(
                beginOffset: const Offset(0, 0.2),
                delay: const Duration(milliseconds: 200),
                child: _buildStatsGrid(context, color),
              ),
              const SizedBox(height: 32),
              AnimatedWidgets.slideIn(
                beginOffset: const Offset(0, 0.2),
                delay: const Duration(milliseconds: 300),
                child: _buildRecentActivity(context),
              ),
              const SizedBox(height: 32),
              AnimatedWidgets.scaleButton(
                onPressed: () => _showSOSDialog(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.red, Colors.deepOrange]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emergency_share, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'EMERGENCY SOS',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, Color color) {
    return AnimatedWidgets.hoverCard(
      borderRadius: BorderRadius.circular(24),
      elevation: 8,
      hoverElevation: 12,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.stars_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Member of RagFree+',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.w500),
                      ),
                      Consumer<AppState>(
                        builder: (context, appState, _) {
                          final userName = appState.currentUser?.name ?? 'User';
                          return Text(
                            'Hello, $userName',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.notifications_active, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.white24),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security_update_good, color: Colors.white70, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your safety is our priority. Report any concern instantly.',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      {'icon': Icons.calendar_month_rounded, 'title': 'Counseling', 'color': Colors.indigo, 'onTap': () => _navigateToBooking(context)},
      {'icon': Icons.gavel_rounded, 'title': 'Report', 'color': Colors.deepOrange, 'onTap': () => _navigateToComplaints(context)},
      {'icon': Icons.forum_rounded, 'title': 'Live Support', 'color': Colors.blue, 'onTap': () => _navigateToChat(context)},
      {'icon': Icons.school_rounded, 'title': 'Awareness', 'color': Colors.green, 'onTap': () => _navigateToAwareness(context)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.getGridCrossAxisCount(context, mobile: 2, tablet: 4, desktop: 4),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
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
              index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, Color color, VoidCallback onTap, int index) {
    return AnimatedWidgets.scaleButton(
      onPressed: onTap,
      child: AnimatedWidgets.hoverCard(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<List<dynamic>>(
      stream: _complaintService.getStudentComplaints(user.uid).map((c) => [
            c.length,
            c.where((x) => x.status == 'Resolved').length,
            c.where((x) => x.status != 'Resolved').length,
          ]),
      builder: (context, snapshot) {
        final stats = [
          {'label': 'Total Reports', 'value': '${snapshot.data?[0] ?? 0}', 'icon': Icons.folder_rounded, 'color': Colors.blue},
          {'label': 'Resolved', 'value': '${snapshot.data?[1] ?? 0}', 'icon': Icons.verified_rounded, 'color': Colors.green},
          {'label': 'Active', 'value': '${snapshot.data?[2] ?? 0}', 'icon': Icons.hourglass_empty_rounded, 'color': Colors.orange},
          {'label': 'System Status', 'value': 'Online', 'icon': Icons.sensors_rounded, 'color': Colors.purple},
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.getGridCrossAxisCount(context, mobile: 2, tablet: 4, desktop: 4),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final user = context.read<AppState>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 16),
        StreamBuilder<List<ActivityModel>>(
          stream: _activityService.getUserActivities(user.uid, limit: 3),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ShimmerEffect(child: Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20))));
            }
            final activities = snapshot.data ?? [];
            if (activities.isEmpty) return _buildEmptyActivity();

            return Column(
              children: activities.map((a) => _buildActivityItemFromModel(context, a)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyActivity() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(Icons.history_rounded, size: 40, color: Theme.of(context).disabledColor),
          const SizedBox(height: 12),
          Text('No recent activity', style: TextStyle(color: Theme.of(context).disabledColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String time,
  ) {
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
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
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

  void _showSOSDialog(BuildContext context) {
    final messageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.emergency, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Emergency SOS'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will immediately alert campus security, emergency services, and your linked parents. Are you sure you want to proceed?',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Optional Message',
                  hintText: 'Brief description of emergency',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _isSendingSOS
                  ? null
                  : () {
                      Navigator.pop(context);
                    },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: _isSendingSOS
                  ? null
                  : () async {
                      setDialogState(() => _isSendingSOS = true);
                      try {
                        final appState =
                            Provider.of<AppState>(context, listen: false);
                        final user = appState.currentUser;

                        if (user != null) {
                          await _emergencyService.sendSOSAlert(
                            studentId: user.uid,
                            studentName: user.name,
                            message: messageController.text.trim().isEmpty
                                ? null
                                : messageController.text.trim(),
                          );

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Emergency alert sent! Help is on the way.'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 5),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isSendingSOS = false);
                        }
                      }
                    },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: _isSendingSOS
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Send SOS'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StudentBookAppointmentPage(),
      ),
    );
  }

  void _navigateToComplaints(BuildContext context) {
    Provider.of<AppState>(context, listen: false).setNavIndex(1);
  }

  void _navigateToChat(BuildContext context) {
    Provider.of<AppState>(context, listen: false).setNavIndex(2);
  }

  void _navigateToAwareness(BuildContext context) {
    Provider.of<AppState>(context, listen: false).setNavIndex(3);
  }

  void _navigateToFeedback(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StudentFeedbackPage()),
    );
  }
}
