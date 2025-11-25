import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/app_state.dart';
import '../models/user_model.dart';
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

      // Try admin login first if email matches admin email
      if (email == 'admin@ragfree.com') {
        try {
          user = await _authService.adminLogin(
            email: email,
            password: password,
          );
        } catch (e) {
          // If admin login fails, show error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      } else {
        // Regular user login
        user = await _authService.loginWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Check if user needs approval (all users except admin need approval)
        if (user != null && user.role != 'admin' && !user.isApproved) {
          // Navigate to approval pending screen
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Your account is pending admin approval'),
                backgroundColor: Colors.orange,
              ),
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
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin');
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

  void _showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    bool isSending = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_reset, color: Colors.blue),
              SizedBox(width: 8),
              Text('Reset Password'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  hintText: 'Enter your registered email',
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !isSending,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSending
                  ? null
                  : () {
                      emailController.dispose();
                      Navigator.pop(context);
                    },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSending
                  ? null
                  : () async {
                      final email = emailController.text.trim();
                      if (email.isEmpty || !email.contains('@')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a valid email address'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSending = true);

                      try {
                        await _authService.sendPasswordResetEmail(email);
                        if (context.mounted) {
                          emailController.dispose();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Password reset email sent! Please check your inbox.',
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSending = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll('Exception: ', ''),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
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
                ? [color.withOpacity(0.1), Colors.transparent]
                : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              final form = Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Icon(Icons.shield, size: 80, color: color),
                    const SizedBox(height: 24),
                    Text(
                      'RagFree+',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold, color: color),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            ); 
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoading ? null : _login,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showForgotPasswordDialog(context),
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegistrationScreen(),
                          ),
                        );
                      },
                      child: const Text('Don\'t have an account? Register'),
                    ),
                  ],
                ),
              );

              if (!isWide) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: form,
                );
              }

              return Row(
                children: [
                  Expanded(child: _buildLoginHero(color, context)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Card(
                            elevation: 6,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: form,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginHero(Color color, BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Safer campuses start here',
            style: textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _buildLoginHeroBullet(
            context,
            icon: Icons.policy,
            title: 'Centralized safety hub',
            subtitle: 'Track complaints, alerts, and approvals from one place.',
          ),
          _buildLoginHeroBullet(
            context,
            icon: Icons.chat_bubble,
            title: 'Stay connected',
            subtitle:
                'Real-time chat between students, staff, and authorities.',
          ),
          _buildLoginHeroBullet(
            context,
            icon: Icons.verified_user,
            title: 'Verified access',
            subtitle: 'Admin approvals ensure every user is authenticated.',
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHeroBullet(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
    );
  }
}
