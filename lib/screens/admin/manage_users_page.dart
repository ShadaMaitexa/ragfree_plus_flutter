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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: 6, vsync: this);

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
                      _buildPendingApprovalsTab(context),
                      _buildStudentsTab(context),
                      _buildParentsTab(context),
                      _buildTeachersTab(context),
                      _buildCounsellorsTab(context),
                      _buildWardensTab(context),
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
                child: Icon(Icons.people, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Management',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      'Manage students, parents, and staff accounts',
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
                onPressed: () => _showAddUserDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add User'),
                style: FilledButton.styleFrom(backgroundColor: color),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                                  final activeUsers = totalUsers; // All approved users are considered active
                                  
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          context,
                                          'Total Users',
                                          totalUsers.toString(),
                                          Icons.people,
                                          Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          context,
                                          'Active',
                                          activeUsers.toString(),
                                          Icons.check_circle,
                                          Colors.green,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: StreamBuilder<List<UserModel>>(
                                          stream: _authService.getPendingApprovals(),
                                          builder: (context, pendingSnapshot) {
                                            final pending = pendingSnapshot.data ?? [];
                                            return _buildStatCard(
                                              context,
                                              'Pending',
                                              pending.length.toString(),
                                              Icons.pending,
                                              Colors.orange,
                                            );
                                          },
                                        ),
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
                  );
                },
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
          Tab(text: 'Pending'),
          Tab(text: 'Students'),
          Tab(text: 'Parents'),
          Tab(text: 'Counsellors'),
          Tab(text: 'Wardens'),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsTab(BuildContext context) {
    final authService = AuthService();
    final color = Theme.of(context).colorScheme.primary;

    return StreamBuilder<List<UserModel>>(
      stream: authService.getPendingApprovals(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final pendingUsers = snapshot.data ?? [];

        if (pendingUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                const SizedBox(height: 16),
                Text(
                  'No Pending Approvals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'All users have been approved',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: pendingUsers.length,
          itemBuilder: (context, index) {
            final user = pendingUsers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withOpacity(0.1),
                  child: Icon(_getRoleIcon(user.role), color: color),
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _getRoleColor(user.role),
                            ),
                          ),
                        ),
                        if (user.department != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            user.department!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blue),
                      onPressed: () => _viewUserDetails(context, user),
                      tooltip: 'View Details & ID Proof',
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () => _approveUser(context, user, authService),
                      tooltip: 'Approve',
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => _rejectUser(context, user, authService),
                      tooltip: 'Reject',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _viewUserDetails(BuildContext context, UserModel user) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getRoleIcon(user.role),
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Role', user.role.toUpperCase()),
                      if (user.phone != null) _buildDetailRow('Phone', user.phone!),
                      if (user.department != null)
                        _buildDetailRow('Department', user.department!),
                      _buildDetailRow(
                        'Status',
                        user.isApproved ? 'Approved' : 'Pending Approval',
                      ),
                      _buildDetailRow(
                        'Registered',
                        _formatDate(user.createdAt),
                      ),
                      const SizedBox(height: 24),
                      // ID Proof Section
                      if (user.idProofUrl != null) ...[
                        Text(
                          'ID Proof Document',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => _showFullScreenImage(context, user.idProofUrl!),
                          child: Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                user.idProofUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.broken_image, size: 48),
                                        SizedBox(height: 8),
                                        Text('Failed to load image'),
                                      ],
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () => _showFullScreenImage(context, user.idProofUrl!),
                          icon: const Icon(Icons.fullscreen),
                          label: const Text('View Full Screen'),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning, color: Colors.orange),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'No ID proof document uploaded',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    if (!user.isApproved) ...[
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _approveUser(context, user, null);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve'),
                        style: FilledButton.styleFrom(backgroundColor: Colors.green),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectUser(context, user, null);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Reject'),
                        style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'student':
        return Icons.school;
      case 'parent':
        return Icons.family_restroom;
      case 'police':
        return Icons.local_police;
      case 'counsellor':
        return Icons.psychology;
      case 'warden':
        return Icons.security;
      case 'teacher':
        return Icons.person_outline;
      default:
        return Icons.person;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'student':
        return Colors.blue;
      case 'parent':
        return Colors.green;
      case 'police':
        return Colors.blue.shade700;
      case 'counsellor':
        return Colors.purple;
      case 'warden':
        return Colors.orange;
      case 'teacher':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Future<void> _approveUser(
    BuildContext context,
    UserModel user,
    AuthService? authService,
  ) async {
    final service = authService ?? AuthService();
    try {
      await service.approveUser(user.uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} has been approved'),
            backgroundColor: Colors.green,
          ),
        );
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
    }
  }

  Future<void> _rejectUser(
    BuildContext context,
    UserModel user,
    AuthService? authService,
  ) async {
    final service = authService ?? AuthService();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject User'),
        content: Text(
          'Are you sure you want to reject ${user.name}? This will delete their account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
              content: Text('${user.name} has been rejected'),
              backgroundColor: Colors.orange,
            ),
          );
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
      }
    }
  }

  Widget _buildStudentsTab(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder<List<UserModel>>(
      stream: authService.getUsersByRole('student'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final students = snapshot.data ?? [];
        if (students.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Students Yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final student = students[index];
            return _buildUserCardFromModel(context, student);
          },
        );
      },
    );
  }

  Widget _buildParentsTab(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder<List<UserModel>>(
      stream: authService.getUsersByRole('parent'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final parents = snapshot.data ?? [];
        if (parents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.family_restroom, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Parents Yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: parents.length,
          itemBuilder: (context, index) {
            final parent = parents[index];
            return _buildUserCardFromModel(context, parent);
          },
        );
      },
    );
  }

  Widget _buildTeachersTab(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder<List<UserModel>>(
      stream: authService.getUsersByRole('teacher'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final teachers = snapshot.data ?? [];
        if (teachers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Teachers Yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: teachers.length,
          itemBuilder: (context, index) {
            final teacher = teachers[index];
            return _buildUserCardFromModel(context, teacher);
          },
        );
      },
    );
  }

  Widget _buildCounsellorsTab(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder<List<UserModel>>(
      stream: authService.getUsersByRole('counsellor'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final counsellors = snapshot.data ?? [];
        if (counsellors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.psychology, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Counsellors Yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: counsellors.length,
          itemBuilder: (context, index) {
            final counsellor = counsellors[index];
            return _buildUserCardFromModel(context, counsellor);
          },
        );
      },
    );
  }

  Widget _buildWardensTab(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder<List<UserModel>>(
      stream: authService.getUsersByRole('warden'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final wardens = snapshot.data ?? [];
        if (wardens.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Wardens Yet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add wardens to manage hostel and student affairs',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: wardens.length,
          itemBuilder: (context, index) {
            final warden = wardens[index];
            return _buildUserCardFromModel(context, warden);
          },
        );
      },
    );
  }

  Widget _buildUserCardFromModel(BuildContext context, UserModel user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _viewUserDetails(context, user),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      child: Icon(
                        _getRoleIcon(user.role),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.7),
                                ),
                          ),
                          if (user.department != null)
                            Text(
                              user.department!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'Approved',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewUserDetails(context, user),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View Details'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'User Type',
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'student', child: Text('Student')),
                DropdownMenuItem(value: 'parent', child: Text('Parent')),
                DropdownMenuItem(
                  value: 'counsellor',
                  child: Text('Counsellor'),
                ),
                DropdownMenuItem(value: 'warden', child: Text('Warden')),
              ],
              onChanged: (value) {
                // Handle user type selection
              },
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
                  content: Text('User added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  void _editUser(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${user['name']}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
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
                const SnackBar(content: Text('User updated successfully!')),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(BuildContext context, Map<String, dynamic> user) {
    final newStatus = user['status'] == 'Active' ? 'Inactive' : 'Active';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${user['status'] == 'Active' ? 'Suspend' : 'Activate'} User',
        ),
        content: Text(
          'Are you sure you want to ${user['status'] == 'Active' ? 'suspend' : 'activate'} ${user['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                user['status'] = newStatus;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'User ${newStatus.toLowerCase()} successfully!',
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(user['status'] == 'Active' ? 'Suspend' : 'Activate'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context, UserModel user) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to delete ${user.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _authService.rejectUser(user.uid);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User deleted successfully!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting user: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
