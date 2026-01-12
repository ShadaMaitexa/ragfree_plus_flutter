import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../widgets/animated_widgets.dart';
import '../../utils/responsive.dart';

class AdminManageUsersPage extends StatefulWidget {
  const AdminManageUsersPage({super.key});

  @override
  State<AdminManageUsersPage> createState() => _AdminManageUsersPageState();
}

class _AdminManageUsersPageState extends State<AdminManageUsersPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        child: Column(
          children: [
            AnimatedWidgets.slideIn(
              beginOffset: const Offset(0, -0.2),
              child: _buildHeader(context, color),
            ),
            const SizedBox(height: 8),
            _buildTabBar(context, color),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildUserListStream(_authService.getPendingApprovals(), 'No pending approvals'),
                  _buildUserListStream(_authService.getUsersByRole('student'), 'No students found'),
                  _buildUserListStream(_authService.getUsersByRole('parent'), 'No parents found'),
                  _buildUserListStream(_authService.getUsersByRole('teacher'), 'No teachers found'),
                  _buildUserListStream(_authService.getUsersByRole('counsellor'), 'No counsellors found'),
                  _buildUserListStream(_authService.getUsersByRole('warden'), 'No wardens found'),
                  _buildUserListStream(_authService.getUsersByRole('police'), 'No police officers found'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.people_alt_rounded, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('User Directory', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
                Text('Monitor and manage community access', style: TextStyle(color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          AnimatedWidgets.scaleButton(
            onPressed: () => _showAddUserDialog(context),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: FilledButton.icon(
                onPressed: () => _showAddUserDialog(context),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                icon: const Icon(Icons.add_rounded),
                label: const Text('New User', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color),
        labelColor: Colors.white,
        unselectedLabelColor: color.withOpacity(0.6),
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Students'),
          Tab(text: 'Parents'),
          Tab(text: 'Teachers'),
          Tab(text: 'Counsellors'),
          Tab(text: 'Wardens'),
          Tab(text: 'Police'),
        ],
      ),
    );
  }

  Widget _buildUserListStream(Stream<List<UserModel>> stream, String emptyMessage) {
    return StreamBuilder<List<UserModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data ?? [];
        if (users.isEmpty) return _buildEmptyState(context, Icons.person_search_rounded, emptyMessage);

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          itemCount: users.length,
          itemBuilder: (context, index) => AnimatedWidgets.slideIn(
            beginOffset: const Offset(0, 0.1),
            delay: Duration(milliseconds: index * 50),
            child: _buildUserCard(context, users[index]),
          ),
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    final color = Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: color.withOpacity(0.1))),
      child: InkWell(
        onTap: () => _viewUserDetails(context, user),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Icon(_getRoleIcon(user.role), color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(user.email, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
                  ],
                ),
              ),
              _buildActionButtons(context, user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserModel user) {
    if (user.isApproved) return const Icon(Icons.chevron_right_rounded, color: Colors.grey);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
          onPressed: () => _approveUser(context, user, _authService),
          tooltip: 'Approve',
        ),
        IconButton(
          icon: const Icon(Icons.cancel_rounded, color: Colors.red),
          onPressed: () => _rejectUser(context, user, _authService),
          tooltip: 'Reject',
        ),
      ],
    );
  }

  IconData _getRoleIcon(String role) {
    final icons = {
      'student': Icons.school_rounded,
      'parent': Icons.family_restroom_rounded,
      'teacher': Icons.person_rounded,
      'counsellor': Icons.psychology_rounded,
      'warden': Icons.security_rounded,
      'police': Icons.local_police_rounded,
    };
    return icons[role] ?? Icons.person_outline_rounded;
  }

  Widget _buildEmptyState(BuildContext context, IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).hintColor.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _viewUserDetails(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserDetailSheet(user: user, authService: _authService, roleIcon: _getRoleIcon(user.role)),
    );
  }

  Future<void> _approveUser(BuildContext context, UserModel user, AuthService service) async {
    try {
      await service.approveUser(user.uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${user.name} approved successfully'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _rejectUser(BuildContext context, UserModel user, AuthService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reject Application', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to reject and delete ${user.name}\'s access request? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pop(context, true), child: const Text('Reject & Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await service.rejectUser(user.uid);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${user.name}\'s request has been rejected'), backgroundColor: Colors.orange));
        }
      } catch (e) {
         if (context.mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
         }
      }
    }
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Onboard New User', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        content: const Text(
          'To maintain security, new users should register via the official app registration screen.\n\nOnce they submit their details and ID proof, their account will appear here for your verification and approval.',
          style: TextStyle(height: 1.5),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () => Navigator.pop(context),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }
}

class _UserDetailSheet extends StatelessWidget {
  final UserModel user;
  final AuthService authService;
  final IconData roleIcon;

  const _UserDetailSheet({required this.user, required this.authService, required this.roleIcon});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 40, spreadRadius: 10)],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 32),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(24)),
                  child: Icon(roleIcon, size: 40, color: color),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(user.role.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _buildDetailSection(context, 'Basic Information', [
              {'icon': Icons.email_rounded, 'label': 'Email Address', 'value': user.email},
              {'icon': Icons.phone_rounded, 'label': 'Contact Number', 'value': user.phone ?? 'Not provided'},
              {'icon': Icons.apartment_rounded, 'label': 'Assigned Department', 'value': user.department ?? 'Common'},
            ]),
            const SizedBox(height: 32),
            if (user.idProofUrl != null) ...[
              const Text('Identity Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(user.idProofUrl!, height: 220, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey.withOpacity(0.1), child: const Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey))),
              ),
              const SizedBox(height: 40),
            ],
            if (user.role != 'admin' || (user.uid == authService.currentUser?.uid))
              SizedBox(
                width: double.infinity,
                child: AnimatedWidgets.scaleButton(
                  onPressed: () => _handleDelete(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.delete_forever_rounded, color: Colors.red), SizedBox(width: 12), Text('Permanently Remove User', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w800))]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              Icon(item['icon'] as IconData, size: 20, color: Theme.of(context).hintColor),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['label'] as String, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600)),
                  Text(item['value'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          )),
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Security Verification', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Are you sure you want to permanently delete ${user.name}\'s profile and all associated data?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete Account')),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await authService.rejectUser(user.uid);
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User account purged successfully'), backgroundColor: Colors.red));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Critical Error: $e'), backgroundColor: Colors.red));
        }
      }
    }
  }
}
