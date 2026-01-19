import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/feedback_service.dart';
import '../../services/app_state.dart';
import '../../models/feedback_model.dart';

class ParentFeedbackPage extends StatefulWidget {
  const ParentFeedbackPage({super.key});

  @override
  State<ParentFeedbackPage> createState() => _ParentFeedbackPageState();
}

class _ParentFeedbackPageState extends State<ParentFeedbackPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  double _rating = 5;
  String _selectedCategory = 'Safety Monitoring';
  bool _isSubmitting = false;
  final FeedbackService _feedbackService = FeedbackService();

  final List<String> _categories = [
    'Safety Monitoring',
    'App Experience',
    'Response Time',
    'Campus Protocols',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final user = appState.currentUser;

      if (user == null) throw Exception('User not logged in');

      final feedback = FeedbackModel(
        id: '',
        userId: user.uid,
        userName: user.name,
        userRole: user.role,
        content: _contentController.text.trim(),
        rating: _rating,
        category: _selectedCategory,
        createdAt: DateTime.now(),
      );

      await _feedbackService.submitFeedback(feedback);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Colors.green,
          ),
        );
        _contentController.clear();
        _tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Send'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildForm(context, color),
          _buildHistory(context),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context, Color color) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Guardian Feedback',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your perspective as a parent is vital. Share your thoughts on how we can improve safety and communication.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            Text(
              'Rate your experience with the platform',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() => _rating = index + 1.0);
                        },
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                      );
                    }),
                  ),
                  Text(
                    'Rating: $_rating / 5.0',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Feedback Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Describe your suggestions or concerns...',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter your message';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submitFeedback,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Send Feedback'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistory(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser!;

    return StreamBuilder<List<FeedbackModel>>(
      stream: _feedbackService.getUserFeedback(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final feedbacks = snapshot.data!;
        if (feedbacks.isEmpty) {
          return const Center(child: Text('No feedback submitted yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: feedbacks.length,
          itemBuilder: (context, index) {
            final f = feedbacks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Row(
                  children: [
                    Text(f.category ?? 'General', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    ...List.generate(5, (i) => Icon(
                      i < f.rating ? Icons.star : Icons.star_border,
                      size: 14,
                      color: Colors.amber,
                    )),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(f.content),
                    const SizedBox(height: 4),
                    Text(
                      'Submitted on: ${f.createdAt.toLocal().toString().split('.')[0]}',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
