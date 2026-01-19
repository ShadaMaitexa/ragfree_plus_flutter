import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/app_state.dart';
import '../models/user_model.dart';
import '../widgets/animated_widgets.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserModel? user;
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (email == 'admin@ragfree.com') {
        user = await _authService.adminLogin(email: email, password: password);
      } else {
        user = await _authService.loginWithEmailAndPassword(email: email, password: password);

        if (user != null && user.role != 'admin' && !user.isApproved) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Your account is pending admin approval'), backgroundColor: Colors.orange),
            );
            Navigator.pushReplacementNamed(context, '/approval-pending');
          }
          return;
        }
      }

      if (user != null && mounted) {
        context.read<AppState>().setUser(user);
        _navigateToDashboard(user.role);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToDashboard(String role) {
    final routes = {
      'student': '/student',
      'parent': '/parent',
      'admin': '/admin',
      'counsellor': '/counsellor',
      'warden': '/warden',
      'police': '/police',
      'teacher': '/teacher',
    };
    if (routes.containsKey(role)) {
      Navigator.pushReplacementNamed(context, routes[role]!);
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email to receive a secure password reset link.', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  hintText: 'user@example.com',
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !isSending,
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: isSending
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid email'), backgroundColor: Colors.red));
                        return;
                      }
                      setDialogState(() => isSending = true);
                      try {
                        await _authService.sendPasswordResetEmail(email);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link sent! Check your inbox.'), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                        }
                      }
                    },
              child: isSending
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
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
                ? [color.withOpacity(0.12), Colors.black, color.withOpacity(0.08)]
                : [color.withOpacity(0.05), Colors.white, color.withOpacity(0.1)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final formWidth = isWide ? 480.0 : double.infinity;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isWide ? 1000 : 450),
                    child: isWide
                        ? Row(
                            children: [
                              Expanded(flex: 1, child: _buildLoginHero(color, context)),
                              const SizedBox(width: 64),
                              Expanded(
                                flex: 1,
                                child: AnimatedWidgets.hoverCard(
                                  borderRadius: BorderRadius.circular(32),
                                  elevation: 20,
                                  child: Container(
                                    padding: const EdgeInsets.all(40),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(32),
                                      color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.8),
                                      border: Border.all(color: color.withOpacity(0.1)),
                                    ),
                                    child: _buildLoginForm(color, context),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _buildLoginForm(color, context),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(Color color, BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedWidgets.bounceIn(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.shield_rounded, size: 56, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 32),
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(0, 0.2),
            delay: const Duration(milliseconds: 100),
            child: Text(
              'RagFree+',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, color: color, letterSpacing: -1),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(0, 0.2),
            delay: const Duration(milliseconds: 200),
            child: Text(
              'Secure Login',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).hintColor),
            ),
          ),
          const SizedBox(height: 40),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_rounded,
            delay: 300,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_rounded,
            delay: 400,
            isPassword: true,
          ),
          const SizedBox(height: 12),
          AnimatedWidgets.fadeIn(
            delay: const Duration(milliseconds: 500),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showForgotPasswordDialog(context),
                child: const Text('Forgot Password?'),
              ),
            ),
          ),
          const SizedBox(height: 32),
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(0, 0.2),
            delay: const Duration(milliseconds: 600),
            child: AnimatedWidgets.scaleButton(
              onPressed: _isLoading ? () {} : _login,
              child: FilledButton(
                onPressed: _isLoading ? null : _login,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: color.withOpacity(0.5),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AnimatedWidgets.fadeIn(
            delay: const Duration(milliseconds: 700),
            child: Row(
              children: [
                Expanded(child: Divider(color: color.withOpacity(0.1))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('OR', style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                Expanded(child: Divider(color: color.withOpacity(0.1))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(0, 0.2),
            delay: const Duration(milliseconds: 800),
            child: OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrationScreen())),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: color.withOpacity(0.3), width: 1.5),
              ),
              child: Text('Create New Account', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int delay,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return AnimatedWidgets.slideIn(
      beginOffset: const Offset(0.1, 0),
      delay: Duration(milliseconds: delay),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 22),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.transparent)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
      ),
    );
  }

  Widget _buildLoginHero(Color color, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedWidgets.slideIn(
          beginOffset: const Offset(-0.2, 0),
          child: Text('Ensuring a Ragging-Free\nCampus Environment', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, color: color, height: 1.2)),
        ),
        const SizedBox(height: 24),
        AnimatedWidgets.slideIn(
          beginOffset: const Offset(-0.2, 0),
          delay: const Duration(milliseconds: 100),
          child: Text('Join the movement to make education safe for everyone. Report, track, and resolve incidents with ease.', style: TextStyle(fontSize: 18, color: Theme.of(context).hintColor, height: 1.5)),
        ),
        const SizedBox(height: 48),
        ...[
          {'icon': Icons.security_rounded, 'text': '24/7 Rapid Incident Response'},
          {'icon': Icons.privacy_tip_rounded, 'text': 'Complete Identity Protection'},
          {'icon': Icons.volunteer_activism_rounded, 'text': 'Supportive Counselling Hub'},
        ].asMap().entries.map((e) => AnimatedWidgets.slideIn(
          beginOffset: const Offset(-0.2, 0),
          delay: Duration(milliseconds: 200 + e.key * 100),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(e.value['icon'] as IconData, color: color),
                ),
                const SizedBox(width: 20),
                Text(e.value['text'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        )),
      ],
    );
  }
}
