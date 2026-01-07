import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';

class WardenDashboardPage extends StatefulWidget {
  const WardenDashboardPage({super.key});

  @override
  State<WardenDashboardPage> createState() => _WardenDashboardPageState();
}

class _WardenDashboardPageState extends State<WardenDashboardPage> {
  final ComplaintService _complaintService = ComplaintService();

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, color),
              const SizedBox(height: 24),
              _buildStatsGrid(context, color),
              const SizedBox(height: 24),
              _buildQuickActions(context, color),
              const SizedBox(height: 24),
              _buildRecentComplaints(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome Back,',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
            ),
            Text(
              user?.name ?? 'Warden',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const Spacer(),
        CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(Icons.person, color: color),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context, Color color) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getHostelComplaints(),
      builder: (context, snapshot) {
        final complaints = snapshot.data ?? [];
        final total = complaints.length;
        final pending = complaints.where((c) => c.status == 'Pending').length;
        final inProgress = complaints.where((c) => c.status == 'In Progress').length;
        final resolved = complaints.where((c) => c.status == 'Resolved').length;

        return Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard('Total', total.toString(), Icons.assessment, Colors.purple)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Pending', pending.toString(), Icons.pending, Colors.orange)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatCard('Active', inProgress.toString(), Icons.run_circle, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Resolved', resolved.toString(), Icons.check_circle, Colors.green)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildActionBtn(context, 'View Complaints', Icons.assignment, Colors.blue, 1)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionBtn(context, 'Manage Students', Icons.people, Colors.purple, 3)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, Color color, int targetIndex) {
    return ElevatedButton.icon(
      onPressed: () => Provider.of<AppState>(context, listen: false).setNavIndex(targetIndex),
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildRecentComplaints(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Complaints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        StreamBuilder<List<ComplaintModel>>(
          stream: _complaintService.getHostelComplaints(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final complaints = snapshot.data!.take(5).toList();
            if (complaints.isEmpty) return const Center(child: Text('No complaints found'));

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final c = complaints[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(c.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(c.studentName ?? 'Anonymous'),
                    trailing: Chip(
                      label: Text(c.status, style: const TextStyle(fontSize: 10)),
                      backgroundColor: _getStatusColor(c.status).withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Resolved': return Colors.green;
      case 'In Progress': return Colors.blue;
      default: return Colors.orange;
    }
  }
}
