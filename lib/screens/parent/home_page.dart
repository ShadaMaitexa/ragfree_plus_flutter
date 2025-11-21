import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/app_state.dart';
import '../../services/parent_student_service.dart';
import '../../models/parent_student_link_model.dart';

class ParentHomePage extends StatefulWidget {
  const ParentHomePage({super.key});

  @override
  State<ParentHomePage> createState() => _ParentHomePageState();
}

class _ParentHomePageState extends State<ParentHomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final ParentStudentService _parentStudentService = ParentStudentService();

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

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
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
          child: SlideTransition(
            position: _slideAnimation,
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
                    _buildWelcomeCard(context, color),
                    const SizedBox(height: 24),
                    _buildChildSafetySummary(context, color),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, color),
                    const SizedBox(height: 24),
                    _buildNotifications(context),
                    const SizedBox(height: 24),
                    _buildRecentActivity(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.family_restroom,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Consumer<AppState>(
                      builder: (context, appState, _) {
                        final userName = appState.currentUser?.name ?? 'User';
                        return Text(
                          userName,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Stay connected with your child\'s safety and wellbeing on campus.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSafetySummary(BuildContext context, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Child Safety Summary',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: color),
              onPressed: () => _showLinkStudentDialog(context),
              tooltip: 'Link Student',
            ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<ParentStudentLinkModel>>(
          stream: _getLinkedStudentsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final links = snapshot.data ?? [];
            if (links.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.link_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No Linked Students',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Link your child\'s account to monitor their safety',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => _showLinkStudentDialog(context),
                        icon: const Icon(Icons.link),
                        label: const Text('Link Student Account'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: links.length,
                  itemBuilder: (context, index) {
                    final link = links[index];
                    return _buildSafetyCard(
                      context,
                      link.studentName,
                      link.studentEmail,
                      link.relationship,
                      _getColorForIndex(index),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  Stream<List<ParentStudentLinkModel>> _getLinkedStudentsStream() {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user == null || user.role != 'parent') {
      return Stream.value([]);
    }
    return _parentStudentService.getLinkedStudents(user.uid);
  }

  Color _getColorForIndex(int index) {
    final colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];
    return colors[index % colors.length];
  }

  Future<void> _showLinkStudentDialog(BuildContext context) async {
    final emailController = TextEditingController();
    final relationshipController = TextEditingController();
    String selectedRelationship = 'Mother';
    final relationships = ['Mother', 'Father', 'Guardian', 'Other'];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Link Student Account'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Student Email',
                  hintText: 'Enter your child\'s registered email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRelationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
                items: relationships.map((rel) {
                  return DropdownMenuItem(value: rel, child: Text(rel));
                }).toList(),
                onChanged: (value) {
                  selectedRelationship = value ?? 'Mother';
                },
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
              if (emailController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter student email'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final appState = Provider.of<AppState>(context, listen: false);
                final user = appState.currentUser;

                if (user != null) {
                  await _parentStudentService.linkStudent(
                    parentId: user.uid,
                    parentName: user.name,
                    studentEmail: emailController.text.trim(),
                    relationship: selectedRelationship,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Student linked successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: ${e.toString().replaceAll('Exception: ', '')}',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Link'),
          ),
        ],
      ),
    );

    emailController.dispose();
    relationshipController.dispose();
  }

  Widget _buildSafetyCard(
    BuildContext context,
    String name,
    String email,
    String relationship,
    Color color,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(constraints.maxWidth > 600 ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: constraints.maxWidth > 600 ? 24 : 20,
                        backgroundColor: color.withOpacity(0.2),
                        child: Text(
                          name
                              .split(' ')
                              .map((n) => n.isNotEmpty ? n[0] : '')
                              .join()
                              .toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: constraints.maxWidth > 600 ? 16 : 14,
                          ),
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth > 600 ? 16 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '$relationship • $email',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth > 600 ? 10 : 8,
                          vertical: constraints.maxWidth > 600 ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Safe',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: constraints.maxWidth > 600 ? 16 : 12),
                  LayoutBuilder(
                    builder: (context, cardConstraints) {
                      return Row(
                        children: [
                          Flexible(
                            child: _buildStatusItem(
                              context,
                              'Reports',
                              '2',
                              Colors.blue,
                            ),
                          ),
                          SizedBox(
                            width: cardConstraints.maxWidth > 400 ? 16 : 12,
                          ),
                          Flexible(
                            child: _buildStatusItem(
                              context,
                              'Resolved',
                              '1',
                              Colors.green,
                            ),
                          ),
                          SizedBox(
                            width: cardConstraints.maxWidth > 400 ? 16 : 12,
                          ),
                          Flexible(
                            child: _buildStatusItem(
                              context,
                              'Active',
                              '1',
                              Colors.orange,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, Color color) {
    final actions = [
      {
        'icon': Icons.assignment,
        'title': 'View Reports',
        'subtitle': 'Child Complaints',
        'color': Colors.blue,
        'onTap': () => _navigateToReports(context),
      },
      {
        'icon': Icons.chat,
        'title': 'Chat',
        'subtitle': 'With Counselors',
        'color': Colors.green,
        'onTap': () => _navigateToChat(context),
      },
      {
        'icon': Icons.school,
        'title': 'Awareness',
        'subtitle': 'Safety Tips',
        'color': Colors.orange,
        'onTap': () => _navigateToAwareness(context),
      },
      {
        'icon': Icons.notifications,
        'title': 'Alerts',
        'subtitle': 'Emergency',
        'color': Colors.red,
        'onTap': () => _showEmergencyAlerts(context),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive grid based on screen width
            int crossAxisCount = 2;
            double childAspectRatio = 1.5;

            if (constraints.maxWidth > 600) {
              crossAxisCount = 4;
              childAspectRatio = 1.2;
            } else if (constraints.maxWidth > 400) {
              crossAxisCount = 2;
              childAspectRatio = 1.3;
            } else {
              crossAxisCount = 2;
              childAspectRatio = 1.4;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return _buildActionCard(
                  context,
                  action['icon'] as IconData,
                  action['title'] as String,
                  action['subtitle'] as String,
                  action['color'] as Color,
                  action['onTap'] as VoidCallback,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.1),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotifications(BuildContext context) {
    final notifications = [
      {
        'title': 'Emma\'s Report Resolved',
        'message': 'The harassment complaint filed by Emma has been resolved.',
        'time': '2 hours ago',
        'type': 'success',
        'icon': Icons.check_circle,
      },
      {
        'title': 'Alex Safety Check',
        'message': 'Alex is safe and accounted for on campus.',
        'time': '1 day ago',
        'type': 'info',
        'icon': Icons.verified_user,
      },
      {
        'title': 'New Safety Alert',
        'message':
            'Campus security has issued a safety alert for the library area.',
        'time': '2 days ago',
        'type': 'warning',
        'icon': Icons.warning,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Notifications',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: notifications.map((notification) {
              return _buildNotificationItem(context, notification);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    Map<String, dynamic> notification,
  ) {
    Color color;
    switch (notification['type']) {
      case 'success':
        color = Colors.green;
        break;
      case 'warning':
        color = Colors.orange;
        break;
      case 'info':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
        ),
        child: Icon(notification['icon'], color: color, size: 20),
      ),
      title: Text(
        notification['title'],
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(notification['message']),
      trailing: Text(
        notification['time'],
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildActivityItem(
                context,
                Icons.assignment,
                'Emma filed a new complaint',
                'Harassment incident reported in library',
                Colors.blue,
                '3 hours ago',
              ),
              const Divider(height: 1),
              _buildActivityItem(
                context,
                Icons.chat,
                'Chat with counselor',
                'Dr. Smith responded to your message',
                Colors.green,
                '1 day ago',
              ),
              const Divider(height: 1),
              _buildActivityItem(
                context,
                Icons.school,
                'Safety awareness',
                'New safety guidelines published',
                Colors.orange,
                '2 days ago',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    String time,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }

  void _navigateToReports(BuildContext context) {
    // Navigate to reports tab
    DefaultTabController.of(context).animateTo(1);
  }

  void _navigateToChat(BuildContext context) {
    // Navigate to chat tab
    DefaultTabController.of(context).animateTo(2);
  }

  void _navigateToAwareness(BuildContext context) {
    // Navigate to awareness tab
    DefaultTabController.of(context).animateTo(3);
  }

  void _showEmergencyAlerts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Alerts'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Status: All Clear'),
            SizedBox(height: 16),
            Text('Recent Alerts:'),
            Text('• Campus security alert - Library area'),
            Text('• Weather warning - Heavy rain expected'),
            Text('• Maintenance notice - Building A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Emergency contacts notified'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Alert Emergency'),
          ),
        ],
      ),
    );
  }
}
