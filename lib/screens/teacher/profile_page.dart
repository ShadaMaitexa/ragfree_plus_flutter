import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditing = false;

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
    _loadUserData();
  }

  void _loadUserData() {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone ?? '';
      _departmentController.text = user.department ?? '';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        'department': _departmentController.text.trim().isEmpty
            ? null
            : _departmentController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update app state
      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        department: _departmentController.text.trim().isEmpty
            ? null
            : _departmentController.text.trim(),
      );
      appState.setUser(updatedUser);

      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                    _buildProfileHeader(context, color),
                    const SizedBox(height: 24),
                    _buildPersonalInfo(context),
                    const SizedBox(height: 24),
                    _buildActions(context, color),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, Color color) {
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
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person_outline, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Consumer<AppState>(
            builder: (context, appState, _) {
              final userName = appState.currentUser?.name ?? 'Teacher';
              return Text(
                userName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              );
            },
          ),
          const SizedBox(height: 4),
          Consumer<AppState>(
            builder: (context, appState, _) {
              final userEmail = appState.currentUser?.email ?? '';
              return Text(
                userEmail,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
              );
            },
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'TEACHER',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Personal Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(_isEditing ? Icons.close : Icons.edit),
                  onPressed: () {
                    setState(() => _isEditing = !_isEditing);
                    if (!_isEditing) {
                      _loadUserData(); // Reset changes
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              enabled: false, // Email cannot be changed
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              enabled: _isEditing,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _departmentController,
              decoration: const InputDecoration(
                labelText: 'Department',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
              enabled: _isEditing,
            ),
            if (_isEditing) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saveProfile,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await _authService.signOut();
              if (mounted) {
                Provider.of<AppState>(context, listen: false).clearUser();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}


