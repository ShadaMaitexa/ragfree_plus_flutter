import 'package:flutter/material.dart';
import '../../services/awareness_service.dart';
import '../../models/awareness_model.dart';

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
  final AwarenessService _awarenessService = AwarenessService();

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
                    ? [color.withValues(alpha: 0.05), Colors.transparent]
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
                  color: color.withValues(alpha: 0.1),
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
                      ' Awareness ',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      'Learn how to support your child\'s safety',
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
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Topics',
                  '—',
                  Icons.topic,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Resources',
                  '—',
                  Icons.library_books,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Support',
                  'On Campus',
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAwarenessContent(BuildContext context) {
    return StreamBuilder<List<AwarenessModel>>(
      stream: _awarenessService.getAwarenessForRole('parent'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline,
                            size: 56, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No awareness content yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Once your institution publishes guidance for parents, it will appear here.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _buildQuickActions(context),
              const SizedBox(height: 20),
            ],
          );
        }

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
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildAwarenessCard(context, item, index);
                },
              ),
            ),
            _buildPageIndicator(context, items.length),
            const SizedBox(height: 20),
            _buildQuickActions(context),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildAwarenessCard(
    BuildContext context,
    AwarenessModel item,
    int index,
  ) {
    final colors = [
      Colors.pink,
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
    ];
    final color = colors[index % colors.length];
    final icon = Icons.family_restroom;
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
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.05),
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
                            color: color.withValues(alpha: 0.1),
                          ),
                          child: Icon(
                            icon,
                            color: color,
                            size: constraints.maxWidth > 600 ? 32 : 24,
                          ),
                        ),
                        SizedBox(width: constraints.maxWidth > 600 ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: color,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.subtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
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
                        item.content,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.4,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
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
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'More about ${item.title} coming from your institution.'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.info_outline),
                            label: const Text('Learn More'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: color,
                              side: BorderSide(color: color),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Sharing "${item.title}"'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            style: FilledButton.styleFrom(
                              backgroundColor: color,
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

  Widget _buildPageIndicator(BuildContext context, int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
              colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
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
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
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
