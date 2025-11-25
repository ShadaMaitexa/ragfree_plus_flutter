import 'package:flutter/material.dart';

class TeacherAwarenessPage extends StatefulWidget {
  const TeacherAwarenessPage({super.key});

  @override
  State<TeacherAwarenessPage> createState() => _TeacherAwarenessPageState();
}

class _TeacherAwarenessPageState extends State<TeacherAwarenessPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _awarenessItems = [
    {
      'title': 'Student Safety Guidelines',
      'subtitle': 'Supporting student wellbeing',
      'content':
          'As a teacher, you play a crucial role in maintaining campus safety. Be observant, listen to students, and report any concerns immediately.',
      'icon': Icons.school,
      'color': Colors.blue,
    },
    {
      'title': 'Recognizing Signs of Distress',
      'subtitle': 'Identifying students who need help',
      'content':
          'Watch for changes in behavior, attendance, or academic performance. These may indicate a student needs support or intervention.',
      'icon': Icons.psychology,
      'color': Colors.purple,
    },
    {
      'title': 'Reporting Procedures',
      'subtitle': 'How to report incidents',
      'content':
          'If you witness or learn about harassment, bullying, or safety concerns, report them through the app immediately. Your reports are confidential.',
      'icon': Icons.report,
      'color': Colors.orange,
    },
    {
      'title': 'Creating Safe Spaces',
      'subtitle': 'Fostering inclusive environments',
      'content':
          'Create an environment where all students feel safe, respected, and valued. Encourage open communication and mutual respect.',
      'icon': Icons.people,
      'color': Colors.green,
    },
  ];

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
                  child: _buildAwarenessContent(context),
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
      child: Row(
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
                  'Safety Awareness',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'Resources for supporting student safety',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAwarenessContent(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _awarenessItems.length,
      itemBuilder: (context, index) {
        final item = _awarenessItems[index];
        return _buildAwarenessCard(context, item);
      },
    );
  }

  Widget _buildAwarenessCard(
      BuildContext context, Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (item['color'] as Color).withOpacity(0.1),
              (item['color'] as Color).withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (item['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: item['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] as String,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Text(
                        item['subtitle'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              item['content'] as String,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}


