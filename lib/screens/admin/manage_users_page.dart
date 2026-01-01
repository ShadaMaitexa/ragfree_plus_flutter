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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!user.isApproved) ...[
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Approve',
                onPressed: () => _approveUser(context, user, _authService),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                tooltip: 'Reject',
                onPressed: () => _rejectUser(context, user, _authService),
              ),
            ],
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: 'View Details',
              onPressed: () => _viewUserDetails(context, user),
            ),
          ],
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

  Future<void> _approveUser(
      BuildContext context, UserModel user, AuthService service) async {
    try {
      await service.approveUser(user.uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectUser(
      BuildContext context, UserModel user, AuthService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject User'),
        content: Text(
            'Are you sure you want to reject and delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.rejectUser(user.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.name} rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
      builder: (_) => AlertDialog(
        title: const Text('Add New User'),
        content: const Text(
          'To add a new user, please ask them to register via the mobile app registration screen.\n\nOnce they register, their account will appear in the "Pending" tab for your approval.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
