import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../services/auth_service.dart';
import '../../models/complaint_model.dart';

class WardenForwardComplaintsPage extends StatefulWidget {
  const WardenForwardComplaintsPage({super.key});

  @override
  State<WardenForwardComplaintsPage> createState() => _WardenForwardComplaintsPageState();
}

class _WardenForwardComplaintsPageState extends State<WardenForwardComplaintsPage> {
  final ComplaintService _complaintService = ComplaintService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forward Complaints')),
      body: StreamBuilder<List<ComplaintModel>>(
        stream: _complaintService.getAllComplaints(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final complaints = snapshot.data!.where((c) => c.assignedTo == null).toList();

          if (complaints.isEmpty) {
            return const Center(child: Text('No unassigned complaints found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final c = complaints[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  title: Text(c.title),
                  subtitle: Text(c.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: ElevatedButton(
                    onPressed: () => _showCounsellorSelection(c),
                    child: const Text('Forward'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showCounsellorSelection(ComplaintModel complaint) async {
    final counsellors = await _authService.getAvailableCounselors();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Counsellor'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: counsellors.length,
              itemBuilder: (context, index) {
                final co = counsellors[index];
                return ListTile(
                  title: Text(co['name']),
                  subtitle: Text(co['department'] ?? 'Counselling'),
                  onTap: () async {
                    await _complaintService.assignComplaint(
                      complaintId: complaint.id, 
                      counselorId: co['id'], 
                      counselorName: co['name']
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Forwarded to ${co['name']}'))
                      );
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ],
        );
      },
    );
  }
}
