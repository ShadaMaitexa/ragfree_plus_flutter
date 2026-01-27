import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import 'package:intl/intl.dart';

class WardenViewComplaintsPage extends StatefulWidget {
  const WardenViewComplaintsPage({super.key});

  @override
  State<WardenViewComplaintsPage> createState() =>
      _WardenViewComplaintsPageState();
}

class _WardenViewComplaintsPageState extends State<WardenViewComplaintsPage> {
  final ComplaintService _complaintService = ComplaintService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Student Complaints')),
      body: StreamBuilder<List<ComplaintModel>>(
        stream: _complaintService.getHostelComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(c.status).withValues(alpha: 0.1),
                    child: Icon(
                      Icons.description,
                      color: _getStatusColor(c.status),
                    ),
                  ),
                  title: Text(
                    c.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'By ${c.studentName ?? "Anonymous"} • ${DateFormat('MMM dd').format(c.createdAt)}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(c.description),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Text(
                                'Type: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Chip(
                                label: Text(c.incidentType),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => _showForwardDialog(c),
                                icon: const Icon(Icons.forward),
                                label: const Text('Forward'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    _setComplaintStatus(c, 'In Progress'),
                                child: const Text('Take Action'),
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

  void _showForwardDialog(ComplaintModel complaint) {
    String selectedRole = 'admin';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Forward to Authorities'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Forward this complaint to college authorities:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Forward To',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'admin',
                    child: Text('College Admin'),
                  ),
                  DropdownMenuItem(value: 'police', child: Text('Police')),
                  DropdownMenuItem(
                    value: 'counsellor',
                    child: Text('Counsellor'),
                  ),
                ],
                onChanged: (val) => setDialogState(() => selectedRole = val!),
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
                try {
                  await _complaintService.forwardToRole(
                    complaintId: complaint.id,
                    forwardToRole: selectedRole,
                    forwarderId: 'warden', // Simplified or use actual ID
                    forwarderName: 'Hostel Warden',
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Forwarded to $selectedRole')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                }
              },
              child: const Text('Forward'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setComplaintStatus(
    ComplaintModel complaint,
    String status,
  ) async {
    await _complaintService.updateComplaintStatus(complaint.id, status);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Status updated to $status')));
  }

  Color _getStatusColor(String status) {
    if (status == 'Resolved') return Colors.green;
    if (status == 'In Progress') return Colors.blue;
    return Colors.orange;
  }

}
