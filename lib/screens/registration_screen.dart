import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/app_state.dart';
import '../services/cloudinary_service.dart';
import '../models/user_model.dart';
import '../widgets/animated_widgets.dart';
import '../services/department_service.dart';
import '../utils/responsive.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _departmentController = TextEditingController();
  final _institutionController = TextEditingController();

  String _selectedRole = 'student';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  File? _idProofFile;
  String? _idProofUrl;
  bool _isUploadingIdProof = false;

  final AuthService _authService = AuthService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _institutionController.dispose();
    super.dispose();
  }

  Future<void> _pickIdProof() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _idProofFile = File(image.path);
          _idProofUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }



  Widget _buildHeroPanel(BuildContext context, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(-0.3, 0),
            child: Text(
              'Join the RagFree+ ecosystem',
              style: textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 32),
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(-0.3, 0),
            delay: const Duration(milliseconds: 100),
            child: _buildHeroBullet(
              context,
              icon: Icons.shield_outlined,
              title: 'Secure Onboarding',
              subtitle: 'Multi-factor verification keeps our campus safe.',
            ),
          ),
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(-0.3, 0),
            delay: const Duration(milliseconds: 200),
            child: _buildHeroBullet(
              context,
              icon: Icons.dashboard_outlined,
              title: 'Custom Dashboards',
              subtitle: 'Tailored tools for every role in the university.',
            ),
          ),
          AnimatedWidgets.slideIn(
            beginOffset: const Offset(-0.3, 0),
            delay: const Duration(milliseconds: 300),
            child: _buildHeroBullet(
              context,
              icon: Icons.bolt_outlined,
              title: 'Instant Alerts',
              subtitle: 'Stay ahead with real-time incident reporting.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBullet(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final color = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadIdProof() async {
    if (_idProofFile == null) return;
    setState(() => _isUploadingIdProof = true);
    try {
      final url = await _cloudinaryService.uploadImage(_idProofFile!);
      if (url != null && mounted) {
        setState(() {
          _idProofUrl = url;
          _isUploadingIdProof = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingIdProof = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole != 'parent' && _idProofFile == null && _idProofUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID proof is required'), backgroundColor: Colors.red),
      );
      return;
    }

    if (_selectedRole != 'parent' && _idProofFile != null && _idProofUrl == null) {
      await _uploadIdProof();
      if (_idProofUrl == null) return;
    }

    setState(() => _isLoading = true);
    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        throw Exception('Passwords do not match');
      }

      UserModel? user = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
        phone: _phoneController.text.trim(),
        department: _departmentController.text.trim(),
        institution: _institutionController.text.trim(),
        idProofUrl: _idProofUrl,
      );

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/approval-pending');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [color.withOpacity(0.05), Colors.transparent]
                : [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1024;
              
              final form = Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedWidgets.bounceIn(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1)),
                        child: Icon(Icons.person_add_rounded, size: 48, color: color),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.1),
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        items: ['student', 'parent', 'counsellor', 'warden', 'police', 'teacher']
                            .map((role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role[0].toUpperCase() + role.substring(1)),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() {
                          _selectedRole = v!;
                          _idProofFile = null;
                          _idProofUrl = null;
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.1),
                      delay: const Duration(milliseconds: 50),
                      child: TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => v!.isEmpty ? 'Name required' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.1),
                      delay: const Duration(milliseconds: 100),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.1),
                      delay: const Duration(milliseconds: 150),
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    if (_selectedRole != 'parent' && _selectedRole != 'police') ...[
                      const SizedBox(height: 16),
                      AnimatedWidgets.slideIn(
                        beginOffset: const Offset(0, 0.1),
                        delay: const Duration(milliseconds: 200),
                        child: StreamBuilder<List<String>>(
                          stream: DepartmentService().getDepartmentNames(),
                          builder: (context, snapshot) {
                            var departments = snapshot.data ?? [];
                            
                            // If no departments managed yet, show text field fallback
                            if (departments.isEmpty) {
                               return TextFormField(
                                controller: _departmentController,
                                decoration: const InputDecoration(
                                  labelText: 'Department',
                                  prefixIcon: Icon(Icons.school_outlined),
                                  helperText: 'Admin hasn\'t added departments yet. Enter manually.',
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Department required' : null,
                              );
                            }

                            return DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Department',
                                prefixIcon: Icon(Icons.school_outlined),
                              ),
                              items: departments.map((dept) => DropdownMenuItem(
                                value: dept,
                                child: Text(dept),
                              )).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  _departmentController.text = val;
                                }
                              },
                              validator: (v) => (_departmentController.text.isEmpty) ? 'Department required' : null,
                            );
                          },
                        ),
                      ),
                    ],
                    if (['student', 'teacher', 'counsellor', 'warden', 'police'].contains(_selectedRole)) ...[
                      const SizedBox(height: 16),
                      AnimatedWidgets.slideIn(
                        beginOffset: const Offset(0, 0.1),
                        delay: const Duration(milliseconds: 220),
                        child: TextFormField(
                          controller: _institutionController,
                          decoration: const InputDecoration(
                            labelText: 'College Name',
                            prefixIcon: Icon(Icons.account_balance_outlined),
                          ),
                          validator: (v) => v!.isEmpty ? 'College name required' : null,
                        ),
                      ),
                    ],
                    if (_selectedRole != 'parent') ...[
                      const SizedBox(height: 24),
                      Text('Proof of Identity', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                      const SizedBox(height: 12),
                      AnimatedWidgets.hoverCard(
                        child: InkWell(
                          onTap: _isUploadingIdProof ? null : _pickIdProof,
                          child: Container(
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: color.withOpacity(0.3), style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: _idProofFile != null || _idProofUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _idProofUrl != null
                                        ? Image.network(_idProofUrl!, fit: BoxFit.cover)
                                        : Image.file(_idProofFile!, fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined, color: color),
                                      const SizedBox(height: 8),
                                      const Text('Tap to upload ID proof'),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.1),
                      delay: const Duration(milliseconds: 250),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => v!.length < 6 ? 'Too short' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedWidgets.slideIn(
                      beginOffset: const Offset(0, 0.1),
                      delay: const Duration(milliseconds: 300),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_reset),
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AnimatedWidgets.scaleButton(
                      onPressed: _isLoading ? () {} : _register,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _register,
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Register Now', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Already have an account? ', style: TextStyle(color: Theme.of(context).hintColor)),
                            Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (!isDesktop) {
                return SingleChildScrollView(padding: const EdgeInsets.all(24), child: form);
              }

              return Row(
                children: [
                  Expanded(flex: 1, child: _buildHeroPanel(context, color)),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(48),
                          child: AnimatedWidgets.hoverCard(
                            elevation: 8,
                            hoverElevation: 16,
                            child: Padding(padding: const EdgeInsets.all(40), child: form),
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
}
