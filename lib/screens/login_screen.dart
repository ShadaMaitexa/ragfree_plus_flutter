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
                ? [
                    color.withOpacity(0.08),
                    Colors.transparent,
                    color.withOpacity(0.04),
                  ]
                : [
                    Colors.white,
                    color.withOpacity(0.03),
                    color.withOpacity(0.08),
                  ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              final form = AnimatedWidgets.fadeIn(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      AnimatedWidgets.bounceIn(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.2),
                                color.withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Icon(Icons.shield, size: 60, color: color),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedWidgets.slideIn(
                        beginOffset: const Offset(0, 0.2),
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'RagFree+',
                          style: Theme.of(context).textTheme.headlineLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: color,
                                letterSpacing: -0.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedWidgets.slideIn(
                        beginOffset: const Offset(0, 0.2),
                        delay: const Duration(milliseconds: 300),
                        child: Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.8),
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),
                      AnimatedWidgets.slideIn(
                        beginOffset: const Offset(-0.2, 0),
                        delay: const Duration(milliseconds: 400),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter your email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: color.withOpacity(0.7),
                            ),
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
                      ),
                      const SizedBox(height: 20),
                      AnimatedWidgets.slideIn(
                        beginOffset: const Offset(0.2, 0),
                        delay: const Duration(milliseconds: 500),
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: color.withOpacity(0.7),
                            ),
                            suffixIcon: AnimatedWidgets.scaleButton(
                              child: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: color.withOpacity(0.7),
                                ),
                                onPressed: () {
                                  setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  );
                                },
                              ),
                              onPressed: () {},
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      AnimatedWidgets.slideIn(
                        beginOffset: const Offset(0, 0.3),
                        delay: const Duration(milliseconds: 600),
                        child: AnimatedWidgets.scaleButton(
                          child: FilledButton(
                            onPressed: _isLoading ? null : _login,
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: _isLoading ? 0 : 2,
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Signing in...',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.login, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Sign In',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                      ),
                                    ],
                                  ),
                          ),
                          onPressed: _isLoading ? () {} : _login,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedWidgets.fadeIn(
                        delay: const Duration(milliseconds: 700),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _showForgotPasswordDialog(context),
                            style: TextButton.styleFrom(
                              foregroundColor: color,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            child: const Text('Forgot Password?'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedWidgets.fadeIn(
                        delay: const Duration(milliseconds: 800),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.2),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'or',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedWidgets.slideIn(
                        beginOffset: const Offset(0, 0.2),
                        delay: const Duration(milliseconds: 900),
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const RegistrationScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.easeInOutCubic;

                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));

                                  return SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: color.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_outlined,
                                size: 20,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Create New Account',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (!isWide) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedWidgets.fadeIn(
                    delay: const Duration(milliseconds: 100),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: form,
                      ),
                    ),
                  ),
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: AnimatedWidgets.slideIn(
                      beginOffset: const Offset(-0.3, 0),
                      delay: const Duration(milliseconds: 200),
                      child: _buildLoginHero(color, context),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: AnimatedWidgets.hoverCard(
                            elevation: 12,
                            hoverElevation: 20,
                            child: Padding(
                              padding: const EdgeInsets.all(40),
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
