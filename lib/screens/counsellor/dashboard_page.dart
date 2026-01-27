import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/appointment_service.dart';
import '../../services/complaint_service.dart';
import '../../services/activity_service.dart';
import '../../models/complaint_model.dart';
import '../../models/appointment_slot_model.dart';
import '../../models/activity_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_widgets.dart';

class CounsellorDashboardPage extends StatefulWidget {
  const CounsellorDashboardPage({super.key});

  @override
  State<CounsellorDashboardPage> createState() =>
      _CounsellorDashboardPageState();
}

class _CounsellorDashboardPageState extends State<CounsellorDashboardPage> {
  final ComplaintService _complaintService = ComplaintService();
  final AppointmentService _appointmentService = AppointmentService();

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
                child: _buildActivitySection(context),
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
                    Icons.psychology_rounded,
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
                        'Student Counsellor',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Consumer<AppState>(
                        builder: (context, appState, _) {
                          final userName =
                              appState.currentUser?.name ?? 'Counsellor';
                          return Text(
                            userName,
                            style: Theme.of(context).textTheme.headlineSmall
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
              'Providing empathy and guidance to students in need. Monitor your appointments and assigned cases.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    final user = Provider.of<AppState>(context, listen: false).currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getAssignedComplaints(user.uid),
      builder: (context, complaintSnapshot) {
        return StreamBuilder<List<AppointmentSlotModel>>(
          stream: _appointmentService.getCounselorSlots(user.uid),
          builder: (context, slotSnapshot) {
            final complaints = complaintSnapshot.data ?? [];
            final slots = slotSnapshot.data ?? [];

            final stats = [
              {
                'label': 'Active Cases',
                'value':
                    '${complaints.where((c) => c.status != 'Resolved').length}',
                'icon': Icons.assignment_ind_rounded,
                'color': Colors.blue,
              },
              {
                'label': 'Pending Sessions',
                'value': '${slots.where((s) => s.status == 'booked').length}',
                'icon': Icons.calendar_today_rounded,
                'color': Colors.orange,
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
              count: int.tryParse(value.replaceAll('%', '')) ?? 0,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
              suffix: value.contains('%') ? '%' : '',
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
        'icon': Icons.groups_rounded,
        'title': 'My Cases',
        'color': Colors.blue,
        'target': 1,
      },
      {
        'icon': Icons.schedule_rounded,
        'title': 'Schedule',
        'color': Colors.orange,
        'target': 2,
      },
      {
        'icon': Icons.forum_rounded,
        'title': 'Messages',
        'color': Colors.green,
        'target': 3,
      },
      {
        'icon': Icons.assessment_rounded,
        'title': 'Log Progress',
        'color': Colors.purple,
        'target': 5,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Therapeutic Tools',
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
              action['target'] as int,
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
    int targetIndex,
  ) {
    return AnimatedWidgets.scaleButton(
      onPressed: () => Provider.of<AppState>(
        context,
        listen: false,
      ).setNavIndex(targetIndex),
      child: AnimatedWidgets.hoverCard(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)],
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

  Widget _buildActivitySection(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;
    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Interactions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            if (user.role == 'counsellor') // Check just in case
            IconButton(
              icon: const Icon(Icons.refresh),
               onPressed: () {
                 setState(() {});
               },
            )
          ],
        ),
        const SizedBox(height: 20),
        StreamBuilder<List<ActivityModel>>(
          stream: ActivityService().getUserActivities(user.uid, limit: 5),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final activities = snapshot.data ?? [];
            if (activities.isEmpty) {
              return Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No recent interactions',
                      style: TextStyle( color: Theme.of(context).disabledColor),
                    ),
                  ),
                ),
              );
            }

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  IconData icon;
                  Color color;
                  
                  switch (activity.type) {
                    case 'complaint':
                      icon = Icons.assignment_rounded;
                      color = Colors.blue;
                      break;
                    case 'appointment':
                      icon = Icons.event_rounded;
                      color = Colors.orange;
                      break;
                    default:
                      icon = Icons.notifications_rounded;
                      color = Colors.purple;
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      activity.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(activity.description),
                    trailing: Text(
                      _formatDate(activity.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).hintColor,
                      ),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }

}
