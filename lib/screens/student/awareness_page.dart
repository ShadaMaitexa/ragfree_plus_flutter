import 'package:flutter/material.dart';

class StudentAwarenessPage extends StatefulWidget {
  const StudentAwarenessPage({super.key});

  @override
  State<StudentAwarenessPage> createState() => _StudentAwarenessPageState();
}

class _StudentAwarenessPageState extends State<StudentAwarenessPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _awarenessItems = [
    {
      'title': 'Understanding Consent',
      'subtitle': 'Learn about boundaries and respect',
      'content':
          'Consent is a clear, enthusiastic, and ongoing agreement to engage in any activity. It must be freely given, reversible, informed, enthusiastic, and specific.',
      'icon': Icons.favorite,
      'color': Colors.pink,
      'image': 'assets/images/consent.jpg',
    },
    {
      'title': 'Cyber Safety',
      'subtitle': 'Protect yourself online',
      'content':
          'Be cautious about sharing personal information online. Use strong passwords, be aware of phishing attempts, and think before you post.',
      'icon': Icons.security,
      'color': Colors.blue,
      'image': 'assets/images/cyber_safety.jpg',
    },
    {
      'title': 'Mental Health Support',
      'subtitle': 'Your wellbeing matters',
      'content':
          'It\'s okay to not be okay. Reach out to counselors, friends, or family when you need support. Mental health is just as important as physical health.',
      'icon': Icons.psychology,
      'color': Colors.green,
      'image': 'assets/images/mental_health.jpg',
    },
    {
      'title': 'Reporting Procedures',
      'subtitle': 'Know your rights and options',
      'content':
          'If you experience harassment, bullying, or discrimination, you have the right to report it. The process is confidential and designed to protect you.',
      'icon': Icons.report,
      'color': Colors.orange,
      'image': 'assets/images/reporting.jpg',
    },
    {
      'title': 'Campus Safety',
      'subtitle': 'Stay safe on campus',
      'content':
          'Be aware of your surroundings, use well-lit paths at night, and don\'t hesitate to call campus security if you feel unsafe. Your safety is our priority.',
      'icon': Icons.shield,
      'color': Colors.purple,
      'image': 'assets/images/campus_safety.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pageController = PageController();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
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
                Expanded(child: _buildAwarenessContent(context)),
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
                child: Icon(Icons.school, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Awareness Center',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      'Learn about safety, rights, and support',
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Topics',
                  '${_awarenessItems.length}',
                  Icons.topic,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Resources',
                  '15+',
                  Icons.library_books,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Support',
                  '24/7',
                  Icons.support_agent,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: Icon(icon, color: color, size: 18)),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
      ),
    );
  }

  Widget _buildAwarenessContent(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _awarenessItems.length,
            itemBuilder: (context, index) {
              final item = _awarenessItems[index];
              return _buildAwarenessCard(context, item);
            },
          ),
        ),
        _buildPageIndicator(context),
        const SizedBox(height: 20),
        _buildQuickActions(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAwarenessCard(BuildContext context, Map<String, dynamic> item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    item['color'].withOpacity(0.1),
                    item['color'].withOpacity(0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                            constraints.maxWidth > 600 ? 16 : 12,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: item['color'].withOpacity(0.1),
                          ),
                          child: Icon(
                            item['icon'],
                            color: item['color'],
                            size: constraints.maxWidth > 600 ? 32 : 24,
                          ),
                        ),
                        SizedBox(width: constraints.maxWidth > 600 ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'],
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: item['color'],
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item['subtitle'],
                                style: Theme.of(context).textTheme.titleMedium
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
                      ],
                    ),
                    SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                    Flexible(
                      child: Text(
                        item['content'],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        ),
                        maxLines: constraints.maxWidth > 600 ? 4 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: constraints.maxWidth > 600 ? 24 : 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showMoreInfo(context, item),
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Learn More'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: item['color'],
                              side: BorderSide(color: item['color']),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => _shareContent(context, item),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            style: FilledButton.styleFrom(
                              backgroundColor: item['color'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _awarenessItems.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'icon': Icons.phone,
        'title': 'Emergency',
        'subtitle': 'Call 911',
        'color': Colors.red,
        'onTap': () => _callEmergency(context),
      },
      {
        'icon': Icons.support_agent,
        'title': 'Counselor',
        'subtitle': 'Get Support',
        'color': Colors.blue,
        'onTap': () => _contactCounselor(context),
      },
      {
        'icon': Icons.report,
        'title': 'Report',
        'subtitle': 'File Complaint',
        'color': Colors.orange,
        'onTap': () => _fileReport(context),
      },
      {
        'icon': Icons.book,
        'title': 'Resources',
        'subtitle': 'More Info',
        'color': Colors.green,
        'onTap': () => _showResources(context),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
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
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
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
      ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
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
                Flexible(child: Icon(icon, color: color, size: 20)),
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

  void _showMoreInfo(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(item['icon'], color: item['color']),
            const SizedBox(width: 8),
            Text(item['title']),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item['subtitle'],
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: item['color']),
              ),
              const SizedBox(height: 16),
              Text(item['content']),
              const SizedBox(height: 16),
              const Text(
                'Additional Resources:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text('• Campus counseling services'),
              const Text('• Online safety guidelines'),
              const Text('• Support group meetings'),
              const Text('• Emergency contact numbers'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _shareContent(context, item);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _shareContent(BuildContext context, Map<String, dynamic> item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${item['title']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _callEmergency(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Call'),
          ],
        ),
        content: const Text('This will call emergency services. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Calling emergency services...'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Call 911'),
          ),
        ],
      ),
    );
  }

  void _contactCounselor(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connecting to counselor...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _fileReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening report form...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showResources(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Additional Resources'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Campus Safety Office: (555) 123-4567'),
            Text('• Counseling Center: (555) 123-4568'),
            Text('• Title IX Coordinator: (555) 123-4569'),
            Text('• Emergency Services: 911'),
            SizedBox(height: 16),
            Text('Online Resources:'),
            Text('• Campus safety guidelines'),
            Text('• Mental health resources'),
            Text('• Reporting procedures'),
            Text('• Support groups'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
