import 'package:flutter/material.dart';
import '../../services/department_service.dart';
import '../../utils/responsive.dart';

class AdminDepartmentsPage extends StatefulWidget {
  const AdminDepartmentsPage({super.key});

  @override
  State<AdminDepartmentsPage> createState() => _AdminDepartmentsPageState();
}

class _AdminDepartmentsPageState extends State<AdminDepartmentsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final DepartmentService _departmentService = DepartmentService();

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _departmentService.getDepartments(),
              builder: (context, snapshot) {
                final departments = snapshot.data ?? [];
                
                return SingleChildScrollView(
                  padding: Responsive.getPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, color, departments),
                      const SizedBox(height: 32),
                      Text(
                        'Departments List',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      departments.isEmpty
                          ? _buildEmptyState(context, color)
                          : _buildDepartmentsList(context, departments),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color color, List<Map<String, dynamic>> departments) {
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
                child: Icon(Icons.apartment, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Department Management',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      'Manage academic departments and staff',
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
                onPressed: () => _showAddDepartmentDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Department'),
                style: FilledButton.styleFrom(backgroundColor: color),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: Responsive.isMobile(context) ? 2 : 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                context,
                'Total Departments',
                '${departments.length}',
                Icons.apartment,
                Colors.blue,
              ),
              _buildStatCard(
                context,
                'Total Students',
                '${departments.fold(0, (sum, d) => sum + (int.tryParse(d['students']?.toString() ?? '0') ?? 0))}',
                Icons.people,
                Colors.green,
              ),
              _buildStatCard(
                context,
                'Total Staff',
                '${departments.fold(0, (sum, d) => sum + (int.tryParse(d['staff']?.toString() ?? '0') ?? 0))}',
                Icons.work,
                Colors.orange,
              ),
            ],
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

  Widget _buildEmptyState(BuildContext context, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: Icon(Icons.apartment_outlined, size: 64, color: color),
          ),
          const SizedBox(height: 24),
          Text(
            'No Departments Yet',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Add departments to organize students and staff',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => _showAddDepartmentDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Department'),
            style: FilledButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentsList(BuildContext context, List<Map<String, dynamic>> departments) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: departments.length,
      itemBuilder: (context, index) {
        final department = departments[index];
        return _buildDepartmentCard(context, department, index);
      },
    );
  }

  Widget _buildDepartmentCard(
    BuildContext context,
    Map<String, dynamic> department,
    int index,
  ) {
    final deptColor = Color(department['colorValue'] ?? Colors.blue.value);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                deptColor.withOpacity(0.1),
                deptColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: deptColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.apartment,
                        color: deptColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            department['name'],
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: deptColor,
                                ),
                          ),
                          Text(
                            'Head: ${department['head']}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
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
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: const Text(
                        'Active',
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
                    _buildStatItem(
                      context,
                      'Students',
                      department['students'].toString(),
                      Icons.people,
                      Colors.blue,
                    ),
                    const SizedBox(width: 24),
                    _buildStatItem(
                      context,
                      'Staff',
                      department['staff'].toString(),
                      Icons.work,
                      Colors.orange,
                    ),
                    const Spacer(),
                    Text(
                      'ID: ${department['id']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editDepartment(context, department),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _viewDepartmentDetails(context, department),
                        icon: const Icon(Icons.info, size: 16),
                        label: const Text('Details'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteDepartment(context, department),
                        icon: const Icon(
                          Icons.delete,
                          size: 16,
                          color: Colors.red,
                        ),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          side: const BorderSide(color: Colors.red),
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  void _showAddDepartmentDialog(BuildContext context) {
    final nameController = TextEditingController();
    final headController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Department'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Department Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: headController,
              decoration: const InputDecoration(
                labelText: 'Department Head',
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
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  headController.text.isNotEmpty) {
                await _departmentService.addDepartment({
                  'name': nameController.text,
                  'head': headController.text,
                  'students': 0,
                  'staff': 0,
                  'colorValue': Colors.blue.value, // Default color or from picker
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Department added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Add Department'),
          ),
        ],
      ),
    );
  }

  void _editDepartment(BuildContext context, Map<String, dynamic> department) {
    final nameController = TextEditingController(text: department['name']);
    final headController = TextEditingController(text: department['head']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${department['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Department Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: headController,
              decoration: const InputDecoration(
                labelText: 'Department Head',
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
            onPressed: () async {
              await _departmentService.updateDepartment(department['id'], {
                'name': nameController.text,
                'head': headController.text,
              });
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Department updated successfully!'),
                  ),
                );
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _viewDepartmentDetails(
    BuildContext context,
    Map<String, dynamic> department,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(department['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Head: ${department['head']}'),
            Text('Students: ${department['students']}'),
            Text('Staff: ${department['staff']}'),
            Text('ID: ${department['id']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteDepartment(
    BuildContext context,
    Map<String, dynamic> department,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text(
          'Are you sure you want to delete ${department['name']}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await _departmentService.deleteDepartment(department['id']);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Department deleted successfully!'),
                    backgroundColor: Colors.red,
                  ),
                );
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
