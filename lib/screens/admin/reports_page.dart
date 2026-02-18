import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/pdf_service.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../../services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  final PdfService _pdfService = PdfService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ComplaintService _complaintService = ComplaintService();
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
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildReportGrid(BuildContext context) {
    final reports = [
      {
        'title': 'Annual Safety Audit',
        'icon': Icons.security,
        'color': Colors.blue,
        'type': 'complaints',
      },
      {
        'title': 'Complaint Analytics',
        'icon': Icons.analytics,
        'color': Colors.purple,
        'type': 'analytics',
      },
      {
        'title': 'User Directory Report',
        'icon': Icons.group,
        'color': Colors.green,
        'type': 'users',
      },
      {
        'title': 'Incident Hotspots',
        'icon': Icons.map,
        'color': Colors.red,
        'type': 'incidents',
      },
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _generateReport(
              report['type'] as String,
              report['title'] as String,
            ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    report['icon'] as IconData,
                    color: report['color'] as Color,
                    size: 32,
                  ),
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
    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getAllComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final complaints = snapshot.data ?? [];

        // Resolution Rate
        final total = complaints.length;
        final resolved = complaints.where((c) => c.status == 'Resolved').length;
        final resolutionRate = total > 0 ? (resolved / total * 100).toInt() : 0;

        // High Priority Tasks
        final highPriority = complaints
            .where((c) => c.priority == 'High' && c.status != 'Resolved')
            .length;

        // Average Response Time
        double avgResponseTime = 0;
        final resolvedWithTime = complaints
            .where((c) => c.status == 'Resolved' && c.updatedAt != null)
            .toList();
        if (resolvedWithTime.isNotEmpty) {
          final totalHours = resolvedWithTime.fold<int>(
            0,
            (sum, c) => sum + c.updatedAt!.difference(c.createdAt).inHours,
          );
          avgResponseTime = totalHours / resolvedWithTime.length;
        }

        return Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInsightItem(
                      Icons.trending_up,
                      '$resolutionRate% Resolution Rate',
                      Colors.green,
                      onTap: () => _generateReport(
                        'analytics',
                        'Resolution Rate Report',
                      ),
                    ),
                    const Divider(),
                    _buildInsightItem(
                      Icons.warning_amber,
                      '$highPriority High Priority Tasks',
                      Colors.orange,
                      onTap: () => Provider.of<AppState>(
                        context,
                        listen: false,
                      ).setNavIndex(2),
                    ),
                    const Divider(),
                    _buildInsightItem(
                      Icons.access_time,
                      'Average ${avgResponseTime.toStringAsFixed(1)}hr response time',
                      Colors.blue,
                      onTap: () =>
                          _generateReport('analytics', 'Performance Audit'),
                    ),
                    const Divider(),
                    _buildInsightItem(
                      Icons.description_outlined,
                      'Student Complaint Case Report',
                      Colors.indigo,

                      onTap: () => _generateReport(
                        'complaints',
                        'Student Complaint Case Report',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Standard Reports'),
            const SizedBox(height: 16),
            _buildReportGrid(context),
          ],
        );
      },
    );
  }

  Widget _buildInsightItem(
    IconData icon,
    String text,
    Color color, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(text),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _generateReport(String type, String title) async {
    setState(() => _isGenerating = true);
    try {
      List<Map<String, dynamic>> data = [];
      String category = '';

      if (type == 'users') {
        final query = await _firestore.collection('users').limit(100).get();
        data = query.docs
            .map(
              (doc) => {
                'Name': doc.data()['name'] ?? 'N/A',
                'Email': doc.data()['email'] ?? 'N/A',
                'Role': doc.data()['role'] ?? 'N/A',
              },
            )
            .toList();
        category = 'User Management';
      } else if (type == 'analytics') {
        final query = await _firestore.collection('complaints').get();
        final Map<String, int> statusCounts = {};
        final Map<String, int> categoryCounts = {};

        for (var doc in query.docs) {
          final s = doc.data()['status'] ?? 'Pending';
          final c = doc.data()['category'] ?? 'Other';
          statusCounts[s] = (statusCounts[s] ?? 0) + 1;
          categoryCounts[c] = (categoryCounts[c] ?? 0) + 1;
        }

        data = [];
        data.add({
          'Metric': 'TOTAL COMPLAINTS',
          'Value': query.docs.length.toString(),
        });
        data.add({'Metric': '--- BY STATUS ---', 'Value': ''});
        statusCounts.forEach(
          (k, v) => data.add({'Metric': k, 'Value': v.toString()}),
        );
        data.add({'Metric': '--- BY CATEGORY ---', 'Value': ''});
        categoryCounts.forEach(
          (k, v) => data.add({'Metric': k, 'Value': v.toString()}),
        );

        category = 'Complaint Analytics Summary';
      } else if (type == 'complaints') {
        final query = await _firestore
            .collection('complaints')
            .limit(100)
            .get();
        data = query.docs
            .map(
              (doc) => {
                'Date': doc.data()['createdAt'] != null
                    ? DateFormat(
                        'yyyy-MM-dd',
                      ).format((doc.data()['createdAt'] as Timestamp).toDate())
                    : 'N/A',
                'Title': doc.data()['title'] ?? 'N/A',
                'Category': doc.data()['category'] ?? 'N/A',
                'Student': doc.data()['studentName'] ?? 'Anonymous',
                'Status': doc.data()['status'] ?? 'Pending',
                'Priority': doc.data()['priority'] ?? 'Medium',
              },
            )
            .toList();
        category = 'Safety & Complaints';
      } else {
        // Fetch real data for hotspots analysis
        final query = await _firestore
            .collection('complaints')
            .limit(100)
            .get();
        final Map<String, int> locationCounts = {};

        for (var doc in query.docs) {
          final data = doc.data();
          // Use location if available, otherwise fall back to incidentType
          String area = data['location']?.toString() ?? '';
          if (area.trim().isEmpty) {
            area = data['incidentType']?.toString() ?? 'Unknown';
          }

          // Normalize area name
          area = area.trim();
          if (area.isEmpty) area = 'Unknown Area';

          locationCounts[area] = (locationCounts[area] ?? 0) + 1;
        }

        data = locationCounts.entries.map((entry) {
          int count = entry.value;
          String status = 'Safe';
          if (count >= 5) {
            status = 'High Alert';
          } else if (count >= 2) {
            status = 'Validation Required';
          }

          return {
            'Area': entry.key,
            'Total Incidents': count.toString(),
            'Status': status,
          };
        }).toList();

        // Sort by incident count descending
        data.sort(
          (a, b) => int.parse(
            b['Total Incidents'],
          ).compareTo(int.parse(a['Total Incidents'])),
        );

        category = 'Safety Hotspots Analysis';
      }

      if (data.isEmpty) {
        data = [
          {'Message': 'No data available for this report'},
        ];
      }

      await _pdfService.generateReport(
        reportTitle: title,
        category: category,
        data: data,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}
