import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';

class WardenForwardComplaintsPage extends StatefulWidget {
  const WardenForwardComplaintsPage({super.key});

  @override
  State<WardenForwardComplaintsPage> createState() =>
      _WardenForwardComplaintsPageState();
}

class _WardenForwardComplaintsPageState
    extends State<WardenForwardComplaintsPage> {
  final ComplaintService _complaintService = ComplaintService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forward Complaints')),
      body: StreamBuilder<List<ComplaintModel>>(
        stream: _complaintService.getHostelComplaints(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final complaints = snapshot.data!
              .where(
                (c) =>
                    c.assignedTo == null &&
                    (c.metadata == null || c.metadata!['forwardedTo'] == null),
              )
              .toList();

          if (complaints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text('No complaints pending forwarding'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final c = complaints[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  title: Text(c.title),
                  subtitle: Text(
                    c.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: FilledButton.icon(
                    onPressed: () => _showForwardDialog(c),
                    icon: const Icon(Icons.forward, size: 18),
                    label: const Text('Forward'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showForwardDialog(ComplaintModel complaint) {
    String selectedRole = 'police'; // Default
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Forward Complaint'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select authority to forward to:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Forward To',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'police', child: Text('Police')),
                  DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
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
                    forwarderId: 'warden',
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
}
