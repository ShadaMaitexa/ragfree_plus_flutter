import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class WardenStudentsPage extends StatefulWidget {
  const WardenStudentsPage({super.key});

  @override
  State<WardenStudentsPage> createState() => _WardenStudentsPageState();
}

class _WardenStudentsPageState extends State<WardenStudentsPage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students')),
      body: StreamBuilder<List<UserModel>>(
        stream: _authService.getUsersByRole('student'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final students = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final s = students[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(s.department ?? 'No Department'),
                  trailing: IconButton(
                    icon: const Icon(Icons.info_outline, color: Colors.blue),
                    onPressed: () => _showStudentDetails(s),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showStudentDetails(UserModel student) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${student.email}'),
            const SizedBox(height: 8),
            Text('Phone: ${student.phone ?? "N/A"}'),
            const SizedBox(height: 8),
            Text('Department: ${student.department ?? "N/A"}'),
            const SizedBox(height: 8),
            Text('Status: ${student.isApproved ? "Approved" : "Pending"}'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
