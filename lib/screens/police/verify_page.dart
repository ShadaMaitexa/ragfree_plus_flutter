import 'package:flutter/material.dart';
import '../../services/complaint_service.dart';
import '../../models/complaint_model.dart';
import 'package:intl/intl.dart';

class PoliceVerifyPage extends StatefulWidget {
  const PoliceVerifyPage({super.key});

  @override
  State<PoliceVerifyPage> createState() => _PoliceVerifyPageState();
}

class _PoliceVerifyPageState extends State<PoliceVerifyPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ComplaintService _complaintService = ComplaintService();

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
            child: Column(
              children: [
                _buildHeader(context, color),
                Expanded(
                  child: _buildComplaintsContent(context),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.verified_user, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify Actions',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      'Verify actions taken on complaints',
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
        ],
      ),
    );
  }

  Widget _buildComplaintsContent(BuildContext context) {
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
        final complaints = snapshot.data ?? [];
        // Filter to show only complaints that need verification (In Progress or Pending)
        final pendingVerification = complaints
            .where((c) => c.status == 'In Progress' || c.status == 'Pending')
            .toList();

        if (pendingVerification.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user, size: 64, color: Colors.grey),
                const SizedBox(height: 24),
                Text(
                  'No Complaints Pending Verification',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'All complaints have been verified',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth > 600 ? 40 : 20,
              ),
              itemCount: pendingVerification.length,
              itemBuilder: (context, index) {
                return _buildComplaintCard(context, pendingVerification[index], index);
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
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
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
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: priorityColor.withOpacity(0.3),
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
                      ).colorScheme.onSurface.withOpacity(0.6),
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
                  ).colorScheme.onSurface.withOpacity(0.7),
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
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    complaint.isAnonymous
                        ? 'Anonymous'
                        : (complaint.studentName ?? 'Unknown'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.category,
                    size: 16,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      complaint.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showVerifyDialog(context, complaint, false),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _showVerifyDialog(context, complaint, true),
                      icon: const Icon(Icons.check),
                      label: const Text('Verify'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showVerifyDialog(
    BuildContext context,
    ComplaintModel complaint,
    bool verified,
  ) async {
    final notesController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(verified ? 'Verify Action' : 'Reject Action'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                verified
                    ? 'Confirm that appropriate action has been taken on this complaint?'
                    : 'Are you sure you want to reject this action?',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: verified ? 'Verification Notes' : 'Rejection Reason',
                  hintText: verified
                      ? 'Add any notes about the verification'
                      : 'Explain why this action is being rejected',
                  border: const OutlineInputBorder(),
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
              try {
                if (verified) {
                  // Mark as verified - you can update status or add verification metadata
                  await _complaintService.updateComplaintStatus(
                    complaint.id,
                    'In Progress',
                  );
                } else {
                  // Reject - keep as pending or update status
                  await _complaintService.updateComplaintStatus(
                    complaint.id,
                    'Pending',
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(verified
                          ? 'Action verified successfully'
                          : 'Action rejected'),
                      backgroundColor: verified ? Colors.green : Colors.orange,
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
            style: FilledButton.styleFrom(
              backgroundColor: verified ? Colors.green : Colors.red,
            ),
            child: Text(verified ? 'Verify' : 'Reject'),
          ),
        ],
      ),
    );

    notesController.dispose();
  }
}

