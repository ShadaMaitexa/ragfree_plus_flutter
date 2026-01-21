import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/certificate_service.dart';
import '../../services/pdf_service.dart';
import '../../models/certificate_model.dart';
import '../../utils/responsive.dart';

class AdminCertificatesPage extends StatefulWidget {
  const AdminCertificatesPage({super.key});

  @override
  State<AdminCertificatesPage> createState() => _AdminCertificatesPageState();
}

class _AdminCertificatesPageState extends State<AdminCertificatesPage> {
  final CertificateService _certificateService = CertificateService();
  final PdfService _pdfService = PdfService();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: StreamBuilder<List<CertificateModel>>(
        stream: _certificateService.getCertificates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final certificates = snapshot.data ?? [];

          return SingleChildScrollView(
            padding: Responsive.getPadding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Certificate Registry',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showIssueDialog(context),
                      icon: const Icon(Icons.add_circle, size: 20),
                      label: const Text('Issue New'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSummaryCards(context, color, certificates),
                const SizedBox(height: 32),
                Text(
                  'Recent Certificates',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCertificateList(context, certificates),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, Color color, List<CertificateModel> items) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Issued',
            items.where((c) => c.status == 'Issued').length.toString(),
            Icons.verified,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Pending',
            items.where((c) => c.status == 'Pending').length.toString(),
            Icons.pending,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificateList(BuildContext context, List<CertificateModel> items) {
    if (items.isEmpty) {
      return const Center(child: Text('No certificates recorded'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final cert = items[index];
        final isIssued = cert.status == 'Issued';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIssued ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              child: Icon(
                isIssued ? Icons.verified : Icons.pending,
                color: isIssued ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(cert.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${cert.course}\n${DateFormat('MMM dd, yyyy').format(cert.issueDate)}'),
            isThreeLine: true,
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'download', child: Text('Download PDF')),
                if (!isIssued) const PopupMenuItem(value: 'issue', child: Text('Issue Now')),
                const PopupMenuItem(value: 'delete', child: Text('Revoke')),
              ],
              onSelected: (value) async {
                if (value == 'download') {
                  await _pdfService.generateCertificate(
                    studentName: cert.studentName,
                    courseName: cert.course,
                    certificateId: cert.id,
                    issueDate: cert.issueDate,
                  );
                } else if (value == 'issue') {
                  await _certificateService.updateStatus(cert.id, 'Issued');
                } else if (value == 'delete') {
                  await _certificateService.deleteCertificate(cert.id);
                }
              },
            ),
          ),
        );
      },
    );
  }

  void _showIssueDialog(BuildContext context) {
    final nameController = TextEditingController();
    final courseController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Issue New Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Student Name')),
            const SizedBox(height: 16),
            TextField(controller: courseController, decoration: const InputDecoration(labelText: 'Course Name')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && courseController.text.isNotEmpty) {
                final cert = CertificateModel(
                  id: '',
                  studentName: nameController.text,
                  course: courseController.text,
                  issueDate: DateTime.now(),
                  status: 'Issued',
                );
                await _certificateService.issueCertificate(cert);
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Issue'),
          ),
        ],
      ),
    );
  }
}
