import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/auth_service.dart';
import '../services/app_state.dart';
import '../services/cloudinary_service.dart';
import '../models/user_model.dart';

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
          _idProofUrl = null; // Reset URL when new file is selected
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
          Text(
            'Join the RagFree+ community',
            style: textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _buildHeroBullet(
            context,
            icon: Icons.shield,
            title: 'Secure onboarding',
            subtitle:
                'Verified ID proofs and admin approvals keep the campus safe.',
          ),
          _buildHeroBullet(
            context,
            icon: Icons.group,
            title: 'Role-specific dashboards',
            subtitle:
                'Students, parents, teachers, and staff get tailored tools.',
          ),
          _buildHeroBullet(
            context,
            icon: Icons.notifications_active,
            title: 'Real-time alerts',
            subtitle: 'Stay informed with emergency alerts and campus updates.',
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ID proof uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to upload ID proof');
      }
    } 
    catch (e) {
      if (mounted) {
        setState(() => _isUploadingIdProof = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload ID proof: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } 
  }                                                           

  Future<void> _register() async { 
    if (!_formKey.currentState!.validate()) return;

    // Check if ID proof is required and uploaded (for all roles except parent and teacher)
    if (_selectedRole != 'parent' && _selectedRole != 'teacher') {
      if (_idProofFile == null && _idProofUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your ID proof'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // If file is selected but not uploaded, upload it first
      if (_idProofFile != null && _idProofUrl == null) {
        await _uploadIdProof();
        if (_idProofUrl == null) {
          return; // Upload failed, don't proceed
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      // Check if passwords match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
        setState(() => _isLoading = false);
        return;
      }

      UserModel? user = await _authService.registerWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        role: _selectedRole,
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        department: _departmentController.text.trim().isEmpty
            ? null
            : _departmentController.text.trim(),
        idProofUrl: (_selectedRole != 'parent' && _selectedRole != 'teacher')
            ? _idProofUrl
            : null,
      );

      if (user != null && mounted) {
        // All users need approval (except admin, but admin doesn't register)
        if (!user.isApproved) {
          // Navigate to approval pending screen
          Navigator.pushReplacementNamed(context, '/approval-pending');
        } else {
          // Only admin would be auto-approved, but they don't register
          context.read<AppState>().setUser(user);
          _navigateToDashboard(user.role);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
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
                    const SizedBox(height: 20),
                    Icon(Icons.person_add, size: 64, color: color),
                    const SizedBox(height: 16),
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold, color: color),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join RagFree+ to ensure campus safety',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Select Your Role *',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'student',
                          child: Row(
                            children: [
                              Icon(Icons.school, size: 20),
                              SizedBox(width: 8),
                              Text('Student'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'parent',
                          child: Row(
                            children: [
                              Icon(Icons.family_restroom, size: 20),
                              SizedBox(width: 8),
                              Text('Parent'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'counsellor',
                          child: Row(
                            children: [
                              Icon(Icons.psychology, size: 20),
                              SizedBox(width: 8),
                              Text('Counsellor'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'warden',
                          child: Row(
                            children: [
                              Icon(Icons.security, size: 20),
                              SizedBox(width: 8),
                              Text('Warden'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'police',
                          child: Row(
                            children: [
                              Icon(Icons.local_police, size: 20),
                              SizedBox(width: 8),
                              Text('Police'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'teacher',
                          child: Row(
                            children: [
                              Icon(Icons.person_outline, size: 20),
                              SizedBox(width: 8),
                              Text('Teacher'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedRole = value;
                            _idProofFile = null;
                            _idProofUrl = null;
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a role';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone (Optional)',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    if (_selectedRole == 'student' ||
                        _selectedRole == 'counsellor' ||
                        _selectedRole == 'warden')
                      TextFormField(
                        controller: _departmentController,
                        decoration: const InputDecoration(
                          labelText: 'Department',
                          prefixIcon: Icon(Icons.business),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    if (_selectedRole == 'student' ||
                        _selectedRole == 'counsellor' ||
                        _selectedRole == 'warden')
                      const SizedBox(height: 16),
                    if (_selectedRole != 'parent' &&
                        _selectedRole != 'teacher') ...[
                      Text(
                        'ID Proof Document *',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _idProofFile == null && _idProofUrl == null
                                ? Colors.red
                                : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            if (_idProofFile != null || _idProofUrl != null)
                              Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  color: Colors.grey.shade100,
                                ),
                                child: _idProofUrl != null
                                    ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                        child: Image.network(
                                          _idProofUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 48,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      )
                                    : _idProofFile != null
                                    ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(10),
                                            ),
                                        child: Image.file(
                                          _idProofFile!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const SizedBox(),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _isUploadingIdProof
                                          ? null
                                          : _pickIdProof,
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text('Select ID Proof'),
                                    ),
                                  ),
                                  if (_idProofFile != null &&
                                      _idProofUrl == null) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: _isUploadingIdProof
                                            ? null
                                            : _uploadIdProof,
                                        icon: _isUploadingIdProof
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Icon(Icons.cloud_upload),
                                        label: Text(
                                          _isUploadingIdProof
                                              ? 'Uploading...'
                                              : 'Upload',
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_idProofFile == null && _idProofUrl == null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 12),
                          child: Text(
                            'ID proof is required for ${_selectedRole == 'student'
                                ? 'students'
                                : _selectedRole == 'counsellor'
                                ? 'counsellors'
                                : _selectedRole == 'warden'
                                ? 'wardens'
                                : _selectedRole == 'police'
                                ? 'police officers'
                                : 'this role'}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
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
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: _isLoading ? null : _register,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Register'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Already have an account? Login'),
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
                  Expanded(child: _buildHeroPanel(context, color)),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 32,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
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
}
