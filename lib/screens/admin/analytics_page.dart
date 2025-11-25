import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../services/auth_service.dart';
import '../../models/complaint_model.dart';
import '../../models/user_model.dart';

class AdminAnalyticsPage extends StatefulWidget {
  const AdminAnalyticsPage({super.key});

  @override
  State<AdminAnalyticsPage> createState() => _AdminAnalyticsPageState();
}

class _AdminAnalyticsPageState extends State<AdminAnalyticsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;
  final ComplaintService _complaintService = ComplaintService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
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
            child: Column(
              children: [
                _buildHeader(context, color),
                _buildTabBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(context),
                      _buildComplaintsTab(context),
                      _buildUsersTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.analytics, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analytics Dashboard',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      'Comprehensive insights and reports',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _exportReport(context),
                icon: const Icon(Icons.download),
                label: const Text('Export Report'),
                style: FilledButton.styleFrom(backgroundColor: color),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Reports',
                  '1,247',
                  Icons.assignment,
                  Colors.blue,
                  '+12%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Resolved',
                  '1,089',
                  Icons.check_circle,
                  Colors.green,
                  '+8%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Response Time',
                  '2.3h',
                  Icons.timer,
                  Colors.orange,
                  '-0.5h',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    String change,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              color: change.startsWith('+') ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Complaints'),
          Tab(text: 'Users'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartCard(
            context,
            'Complaints Trend',
            'Monthly complaint reports over the last 6 months',
            Icons.trending_up,
            Colors.blue,
          ),
          const SizedBox(height: 20),
          _buildChartCard(
            context,
            'Resolution Rate',
            'Percentage of complaints resolved by category',
            Icons.pie_chart,
            Colors.green,
          ),
          const SizedBox(height: 20),
          _buildChartCard(
            context,
            'Response Time',
            'Average response time by department',
            Icons.timer,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildComplaintsTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComplaintsStats(context),
          const SizedBox(height: 20),
          _buildComplaintsByCategory(context),
          const SizedBox(height: 20),
          _buildComplaintsByStatus(context),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserStats(context),
          const SizedBox(height: 20),
          _buildUserActivity(context),
          const SizedBox(height: 20),
          _buildUserEngagement(context),
        ],
      ),
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
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                        ),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
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
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 48,
                        color: color.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chart Visualization',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: color.withOpacity(0.7)),
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

  Widget _buildComplaintsStats(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complaints Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<ComplaintModel>>(
              stream: _complaintService.getAllComplaints(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final complaints = snapshot.data ?? [];
                final total = complaints.length;
                final resolved = complaints.where((c) => c.status == 'Resolved').length;
                final pending = complaints.where((c) => c.status == 'Pending').length;
                
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(context, 'Total', total.toString(), Colors.blue),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Resolved',
                        resolved.toString(),
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Pending',
                        pending.toString(),
                        Colors.orange,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsByCategory(BuildContext context) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getAllComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final complaints = snapshot.data ?? [];
        final categoryCounts = <String, int>{};
        final categoryColors = {
          'Harassment': Colors.red,
          'Bullying': Colors.orange,
          'Discrimination': Colors.purple,
          'Cyber Bullying': Colors.blue,
          'Other': Colors.grey,
        };
        
        for (var complaint in complaints) {
          final category = complaint.category.isEmpty ? 'Other' : complaint.category;
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        }
        
        final categories = categoryCounts.entries.map((entry) {
          return {
            'name': entry.key,
            'count': entry.value,
            'color': categoryColors[entry.key] ?? Colors.grey,
          };
        }).toList()
          ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
        
        if (categories.isEmpty) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complaints by Category',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Center(child: Text('No complaints yet')),
                ],
              ),
            ),
          );
        }

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complaints by Category',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ...categories.map(
                  (category) => _buildCategoryItem(context, category),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComplaintsByStatus(BuildContext context) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getAllComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final complaints = snapshot.data ?? [];
        final statusCounts = <String, int>{};
        final statusColors = {
          'Resolved': Colors.green,
          'In Progress': Colors.blue,
          'Pending': Colors.orange,
        };
        
        for (var complaint in complaints) {
          final status = complaint.status;
          statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        }
        
        final statuses = statusCounts.entries.map((entry) {
          return {
            'name': entry.key,
            'count': entry.value,
            'color': statusColors[entry.key] ?? Colors.grey,
          };
        }).toList()
          ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complaints by Status',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                statuses.isEmpty
                    ? const Center(child: Text('No complaints yet'))
                    : Column(
                        children: statuses.map((status) => _buildStatusItem(context, status)).toList(),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserStats(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Statistics',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<UserModel>>(
              stream: _authService.getUsersByRole('student'),
              builder: (context, studentsSnapshot) {
                return StreamBuilder<List<UserModel>>(
                  stream: _authService.getUsersByRole('parent'),
                  builder: (context, parentsSnapshot) {
                    return StreamBuilder<List<UserModel>>(
                      stream: _authService.getUsersByRole('teacher'),
                      builder: (context, teachersSnapshot) {
                        return StreamBuilder<List<UserModel>>(
                          stream: _authService.getUsersByRole('counsellor'),
                          builder: (context, counsellorsSnapshot) {
                            final students = studentsSnapshot.data ?? [];
                            final parents = parentsSnapshot.data ?? [];
                            final teachers = teachersSnapshot.data ?? [];
                            final counsellors = counsellorsSnapshot.data ?? [];
                            final staff = teachers.length + counsellors.length;
                            
                            return Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    context,
                                    'Students',
                                    students.length.toString(),
                                    Colors.blue,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatItem(
                                    context,
                                    'Parents',
                                    parents.length.toString(),
                                    Colors.green,
                                  ),
                                ),
                                Expanded(
                                  child: _buildStatItem(context, 'Staff', staff.toString(), Colors.orange),
                                ),
                              ],
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
        ),
      ),
    );
  }

  Widget _buildUserActivity(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: _authService.getUsersByRole('student'),
      builder: (context, studentsSnapshot) {
        return StreamBuilder<List<UserModel>>(
          stream: _authService.getUsersByRole('parent'),
          builder: (context, parentsSnapshot) {
            return StreamBuilder<List<UserModel>>(
              stream: _authService.getUsersByRole('teacher'),
              builder: (context, teachersSnapshot) {
                return StreamBuilder<List<UserModel>>(
                  stream: _authService.getUsersByRole('counsellor'),
                  builder: (context, counsellorsSnapshot) {
                    return StreamBuilder<List<UserModel>>(
                      stream: _authService.getUsersByRole('warden'),
                      builder: (context, wardensSnapshot) {
                        return StreamBuilder<List<UserModel>>(
                          stream: _authService.getUsersByRole('police'),
                          builder: (context, policeSnapshot) {
                            final students = studentsSnapshot.data ?? [];
                            final parents = parentsSnapshot.data ?? [];
                            final teachers = teachersSnapshot.data ?? [];
                            final counsellors = counsellorsSnapshot.data ?? [];
                            final wardens = wardensSnapshot.data ?? [];
                            final police = policeSnapshot.data ?? [];
                            
                            final totalUsers = students.length + parents.length + 
                                            teachers.length + counsellors.length + 
                                            wardens.length + police.length;
                            
                            // Count new registrations (created in last 7 days)
                            final now = DateTime.now();
                            final weekAgo = now.subtract(const Duration(days: 7));
                            final newRegistrations = [
                              ...students,
                              ...parents,
                              ...teachers,
                              ...counsellors,
                              ...wardens,
                              ...police,
                            ].where((user) {
                              return user.createdAt.isAfter(weekAgo);
                            }).length;
                            
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'User Activity',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 16),
                                    _buildActivityItem(
                                      context,
                                      'Active Users',
                                      totalUsers.toString(),
                                      Colors.green,
                                    ),
                                    _buildActivityItem(
                                      context, 
                                      'New Registrations (7 days)', 
                                      newRegistrations.toString(), 
                                      Colors.blue
                                    ),
                                    _buildActivityItem(
                                      context, 
                                      'Total Users', 
                                      totalUsers.toString(), 
                                      Colors.orange
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUserEngagement(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Engagement',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildEngagementItem(
              context,
              'Average Session Time',
              '12.5 min',
              Colors.blue,
            ),
            _buildEngagementItem(
              context,
              'Reports per User',
              '2.3',
              Colors.green,
            ),
            _buildEngagementItem(
              context,
              'Response Rate',
              '87.5%',
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category['color'],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(category['name'])),
          Text(
            category['count'].toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: category['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, Map<String, dynamic> status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: status['color'],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(status['name'])),
          Text(
            status['count'].toString(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: status['color'],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose report format:'),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title: Text('PDF Report'),
              subtitle: Text('Comprehensive analytics report'),
            ),
            ListTile(
              leading: Icon(Icons.table_chart),
              title: Text('Excel Spreadsheet'),
              subtitle: Text('Data tables and charts'),
            ),
            ListTile(
              leading: Icon(Icons.image),
              title: Text('Image Export'),
              subtitle: Text('Charts and visualizations'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report exported successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}
