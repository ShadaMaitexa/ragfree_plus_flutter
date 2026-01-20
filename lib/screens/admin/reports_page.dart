import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/pdf_service.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final PdfService _pdfService = PdfService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint Logs')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'Standard Reports'),
                const SizedBox(height: 16),
                _buildReportGrid(context),
                const SizedBox(height: 32),
                _buildSectionTitle(context, 'Recent Activity Insights'),
                const SizedBox(height: 16),
                _buildInsightsCard(context),
              ],
            ),
          ),
          if (_isGenerating)
            Container(
              color: Colors.black26,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Generating Report...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildReportGrid(BuildContext context) {
    final reports = [
      {'title': 'Annual Safety Audit', 'icon': Icons.security, 'color': Colors.blue, 'type': 'complaints'},
      {'title': 'Complaint Analytics', 'icon': Icons.analytics, 'color': Colors.purple, 'type': 'analytics'},
      {'title': 'User Directory Report', 'icon': Icons.group, 'color': Colors.green, 'type': 'users'},
      {'title': 'Incident Hotspots', 'icon': Icons.map, 'color': Colors.red, 'type': 'incidents'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => _generateReport(report['type'] as String, report['title'] as String),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(report['icon'] as IconData, color: report['color'] as Color, size: 32),
                  const SizedBox(height: 12),
                  Text(
                    report['title'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightsCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInsightItem(Icons.trending_up, '85% Resolution Rate', Colors.green),
            const Divider(),
            _buildInsightItem(Icons.warning_amber, '12 High Priority Tasks', Colors.orange),
            const Divider(),
            _buildInsightItem(Icons.access_time, 'Average 2hr response time', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String text, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right, size: 16),
    );
  }

  Future<void> _generateReport(String type, String title) async {
    setState(() => _isGenerating = true);
    try {
      List<Map<String, dynamic>> data = [];
      String category = '';

      if (type == 'users') {
        final query = await _firestore.collection('users').limit(50).get();
        data = query.docs.map((doc) => {
          'Name': doc.data()['name'] ?? 'N/A',
          'Email': doc.data()['email'] ?? 'N/A',
          'Role': doc.data()['role'] ?? 'N/A',
        }).toList();
        category = 'User Management';
      } else if (type == 'complaints' || type == 'analytics') {
        final query = await _firestore.collection('complaints').limit(50).get();
        data = query.docs.map((doc) => {
          'Title': doc.data()['title'] ?? 'N/A',
          'Student': doc.data()['studentName'] ?? 'Anonymous',
          'Status': doc.data()['status'] ?? 'Pending',
          'Priority': doc.data()['priority'] ?? 'Medium',
        }).toList();
        category = 'safety & Complaints';
      } else {
        // Mock incidents for hotspots
        data = [
          {'Area': 'Hostel A', 'Total Incidents': '5', 'Status': 'High Alert'},
          {'Area': 'Cafeteria', 'Total Incidents': '2', 'Status': 'Normal'},
          {'Area': 'Library', 'Total Incidents': '0', 'Status': 'Safe'},
        ];
        category = 'Safety Hotspots';
      }

      if (data.isEmpty) {
        data = [{'Message': 'No data available for this report'}];
      }

      await _pdfService.generateReport(
        reportTitle: title,
        category: category,
        data: data,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating report: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}
