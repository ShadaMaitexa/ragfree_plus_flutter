import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import 'package:intl/intl.dart';

class WardenViewComplaintsPage extends StatefulWidget {
  const WardenViewComplaintsPage({super.key});

  @override
  State<WardenViewComplaintsPage> createState() => _WardenViewComplaintsPageState();
}

class _WardenViewComplaintsPageState extends State<WardenViewComplaintsPage> {
  final ComplaintService _complaintService = ComplaintService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Student Complaints')),
      body: StreamBuilder<List<ComplaintModel>>(
        stream: _complaintService.getAllComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No complaints currently filed'),
                ],
              ),
            );
          }

          final complaints = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final c = complaints[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(c.status).withOpacity(0.1),
                    child: Icon(Icons.description, color: _getStatusColor(c.status)),
                  ),
                  title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('By ${c.studentName ?? "Anonymous"} • ${DateFormat('MMM dd').format(c.createdAt)}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(c.description),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text('Priority: ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Chip(
                                label: Text(c.priority),
                                backgroundColor: _getPriorityColor(c.priority).withOpacity(0.1),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () => _updateStatus(c),
                                child: const Text('Update Status'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _updateStatus(ComplaintModel complaint) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Update Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Pending'),
                onTap: () => _setComplaintStatus(complaint, 'Pending'),
              ),
              ListTile(
                title: const Text('In Progress'),
                onTap: () => _setComplaintStatus(complaint, 'In Progress'),
              ),
              ListTile(
                title: const Text('Resolved'),
                onTap: () => _setComplaintStatus(complaint, 'Resolved'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setComplaintStatus(ComplaintModel complaint, String status) async {
    await _complaintService.updateComplaintStatus(complaint.id, status);
    if (mounted) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status updated to $status')));
  }

  Color _getStatusColor(String status) {
    if (status == 'Resolved') return Colors.green;
    if (status == 'In Progress') return Colors.blue;
    return Colors.orange;
  }

  Color _getPriorityColor(String priority) {
    if (priority == 'High') return Colors.red;
    if (priority == 'Medium') return Colors.orange;
    return Colors.green;
  }
}
