import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/appointment_service.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../../models/appointment_slot_model.dart';
import '../../utils/responsive.dart';
import 'schedule_session_page.dart';
import 'chat_page.dart';

class CounsellorDashboardPage extends StatefulWidget {
  const CounsellorDashboardPage({super.key});

  @override
  State<CounsellorDashboardPage> createState() =>
      _CounsellorDashboardPageState();
}

class _CounsellorDashboardPageState extends State<CounsellorDashboardPage>
  final ComplaintService _complaintService = ComplaintService();
  final AppointmentService _appointmentService = AppointmentService();

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
                        maxWidth: Responsive.isDesktop(context) ? 1200 : double.infinity,
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
                          _buildRecentActivity(context),
                          const SizedBox(height: 24),
                          _buildCharts(context),
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
                  Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back, Counsellor!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Consumer<AppState>(
                      builder: (context, appState, _) {
                        final userName = appState.currentUser?.name ?? 'Counsellor';
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
            'Support students and help them navigate through challenges. Your guidance makes a difference.',
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

    if (user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Performance',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ComplaintModel>>(
          stream: _complaintService.getAssignedComplaints(user.uid),
          builder: (context, complaintSnapshot) {
            return StreamBuilder<List<AppointmentSlotModel>>(
              stream: _appointmentService.getCounselorSlots(user.uid),
              builder: (context, slotSnapshot) {
                final complaints = complaintSnapshot.data ?? [];
                final slots = slotSnapshot.data ?? [];

                final totalCases = complaints.length;
                final activeCases = complaints.where((c) => c.status != 'Resolved').length;
                final resolvedCases = complaints.where((c) => c.status == 'Resolved').length;
                final todaySessions = slots.where((s) => s.date.day == DateTime.now().day && s.status == 'booked').length;
                
                final stats = [
                  {
                    'label': 'Total Cases',
                    'value': totalCases.toString(),
                    'icon': Icons.assignment_outlined,
                    'color': Colors.indigo,
                    'change': '',
                    'changeColor': Colors.transparent,
                  },
                  {
                    'label': 'Active Cases',
                    'value': activeCases.toString(),
                    'icon': Icons.pending_actions,
                    'color': Colors.blue,
                    'change': '',
                    'changeColor': Colors.transparent,
                  },
                  {
                    'label': 'Resolved',
                    'value': resolvedCases.toString(),
                    'icon': Icons.check_circle,
                    'color': Colors.green,
                    'change': totalCases > 0 ? '${((resolvedCases / totalCases) * 100).toStringAsFixed(0)}%' : '0%',
                    'changeColor': Colors.green,
                  },
                  {
                    'label': 'Sessions Today',
                    'value': todaySessions.toString(),
                    'icon': Icons.event,
                    'color': Colors.orange,
                    'change': '',
                    'changeColor': Colors.transparent,
                  },
                ];

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = Responsive.isMobile(context) ? 2 : 4;
                    
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
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
                          stat['change'] as String,
                          stat['changeColor'] as Color,
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
    String change,
    Color changeColor,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
              padding: EdgeInsets.all(
                Responsive.isDesktop(context) ? 20 : 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          Responsive.isDesktop(context) ? 8 : 6,
                        ),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(0.1),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: Responsive.isDesktop(context) ? 20 : 18,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.isDesktop(context) ? 8 : 6,
                          vertical: Responsive.isDesktop(context) ? 4 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          change,
                          style: TextStyle(
                            color: changeColor,
                            fontWeight: FontWeight.w600,
                            fontSize: constraints.maxWidth > 600 ? 12 : 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: constraints.maxWidth > 600 ? 12 : 8),
                  Flexible(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      {
        'icon': Icons.assignment,
        'title': 'Assigned Cases',
        'subtitle': 'View your cases',
        'color': Colors.blue,
        'onTap': () => _navigateToCases(context),
      },
      {
        'icon': Icons.reply,
        'title': 'Respond',
        'subtitle': 'Reply to complaints',
        'color': Colors.green,
        'onTap': () => _navigateToRespond(context),
      },
      {
        'icon': Icons.event,
        'title': 'Schedule',
        'subtitle': 'Book sessions',
        'color': Colors.orange,
        'onTap': () => _navigateToSchedule(context),
      },
      {
        'icon': Icons.chat,
        'title': 'Chat',
        'subtitle': 'Student support',
        'color': Colors.purple,
        'onTap': () => _navigateToChat(context),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(
                        constraints.maxWidth > 600 ? 12 : 10,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.1),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: constraints.maxWidth > 600 ? 24 : 20,
                      ),
                    ),
                    SizedBox(height: constraints.maxWidth > 600 ? 8 : 6),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final activities = [
      {
        'icon': Icons.assignment,
        'title': 'New Case Assigned',
        'subtitle': 'Harassment case #C001 from Emma Johnson',
        'time': '2 hours ago',
        'color': Colors.blue,
      },
      {
        'icon': Icons.check_circle,
        'title': 'Case Resolved',
        'subtitle': 'Bullying case #C002 resolved successfully',
        'time': '4 hours ago',
        'color': Colors.green,
      },
      {
        'icon': Icons.event,
        'title': 'Session Scheduled',
        'subtitle': 'Counseling session with Alex Johnson',
        'time': '1 day ago',
        'color': Colors.orange,
      },
      {
        'icon': Icons.chat,
        'title': 'New Message',
        'subtitle': 'Message from student regarding case',
        'time': '2 days ago',
        'color': Colors.purple,
      },
    ];

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
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: activities.map((activity) {
              return _buildActivityItem(context, activity);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activity['color'].withOpacity(0.1),
        ),
        child: Icon(activity['icon'], color: activity['color'], size: 20),
      ),
      title: Text(
        activity['title'],
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(activity['subtitle']),
      trailing: Text(
        activity['time'],
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildCharts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Analytics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildChartCard(
                context,
                'Cases by Month',
                'Monthly case distribution',
                Icons.bar_chart,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildChartCard(
                context,
                'Resolution Rate',
                'Success rate by category',
                Icons.pie_chart,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                        ),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 32, color: color.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text(
                        'Chart Visualization',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: color.withOpacity(0.7),
                        ),
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

  void _navigateToCases(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to assigned cases...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _navigateToRespond(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigating to respond to complaints...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToSchedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CounsellorScheduleSessionPage(),
      ),
    );
  }

  void _navigateToChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CounsellorChatPage(),
      ),
    );
  }
}
