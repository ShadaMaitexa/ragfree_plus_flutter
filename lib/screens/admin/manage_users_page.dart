import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class AdminManageUsersPage extends StatefulWidget {
  const AdminManageUsersPage({super.key});

  @override
  State<AdminManageUsersPage> createState() => _AdminManageUsersPageState();
}

class _AdminManageUsersPageState extends State<AdminManageUsersPage>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final TabController _tabController;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _tabController = TabController(length: 7, vsync: this);
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
                  _buildPendingApprovalsTab(context),
                  _buildRoleTab(context, 'student'),
                  _buildRoleTab(context, 'parent'),
                  _buildRoleTab(context, 'teacher'),
                  _buildRoleTab(context, 'counsellor'),
                  _buildRoleTab(context, 'warden'),
                  _buildRoleTab(context, 'police'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader(BuildContext context, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.people, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User Management',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Text('Manage students, parents and staff'),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () => _showAddUserDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  // ================= TAB BAR =================

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabs: const [
        Tab(text: 'Pending'),
        Tab(text: 'Students'),
        Tab(text: 'Parents'),
        Tab(text: 'Teachers'),
        Tab(text: 'Counsellors'),
        Tab(text: 'Wardens'),
        Tab(text: 'Police'),
      ],
    );
  }

  // ================= PENDING =================

  Widget _buildPendingApprovalsTab(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: _authService.getPendingApprovals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No Pending Approvals'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (_, i) => _buildUserCardFromModel(context, users[i]),
        );
      },
    );
  }

  // ================= ROLE TAB =================

  Widget _buildRoleTab(BuildContext context, String role) {
    return StreamBuilder<List<UserModel>>(
      stream: _authService.getUsersByRole(role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return Center(child: Text('No ${role}s yet'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (_, i) => _buildUserCardFromModel(context, users[i]),
        );
      },
    );
  }

  // ================= USER CARD =================

  Widget _buildUserCardFromModel(BuildContext context, UserModel user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_getRoleIcon(user.role)),
        ),
        title: Text(user.name),
        subtitle: Text(user.email),
        trailing: IconButton(
          icon: const Icon(Icons.visibility),
          onPressed: () => _viewUserDetails(context, user),
        ),
      ),
    );
  }

  // ================= HELPERS =================

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'student':
        return Icons.school;
      case 'parent':
        return Icons.family_restroom;
      case 'teacher':
        return Icons.person;
      case 'counsellor':
        return Icons.psychology;
      case 'warden':
        return Icons.security;
      case 'police':
        return Icons.local_police;
      default:
        return Icons.person_outline;
    }
  }

  // ================= ACTIONS =================

  void _approveUser(BuildContext context, UserModel user, AuthService service) {
    service.approveUser(user.uid);
  }

  void _rejectUser(BuildContext context, UserModel user, AuthService service) {
    service.rejectUser(user.uid);
  }

  void _viewUserDetails(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user.name),
        content: Text(user.email),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Add User'),
        content: Text('Add user form here'),
      ),
    );
  }
}
