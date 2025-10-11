import 'package:flutter/material.dart';

class AdminAwarenessPage extends StatefulWidget {
  const AdminAwarenessPage({super.key});

  @override
  State<AdminAwarenessPage> createState() => _AdminAwarenessPageState();
}

class _AdminAwarenessPageState extends State<AdminAwarenessPage>
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
          'Consent is a clear, enthusiastic, and ongoing agreement to engage in any activity.',
      'image': 'assets/images/consent.jpg',
      'category': 'Safety',
      'views': 1250,
      'likes': 89,
    },
    {
      'title': 'Cyber Safety',
      'subtitle': 'Protect yourself online',
      'content':
          'Be cautious about sharing personal information online and use strong passwords.',
      'image': 'assets/images/cyber_safety.jpg',
      'category': 'Digital Safety',
      'views': 980,
      'likes': 67,
    },
    {
      'title': 'Mental Health Support',
      'subtitle': 'Your wellbeing matters',
      'content':
          'It\'s okay to not be okay. Reach out to counselors when you need support.',
      'image': 'assets/images/mental_health.jpg',
      'category': 'Wellness',
      'views': 2100,
      'likes': 156,
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(context, color),
                  _buildContent(context),
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
                      'Awareness Management',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700, color: color),
                    ),
                    Text(
                      'Manage safety awareness content and campaigns',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _showAddContentDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Content'),
                style: FilledButton.styleFrom(backgroundColor: color),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Content',
                  '${_awarenessItems.length}',
                  Icons.library_books,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Views',
                  '${_awarenessItems.fold(0, (sum, item) => sum + (item['views'] as int))}',
                  Icons.visibility,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Likes',
                  '${_awarenessItems.fold(0, (sum, item) => sum + (item['likes'] as int))}',
                  Icons.favorite,
                  Colors.red,
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

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300, // Fixed height for carousel
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
        _buildContentList(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAwarenessCard(BuildContext context, Map<String, dynamic> item) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600 ? 20 : 16,
            vertical: constraints.maxWidth > 600 ? 10 : 8,
          ),
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
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(constraints.maxWidth > 600 ? 16 : 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(
                            constraints.maxWidth > 600 ? 10 : 8,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.school,
                            color: Theme.of(context).colorScheme.primary,
                            size: constraints.maxWidth > 600 ? 24 : 20,
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
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontSize: constraints.maxWidth > 600
                                          ? 20
                                          : 18,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item['subtitle'],
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                      fontSize: constraints.maxWidth > 600
                                          ? 14
                                          : 12,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: constraints.maxWidth > 600 ? 12 : 8),
                    Flexible(
                      child: Text(
                        item['content'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.3,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                          fontSize: constraints.maxWidth > 600 ? 13 : 11,
                        ),
                        maxLines: constraints.maxWidth > 600 ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: constraints.maxWidth > 600 ? 12 : 8),
                    Row(
                      children: [
                        Flexible(
                          child: _buildStatItem(
                            context,
                            'Views',
                            item['views'].toString(),
                            Icons.visibility,
                          ),
                        ),
                        SizedBox(width: constraints.maxWidth > 600 ? 12 : 8),
                        Flexible(
                          child: _buildStatItem(
                            context,
                            'Likes',
                            item['likes'].toString(),
                            Icons.favorite,
                          ),
                        ),
                        SizedBox(width: constraints.maxWidth > 600 ? 12 : 8),
                        Flexible(
                          child: _buildStatItem(
                            context,
                            'Category',
                            item['category'],
                            Icons.category,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: constraints.maxWidth > 600 ? 12 : 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _editContent(context, item),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: constraints.maxWidth > 600 ? 10 : 8,
                              ),
                            ),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: constraints.maxWidth > 600 ? 13 : 11,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: constraints.maxWidth > 600 ? 8 : 6),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => _shareContent(context, item),
                            style: FilledButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: constraints.maxWidth > 600 ? 10 : 8,
                              ),
                            ),
                            child: Text(
                              'Share',
                              style: TextStyle(
                                fontSize: constraints.maxWidth > 600 ? 13 : 11,
                              ),
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

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
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

  Widget _buildContentList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'All Content',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ..._awarenessItems.map(
            (item) => _buildContentListItem(context, item),
          ),
        ],
      ),
    );
  }

  Widget _buildContentListItem(
    BuildContext context,
    Map<String, dynamic> item,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
            child: Icon(
              Icons.school,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          title: Text(
            item['title'],
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text('${item['views']} views • ${item['likes']} likes'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editContent(context, item),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () => _deleteContent(context, item),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddContentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Content'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Subtitle',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
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
                  content: Text('Content added successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Add Content'),
          ),
        ],
      ),
    );
  }

  void _editContent(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item['title']}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Content updated successfully!')),
              );
            },
            child: const Text('Save Changes'),
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

  void _deleteContent(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content'),
        content: Text(
          'Are you sure you want to delete "${item['title']}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _awarenessItems.remove(item);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Content deleted successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
