import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../services/auth_service.dart';
import '../../models/complaint_model.dart';
import '../../models/user_model.dart';
import '../../services/app_state.dart';
import 'package:provider/provider.dart';

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

    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getAllComplaints(),
      builder: (context, complaintsSnapshot) {
        return StreamBuilder<List<UserModel>>(
          stream: _authService.getAllUsers(),
          builder: (context, usersSnapshot) {
            final complaints = complaintsSnapshot.data ?? [];
            final users = usersSnapshot.data ?? [];

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
                            ? [
                                color.withValues(alpha: 0.05),
                                Colors.transparent,
                              ]
                            : [Colors.grey.shade50, Colors.white],
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildHeader(context, color, complaints),
                        _buildTabBar(context),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildOverviewTab(context, complaints, users),
                              _buildComplaintsTab(context, complaints),
                              _buildUsersTab(context, complaints, users),
                            ],
                          ),
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
  }

  Widget _buildHeader(
    BuildContext context,
    Color color,
    List<ComplaintModel> complaints,
  ) {
    final total = complaints.length;
    final resolved = complaints.where((c) => c.status == 'Resolved').length;

    // Calculate Response Time
    double avgResponseTime = 0;
    final resolvedComplaints = complaints
        .where((c) => c.status == 'Resolved' && c.updatedAt != null)
        .toList();
    if (resolvedComplaints.isNotEmpty) {
      final totalDiff = resolvedComplaints.fold<int>(
        0,
        (totalSum, c) =>
            totalSum + c.updatedAt!.difference(c.createdAt).inHours,
      );
      avgResponseTime = totalDiff / resolvedComplaints.length;
    }

    // Rough Change percentages (compare this month vs all time Avg or something)
    // For now, keep them or calculate if we have enough data.

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
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
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                    fontSize: isNarrow ? 20 : null,
                                  ),
                            ),
                            Text(
                              'Comprehensive insights and reports',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                    fontSize: isNarrow ? 12 : null,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (!isNarrow)
                        FilledButton.icon(
                          onPressed: () => Provider.of<AppState>(
                            context,
                            listen: false,
                          ).setNavIndex(6),
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('View Reports'),
                          style: FilledButton.styleFrom(backgroundColor: color),
                        ),
                    ],
                  ),
                  if (isNarrow) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Provider.of<AppState>(
                          context,
                          listen: false,
                        ).setNavIndex(6),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('View Reports'),
                        style: FilledButton.styleFrom(backgroundColor: color),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                return Column(
                  children: [
                    _buildStatCard(
                      context,
                      'Total Reports',
                      total.toString(),
                      Icons.assignment,
                      Colors.blue,
                      'Updated',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Resolved',
                            resolved.toString(),
                            Icons.check_circle,
                            Colors.green,
                            '${total > 0 ? (resolved / total * 100).toStringAsFixed(1) : 0}%',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Response Time',
                            '${avgResponseTime.toStringAsFixed(1)}h',
                            Icons.timer,
                            Colors.orange,
                            'Average',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Total Reports',
                      total.toString(),
                      Icons.assignment,
                      Colors.blue,
                      'Updated',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Resolved',
                      resolved.toString(),
                      Icons.check_circle,
                      Colors.green,
                      '${total > 0 ? (resolved / total * 100).toStringAsFixed(1) : 0}%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Response Time',
                      '${avgResponseTime.toStringAsFixed(1)}h',
                      Icons.timer,
                      Colors.orange,
                      'Average',
                    ),
                  ),
                ],
              );
            },
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
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

  Widget _buildOverviewTab(
    BuildContext context,
    List<ComplaintModel> complaints,
    List<UserModel> users,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartCard(
            context,
            'Complaints Trend',
            'Total complaints created each month',
            Icons.trending_up,
            Colors.blue,
            _calculateComplaintsTrend(complaints),
          ),
          const SizedBox(height: 20),
          _buildChartCard(
            context,
            'Resolution Rate',
            'Resolved complaints by category',
            Icons.pie_chart,
            Colors.green,
            _calculateResolutionRate(complaints),
          ),
          const SizedBox(height: 20),
          _buildChartCard(
            context,
            'User Distribution',
            'Distribution of users by role',
            Icons.people,
            Colors.orange,
            _calculateUserDistribution(users),
          ),
        ],
      ),
    );
  }

  Map<String, double> _calculateComplaintsTrend(
    List<ComplaintModel> complaints,
  ) {
    final months = <String, double>{};
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final monthDate = DateTime(now.year, now.month - i, 1);
      final monthName = _getMonthName(monthDate.month);
      final count = complaints
          .where(
            (c) =>
                c.createdAt.month == monthDate.month &&
                c.createdAt.year == monthDate.year,
          )
          .length;
      months[monthName] = count.toDouble();
    }
    return months;
  }

  Map<String, double> _calculateResolutionRate(
    List<ComplaintModel> complaints,
  ) {
    final categories = <String, double>{};
    for (var c in complaints) {
      if (c.status == 'Resolved') {
        categories[c.category] = (categories[c.category] ?? 0) + 1;
      }
    }
    return categories;
  }

  Map<String, double> _calculateUserDistribution(List<UserModel> users) {
    final roles = <String, double>{};
    for (var u in users) {
      roles[u.role] = (roles[u.role] ?? 0) + 1;
    }
    return roles;
  }

  String _getMonthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }

  Widget _buildComplaintsTab(
    BuildContext context,
    List<ComplaintModel> complaints,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildComplaintsStatsStatic(context, complaints),
          const SizedBox(height: 20),
          _buildComplaintsByCategoryStatic(context, complaints),
          const SizedBox(height: 20),
          _buildComplaintsByStatusStatic(context, complaints),
        ],
      ),
    );
  }

  Widget _buildUsersTab(
    BuildContext context,
    List<ComplaintModel> complaints,
    List<UserModel> users,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserStatsStatic(context, users),
          const SizedBox(height: 20),
          _buildUserActivityStatic(context, users),
          const SizedBox(height: 20),
          _buildUserEngagement(context, complaints, users),
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
    Map<String, double> data,
  ) {
    double maxValue = data.isNotEmpty
        ? data.values.reduce((a, b) => a > b ? a : b)
        : 1.0;
    if (maxValue == 0) maxValue = 1.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
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
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                height: 200,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: data.isEmpty
                    ? Center(
                        child: Text(
                          'No data distribution available',
                          style: TextStyle(color: color.withValues(alpha: 0.5)),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: data.entries.map((entry) {
                          final percentage = entry.value / maxValue;
                          return Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  height: 140 * percentage,
                                  decoration: BoxDecoration(
                                    color: color.withValues(
                                      alpha: 0.7 + (0.3 * percentage),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  entry.key,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  entry.value.toInt().toString(),
                                  style: TextStyle(fontSize: 10, color: color),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintsStatsStatic(
    BuildContext context,
    List<ComplaintModel> complaints,
  ) {
    final total = complaints.length;
    final resolved = complaints.where((c) => c.status == 'Resolved').length;
    final pending = complaints.where((c) => c.status == 'Pending').length;

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
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total',
                    total.toString(),
                    Colors.blue,
                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsByCategoryStatic(
    BuildContext context,
    List<ComplaintModel> complaints,
  ) {
    final categoryCounts = <String, int>{};
    final categoryColors = {
      'Harassment': Colors.red,
      'Bullying': Colors.orange,
      'Discrimination': Colors.purple,
      'Cyber Bullying': Colors.blue,
      'Other': Colors.grey,
    };

    for (var complaint in complaints) {
      final category = complaint.category.isEmpty
          ? 'Other'
          : complaint.category;
      categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
    }

    final categories =
        categoryCounts.entries.map((entry) {
            return {
              'name': entry.key,
              'count': entry.value,
              'color': categoryColors[entry.key] ?? Colors.grey,
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
              'Complaints by Category',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No complaints yet'),
                ),
              )
            else
              ...categories.map(
                (category) => _buildCategoryItem(context, category),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintsByStatusStatic(
    BuildContext context,
    List<ComplaintModel> complaints,
  ) {
    final statusCounts = <String, int>{};
    final statusColors = {
      'Resolved': Colors.green,
      'In Progress': Colors.blue,
      'Pending': Colors.orange,
    };

    for (var complaint in complaints) {
      statusCounts[complaint.status] =
          (statusCounts[complaint.status] ?? 0) + 1;
    }

    final statuses =
        statusCounts.entries.map((entry) {
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
            if (statuses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No complaints yet'),
                ),
              )
            else
              ...statuses.map((status) => _buildStatusItem(context, status)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStatsStatic(BuildContext context, List<UserModel> users) {
    final students = users.where((u) => u.role == 'student').length;
    final parents = users.where((u) => u.role == 'parent').length;
    final staff = users
        .where(
          (u) => ['teacher', 'counsellor', 'warden', 'police'].contains(u.role),
        )
        .length;

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
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Students',
                    students.toString(),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Parents',
                    parents.toString(),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Staff',
                    staff.toString(),
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserActivityStatic(BuildContext context, List<UserModel> users) {
    final totalUsers = users.length;
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final newRegistrations = users
        .where((u) => u.createdAt.isAfter(weekAgo))
        .length;

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
              Colors.blue,
            ),
            _buildActivityItem(
              context,
              'Total Users',
              totalUsers.toString(),
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserEngagement(
    BuildContext context,
    List<ComplaintModel> complaints,
    List<UserModel> users,
  ) {
    final totalUsers = users.length;
    final totalComplaints = complaints.length;
    final reportsPerUser = totalUsers > 0 ? totalComplaints / totalUsers : 0.0;

    final resolvedComplaints = complaints
        .where((c) => c.status == 'Resolved')
        .length;
    final responseRate = totalComplaints > 0
        ? (resolvedComplaints / totalComplaints) * 100
        : 0.0;

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
              'Active Users',
              totalUsers.toString(),
              Colors.blue,
            ),
            _buildEngagementItem(
              context,
              'Reports per User',
              reportsPerUser.toStringAsFixed(1),
              Colors.green,
            ),
            _buildEngagementItem(
              context,
              'Resolution Rate',
              '${responseRate.toStringAsFixed(1)}%',
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
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
}
