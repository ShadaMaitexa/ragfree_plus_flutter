import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ApprovalPendingScreen extends StatefulWidget {
  const ApprovalPendingScreen({super.key});

  @override
  State<ApprovalPendingScreen> createState() => _ApprovalPendingScreenState();
}

class _ApprovalPendingScreenState extends State<ApprovalPendingScreen> {
  final AuthService _authService = AuthService();
  bool _isChecking = true;
  bool _isApproved = false;

  @override
  void initState() {
    super.initState();
    _checkApprovalStatus();
  }

  Future<void> _checkApprovalStatus() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (userData != null && userData.isApproved) {
        setState(() {
          _isApproved = true;
          _isChecking = false;
        });
        // Navigate to dashboard after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _navigateToDashboard(userData.role);
          }
        });
      } else {
        setState(() {
          _isApproved = false;
          _isChecking = false;
        });
      }
    } else {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _navigateToDashboard(String role) {
    switch (role) {
      case 'student':
        Navigator.pushReplacementNamed(context, '/student');
        break;
      case 'parent':
        Navigator.pushReplacementNamed(context, '/parent');
        break;
      case 'counsellor':
        Navigator.pushReplacementNamed(context, '/counsellor');
        break;
      case 'warden':
        Navigator.pushReplacementNamed(context, '/warden');
        break;
      case 'police':
        Navigator.pushReplacementNamed(context, '/police');
        break;
      case 'teacher':
        Navigator.pushReplacementNamed(context, '/teacher');
        break;
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [color.withOpacity(0.1), Colors.transparent]
                : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isChecking)
                    Column(
                      children: [
                        CircularProgressIndicator(color: color),
                        const SizedBox(height: 24),
                        Text(
                          'Checking approval status...',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    )
                  else if (_isApproved)
                    Column(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Approved!',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Redirecting to dashboard...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Icon(
                          Icons.pending_actions,
                          size: 80,
                          color: color,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Approval Pending',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your registration is pending admin approval.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You will be able to access your dashboard once an administrator approves your account.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        FilledButton.icon(
                          onPressed: _checkApprovalStatus,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Check Status'),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _signOut,
                          child: const Text('Sign Out'),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

