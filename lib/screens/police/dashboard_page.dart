import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../../utils/responsive.dart';
import '../../widgets/animated_widgets.dart';

class PoliceDashboardPage extends StatefulWidget {
  const PoliceDashboardPage({super.key});

  @override
  State<PoliceDashboardPage> createState() => _PoliceDashboardPageState();
}

class _PoliceDashboardPageState extends State<PoliceDashboardPage> {
  final ComplaintService _complaintService = ComplaintService();

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
                child: _buildRecentComplaints(context),
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
                  child: const Icon(Icons.local_police_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Law Enforcement Office', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
                      Consumer<AppState>(
                        builder: (context, appState, _) {
                          final userName = appState.currentUser?.name ?? 'Officer';
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
              'Rapid response and campus security management. Monitor high-priority cases and critical alerts.',
              style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getAllComplaints(),
      builder: (context, snapshot) {
        final complaints = snapshot.data ?? [];
        final stats = [
          {'label': 'Investigations', 'value': '${complaints.length}', 'icon': Icons.folder_shared_rounded, 'color': Colors.blue},
          {'label': 'High Priority', 'value': '${complaints.where((c) => c.priority == 'High').length}', 'icon': Icons.priority_high_rounded, 'color': Colors.red},
          {'label': 'Pending', 'value': '${complaints.where((c) => c.status == 'Pending').length}', 'icon': Icons.hourglass_top_rounded, 'color': Colors.orange},
          {'label': 'Closed', 'value': '${complaints.where((c) => c.status == 'Resolved').length}', 'icon': Icons.verified_rounded, 'color': Colors.green},
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
              count: int.tryParse(value) ?? 0,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
            ),
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      {'icon': Icons.assignment_rounded, 'title': 'All Cases', 'color': Colors.blue, 'target': 1},
      {'icon': Icons.verified_user_rounded, 'title': 'Verifications', 'color': Colors.green, 'target': 2},
      {'icon': Icons.picture_as_pdf_rounded, 'title': 'Reports', 'color': Colors.purple, 'target': 3},
      {'icon': Icons.notification_important_rounded, 'title': 'Alerts', 'color': Colors.orange, 'target': 4},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Response Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
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
      onPressed: () => Provider.of<AppState>(context, listen: false).setNavIndex(targetIndex),
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

  Widget _buildRecentComplaints(BuildContext context, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Complaints',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Use drawer navigation
                Scaffold.of(context).openDrawer();
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ComplaintModel>>(
          stream: _complaintService.getAllComplaints(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final complaints = snapshot.data ?? [];
            final recentComplaints = complaints.take(5).toList();
            
            if (recentComplaints.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.assignment_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No Complaints Yet',
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: recentComplaints.map((complaint) {
                  return _buildComplaintListItem(context, complaint);
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildComplaintListItem(BuildContext context, ComplaintModel complaint) {
    Color statusColor;
    switch (complaint.status) {
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: statusColor.withOpacity(0.1),
        ),
        child: Icon(
          Icons.assignment,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Text(
        complaint.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        complaint.isAnonymous
            ? 'Anonymous'
            : (complaint.studentName ?? 'Unknown'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          complaint.status,
          style: TextStyle(
            color: statusColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      onTap: () {
        // Use drawer navigation
        Scaffold.of(context).openDrawer();
      },
    );
  }
}
