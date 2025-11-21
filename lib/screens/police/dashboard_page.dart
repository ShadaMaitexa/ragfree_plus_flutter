import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';

class PoliceDashboardPage extends StatefulWidget {
  const PoliceDashboardPage({super.key});

  @override
  State<PoliceDashboardPage> createState() => _PoliceDashboardPageState();
}

class _PoliceDashboardPageState extends State<PoliceDashboardPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ComplaintService _complaintService = ComplaintService();

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(context, color),
                    const SizedBox(height: 24),
                    _buildStatsGrid(context, color),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, color),
                    const SizedBox(height: 24),
                    _buildRecentComplaints(context, color),
                  ],
                ),
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
                child: const Icon(Icons.local_police, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome, Officer!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Consumer<AppState>(
                      builder: (context, appState, _) {
                        final userName = appState.currentUser?.name ?? 'Officer';
                        return Text(
                          userName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
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
          Text(
            'Monitor and manage ragging complaints. Your vigilance keeps our campus safe.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getAllComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final complaints = snapshot.data ?? [];
        final highPriority = complaints.where((c) => c.priority == 'High').length;
        final pending = complaints.where((c) => c.status == 'Pending').length;
        final resolved = complaints.where((c) => c.status == 'Resolved').length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complaint Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatCard(
                      context,
                      'Total',
                      '${complaints.length}',
                      Icons.assignment,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      context,
                      'High Priority',
                      '$highPriority',
                      Icons.priority_high,
                      Colors.red,
                    ),
                    _buildStatCard(
                      context,
                      'Pending',
                      '$pending',
                      Icons.pending,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      context,
                      'Resolved',
                      '$resolved',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
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
            final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildActionCard(
                  context,
                  Icons.assignment,
                  'View Complaints',
                  Colors.blue,
                  () {
                    // Use drawer navigation - show message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Use the drawer menu to navigate to Complaints'),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  Icons.verified_user,
                  'Verify Actions',
                  Colors.green,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Use the drawer menu to navigate to Verify'),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  Icons.picture_as_pdf,
                  'Generate Report',
                  Colors.purple,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Use the drawer menu to navigate to Generate Report'),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  Icons.notifications,
                  'Send Notification',
                  Colors.orange,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Use the drawer menu to navigate to Send Notification'),
                      ),
                    );
                  },
                ),
              ],
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
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.1),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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
