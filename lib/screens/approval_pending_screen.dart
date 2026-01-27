import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/animated_widgets.dart';

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
    setState(() => _isChecking = true);
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getUserData(user.uid);
      if (userData != null && userData.isApproved) {
        setState(() {
          _isApproved = true;
          _isChecking = false;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          _navigateToDashboard(userData.role);
        });
      } else {
        setState(() {
          _isApproved = false;
          _isChecking = false;
        });
      }
    } else {
      setState(() => _isChecking = false);
    }
  }

  void _navigateToDashboard(String role) {
    final routes = {
      'student': '/student',
      'parent': '/parent',
      'counsellor': '/counsellor',
      'warden': '/warden',
      'police': '/police',
      'teacher': '/teacher',
    };
    if (routes.containsKey(role)) {
      Navigator.pushReplacementNamed(context, routes[role]!);
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
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
                ? [color.withValues(alpha: 0.12), Colors.black, color.withValues(alpha: 0.08)]
                : [color.withValues(alpha: 0.05), Colors.white, color.withValues(alpha: 0.1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _isChecking ? _buildChecking(color) : (_isApproved ? _buildApproved(color) : _buildPending(color)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecking(Color color) {
    return Column(
      key: const ValueKey('checking'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 60, height: 60, child: CircularProgressIndicator(strokeWidth: 6, color: color)),
        const SizedBox(height: 32),
        AnimatedWidgets.fadeIn(
          child: Text('Verifying Authorization...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
        ),
      ],
    );
  }

  Widget _buildApproved(Color color) {
    return Column(
      key: const ValueKey('approved'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedWidgets.bounceIn(
          child: const Icon(Icons.verified_rounded, size: 100, color: Colors.green),
        ),
        const SizedBox(height: 32),
        AnimatedWidgets.slideIn(
          beginOffset: const Offset(0, 0.2),
          child: const Text('Access Granted!', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.green)),
        ),
        const SizedBox(height: 12),
        AnimatedWidgets.fadeIn(
          delay: const Duration(milliseconds: 200),
          child: const Text('Your profile is approved. Redirecting now...', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildPending(Color color) {
    return Column(
      key: const ValueKey('pending'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedWidgets.bounceIn(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.shield_moon_rounded, size: 80, color: color),
          ),
        ),
        const SizedBox(height: 40),
        AnimatedWidgets.slideIn(
          beginOffset: const Offset(0, 0.2),
          child: Text('Approval Pending', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
        ),
        const SizedBox(height: 16),
        AnimatedWidgets.fadeIn(
          delay: const Duration(milliseconds: 200),
          child: const Text(
            'We are currently verifying your credentials. This process ensures the safety and integrity of our community.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          child: AnimatedWidgets.scaleButton(
            onPressed: _checkApprovalStatus,
            child: FilledButton.icon(
              onPressed: _checkApprovalStatus,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh Status', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _signOut,
          child: Text('Sign Out', style: TextStyle(color: Theme.of(context).hintColor)),
        ),
      ],
    );
  }
}

