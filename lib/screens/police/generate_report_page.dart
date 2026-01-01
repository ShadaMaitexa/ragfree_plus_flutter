import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../../services/pdf_service.dart';
import 'package:intl/intl.dart';

class PoliceGenerateReportPage extends StatefulWidget {
  const PoliceGenerateReportPage({super.key});

  @override
  State<PoliceGenerateReportPage> createState() =>
      _PoliceGenerateReportPageState();
}

class _PoliceGenerateReportPageState extends State<PoliceGenerateReportPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ComplaintService _complaintService = ComplaintService();
  final PdfService _pdfService = PdfService();
  DateTimeRange? _selectedDateRange;
  String _selectedStatus = 'All';
  String _selectedPriority = 'All';

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, color),
                  const SizedBox(height: 24),
                  _buildFilters(context, color),
                  const SizedBox(height: 24),
                  _buildReportPreview(context, color),
                  const SizedBox(height: 24),
                  _buildGenerateButton(context, color),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.picture_as_pdf, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Generate Report',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  'Create comprehensive reports on ragging complaints',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(BuildContext context, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Filters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', 'Pending', 'In Progress', 'Resolved']
                        .map((status) {
                      return DropdownMenuItem(value: status, child: Text(status));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value ?? 'All';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: ['All', 'High', 'Medium', 'Low'].map((priority) {
                      return DropdownMenuItem(
                          value: priority, child: Text(priority));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value ?? 'All';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _selectedDateRange,
                );
                if (picked != null) {
                  setState(() {
                    _selectedDateRange = picked;
                  });
                }
              },
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDateRange == null
                    ? 'Select Date Range'
                    : '${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportPreview(BuildContext context, Color color) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getAllComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final allComplaints = snapshot.data ?? [];
        
        final filteredComplaints = _getFilteredComplaints(allComplaints);

        final total = filteredComplaints.length;
        final pending = filteredComplaints.where((c) => c.status == 'Pending').length;
        final inProgress = filteredComplaints.where((c) => c.status == 'In Progress').length;
        final resolved = filteredComplaints.where((c) => c.status == 'Resolved').length;
        final highPriority = filteredComplaints.where((c) => c.priority == 'High').length;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 16),
                _buildStatRow('Total Complaints', '$total', Colors.blue),
                _buildStatRow('Pending', '$pending', Colors.orange),
                _buildStatRow('In Progress', '$inProgress', Colors.blue),
                _buildStatRow('Resolved', '$resolved', Colors.green),
                _buildStatRow('High Priority', '$highPriority', Colors.red),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Report Period',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedDateRange == null
                      ? 'All Time'
                      : '${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ComplaintModel> _getFilteredComplaints(List<ComplaintModel> all) {
    var filtered = all;
    if (_selectedStatus != 'All') {
      filtered = filtered.where((c) => c.status == _selectedStatus).toList();
    }
    if (_selectedPriority != 'All') {
      filtered = filtered.where((c) => c.priority == _selectedPriority).toList();
    }
    if (_selectedDateRange != null) {
      filtered = filtered
          .where((c) =>
              c.createdAt.isAfter(_selectedDateRange!.start) &&
              c.createdAt.isBefore(_selectedDateRange!.end.add(const Duration(days: 1))))
          .toList();
    }
    return filtered;
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(BuildContext context, Color color) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getAllComplaints(),
      builder: (context, snapshot) {
        final complaints = _getFilteredComplaints(snapshot.data ?? []);
        return FilledButton.icon(
          onPressed: complaints.isEmpty ? null : () => _generateReport(context, complaints),
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Generate PDF Report'),
          style: FilledButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        );
      },
    );
  }

  Future<void> _generateReport(BuildContext context, List<ComplaintModel> complaints) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final data = complaints.map((c) => {
        'Title': c.title,
        'Student': c.studentName ?? 'Anonymous',
        'Category': c.category,
        'Status': c.status,
        'Priority': c.priority,
        'Date': DateFormat('yyyy-MM-dd').format(c.createdAt),
      }).toList();

      await _pdfService.generateReport(
        reportTitle: 'Campus Safety - Ragging Complaints Report',
        category: 'Status: $_selectedStatus, Priority: $_selectedPriority',
        data: data,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
