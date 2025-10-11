import 'package:flutter/material.dart';

class ParentAwarenessPage extends StatefulWidget {
  const ParentAwarenessPage({super.key});

  @override
  State<ParentAwarenessPage> createState() => _ParentAwarenessPageState();
}

class _ParentAwarenessPageState extends State<ParentAwarenessPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, dynamic>> _awarenessItems = [
    {
      'title': 'Supporting Your Child',
      'subtitle': 'How to help during difficult times',
      'content':
          'Be a supportive listener, validate their feelings, and encourage them to seek help when needed. Your understanding and patience can make a significant difference.',
      'icon': Icons.family_restroom,
      'color': Colors.pink,
    },
    {
      'title': 'Recognizing Warning Signs',
      'subtitle': 'Know when your child needs help',
      'content':
          'Watch for changes in behavior, mood, sleep patterns, or academic performance. Early intervention can prevent more serious issues.',
      'icon': Icons.warning,
      'color': Colors.orange,
    },
    {
      'title': 'Communication Strategies',
      'subtitle': 'Effective ways to talk with your child',
      'content':
          'Create a safe space for open dialogue, ask open-ended questions, and listen without judgment. Regular check-ins can help maintain trust.',
      'icon': Icons.chat,
      'color': Colors.blue,
    },
    {
      'title': 'Campus Safety Resources',
      'subtitle': 'Available support services',
      'content':
          'Familiarize yourself with campus counseling services, emergency procedures, and support groups. Knowledge of resources helps you guide your child.',
      'icon': Icons.school,
      'color': Colors.green,
    },
    {
      'title': 'Mental Health Awareness',
      'subtitle': 'Understanding mental health challenges',
      'content':
          'Learn about common mental health issues in college students, their symptoms, and available treatments. Early recognition leads to better outcomes.',
      'icon': Icons.psychology,
      'color': Colors.purple,
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
                      'Parent Awareness Center',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      'Learn how to support your child\'s safety',
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
                  '20+',
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
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
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: item['color'],
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item['subtitle'],
                                style: Theme.of(context).textTheme.bodyMedium
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
                    SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
                    Flexible(
                      child: Text(
                        item['content'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        ),
                        maxLines: constraints.maxWidth > 600 ? 4 : 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: constraints.maxWidth > 600 ? 20 : 16),
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
        'icon': Icons.school,
        'title': 'Campus',
        'subtitle': 'Safety Office',
        'color': Colors.green,
        'onTap': () => _contactCampus(context),
      },
      {
        'icon': Icons.book,
        'title': 'Resources',
        'subtitle': 'More Info',
        'color': Colors.orange,
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
              const Text('• Parent support groups'),
              const Text('• Family counseling services'),
              const Text('• Crisis intervention resources'),
              const Text('• Educational workshops'),
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

  void _contactCampus(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Connecting to campus safety...'),
        backgroundColor: Colors.green,
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
            Text('• Parent Support Line: (555) 123-4570'),
            Text('• Emergency Services: 911'),
            SizedBox(height: 16),
            Text('Online Resources:'),
            Text('• Parent support groups'),
            Text('• Family counseling services'),
            Text('• Crisis intervention resources'),
            Text('• Educational workshops'),
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
