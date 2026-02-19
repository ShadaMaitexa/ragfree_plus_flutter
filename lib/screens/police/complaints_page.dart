import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/app_state.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import '../../utils/responsive.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PoliceComplaintsPage extends StatefulWidget {
  const PoliceComplaintsPage({super.key});

  @override
  State<PoliceComplaintsPage> createState() => _PoliceComplaintsPageState();
}

class _PoliceComplaintsPageState extends State<PoliceComplaintsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;
  final ComplaintService _complaintService = ComplaintService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: 4, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
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
                    ? [color.withValues(alpha: 0.05), Colors.transparent]
                    : [Colors.grey.shade50, Colors.white],
              ),
            ),
            child: Column(
              children: [
                _buildHeader(context, color),
                _buildTabBar(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllComplaintsTab(context),
                      _buildPendingTab(context),
                      _buildInProgressTab(context),
                      _buildResolvedTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.assignment, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complaints Management',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      'Monitor and verify ragging complaints',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.primary,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Pending'),
          Tab(text: 'In Progress'),
          Tab(text: 'Resolved'),
        ],
      ),
    );
  }

  Widget _buildAllComplaintsTab(BuildContext context) {
    return _buildComplaintsList(context, null, null);
  }

  Widget _buildPendingTab(BuildContext context) {
    return _buildComplaintsList(context, 'Pending', null);
  }

  Widget _buildInProgressTab(BuildContext context) {
    return _buildInProgressComplaintsList(context);
  }

  Widget _buildResolvedTab(BuildContext context) {
    return _buildComplaintsList(context, 'Resolved', null);
  }

  Widget _buildInProgressComplaintsList(BuildContext context) {
    return StreamBuilder<List<ComplaintModel>>(
      stream: _complaintService.getAllComplaints(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }

        // Filter to show both "In Progress" and "Verified" complaints
        final allComplaints = snapshot.data ?? [];
        final complaints = allComplaints
            .where((c) => c.status == 'In Progress' || c.status == 'Verified')
            .toList();

        if (complaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Complaints',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'No in progress or verified complaints',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getHorizontalPadding(context),
              ),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                return _buildComplaintCard(context, complaints[index], index);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildComplaintsList(
    BuildContext context,
    String? status,
    String? priority,
  ) {
    Stream<List<ComplaintModel>> stream;
    if (status != null) {
      stream = _complaintService.getComplaintsByStatus(status);
    } else if (priority != null) {
      stream = _complaintService.getAllComplaints();
    } else {
      stream = _complaintService.getAllComplaints();
    }

    return StreamBuilder<List<ComplaintModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
              ],
            ),
          );
        }
        var complaints = snapshot.data ?? [];

        // Filter by priority if needed
        if (priority != null) {
          complaints = complaints.where((c) => c.priority == priority).toList();
        }

        if (complaints.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No Complaints',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  status != null
                      ? 'No ${status.toLowerCase()} complaints'
                      : priority != null
                      ? 'No $priority priority complaints'
                      : 'No complaints found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.getHorizontalPadding(context),
              ),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                return _buildComplaintCard(context, complaints[index], index);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildComplaintCard(
    BuildContext context,
    ComplaintModel complaint,
    int index,
  ) {
    final status = complaint.status;
    final priority = complaint.priority;

    Color statusColor;
    switch (status) {
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Verified':
        statusColor = Colors.purple;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    Color priorityColor;
    switch (priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      case 'Low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => _showComplaintDetails(context, complaint),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: priorityColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          color: priorityColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM dd, yyyy').format(complaint.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  complaint.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  complaint.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      complaint.isAnonymous
                          ? 'Anonymous'
                          : (complaint.studentName ?? 'Unknown'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.category,
                      size: 16,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        complaint.category,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (complaint.location != null) ...[
                      const Spacer(),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          complaint.location!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComplaintDetails(BuildContext context, ComplaintModel complaint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(complaint.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(complaint.description),
              const SizedBox(height: 16),
              _buildDetailRow('Status', complaint.status),
              _buildDetailRow('Priority', complaint.priority),
              _buildDetailRow('Category', complaint.category),
              _buildDetailRow(
                'Student',
                complaint.isAnonymous
                    ? 'Anonymous'
                    : (complaint.studentName ?? 'Unknown'),
              ),
              _buildDetailRow(
                'Date',
                DateFormat('MMM dd, yyyy').format(complaint.createdAt),
              ),
              if (complaint.location != null)
                _buildDetailRow('Location', complaint.location!),
              if (complaint.assignedToName != null)
                _buildDetailRow('Assigned To', complaint.assignedToName!),

              // Show Resolution Details if resolved
              if (complaint.status.toLowerCase() == 'resolved' &&
                  complaint.metadata != null) ...[
                const Divider(height: 32),
                Text(
                  'Resolution Details',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 12),
                if (complaint.metadata!['actionTaken'] != null)
                  _buildDetailRow(
                    'Action Taken',
                    complaint.metadata!['actionTaken'],
                  ),
                if (complaint.metadata!['resolvedAt'] != null)
                  _buildDetailRow(
                    'Resolved On',
                    DateFormat('MMM dd, yyyy HH:mm').format(
                      (complaint.metadata!['resolvedAt'] as Timestamp).toDate(),
                    ),
                  ),
                if (complaint.metadata!['reportUrl'] != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse(complaint.metadata!['reportUrl']);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    label: const Text('View Case Report'),
                  ),
                ],
              ],

              if (complaint.mediaUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Media:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: complaint.mediaUrls.map((url) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.broken_image);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (complaint.status != 'Resolved')
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _showVerifyDialog(context, complaint);
              },
              child: const Text('Verify Action'),
            ),
          if (complaint.status == 'In Progress' ||
              complaint.status == 'Verified')
            FilledButton(
              onPressed: () => _showResolveDialog(context, complaint),
              child: const Text('Resolve'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _showVerifyDialog(
    BuildContext context,
    ComplaintModel complaint,
  ) async {
    final actionController = TextEditingController();
    bool actionTaken = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Verify Action Taken'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('Action Taken'),
                value: actionTaken,
                onChanged: (value) {
                  actionTaken = value ?? false;
                },
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: actionController,
                decoration: const InputDecoration(
                  labelText: 'Action Details',
                  hintText: 'Describe the action taken',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (actionController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter action details'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                // Update complaint with verification
                await _complaintService.updateComplaintStatus(
                  complaint.id,
                  actionTaken ? 'In Progress' : complaint.status,
                );

                // You can add verification details to metadata
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        actionTaken
                            ? 'Action verified and complaint updated'
                            : 'Verification recorded',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    actionController.dispose();
  }

  Future<void> _showResolveDialog(
    BuildContext context,
    ComplaintModel complaint,
  ) async {
    final actionController = TextEditingController();
    File? selectedReport;
    String? selectedFileName;
    bool isResolving = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Resolve Complaint'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Provide details of the action taken and upload the final case report (PDF).',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: actionController,
                  decoration: const InputDecoration(
                    labelText: 'Action Taken',
                    hintText: 'Describe what was done to resolve this case...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Case Report (PDF/Doc)',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['pdf', 'doc', 'docx'],
                        );

                    if (result != null) {
                      setDialogState(() {
                        selectedReport = File(result.files.single.path!);
                        selectedFileName = result.files.single.name;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedReport != null
                              ? Icons.description
                              : Icons.upload_file,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedFileName ?? 'Select Case Report PDF',
                            style: TextStyle(
                              color: selectedFileName != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (selectedReport != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 20),
                            onPressed: () {
                              setDialogState(() {
                                selectedReport = null;
                                selectedFileName = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isResolving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isResolving
                  ? null
                  : () async {
                      if (actionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please describe the action taken'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isResolving = true);

                      try {
                        final appState = Provider.of<AppState>(
                          context,
                          listen: false,
                        );
                        final user = appState.currentUser;
                        if (user == null) throw Exception('User not logged in');

                        await _complaintService.resolveComplaintWithReport(
                          complaintId: complaint.id,
                          actionTaken: actionController.text.trim(),
                          reportFile: selectedReport,
                          resolverId: user.uid,
                          resolverName: user.name,
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Complaint successfully resolved with report',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isResolving = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              child: isResolving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Resolve Case'),
            ),
          ],
        ),
      ),
    );

    actionController.dispose();
  }
}
