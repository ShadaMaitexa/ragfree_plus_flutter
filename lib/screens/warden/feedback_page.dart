import 'package:flutter/material.dart';
import '../../services/feedback_service.dart';
import '../../models/feedback_model.dart';
import 'package:intl/intl.dart';

class WardenFeedbackPage extends StatefulWidget {
  const WardenFeedbackPage({super.key});

  @override
  State<WardenFeedbackPage> createState() => _WardenFeedbackPageState();
}

class _WardenFeedbackPageState extends State<WardenFeedbackPage> {
  final FeedbackService _feedbackService = FeedbackService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Feedback')),
      body: StreamBuilder<List<FeedbackModel>>(
        stream: _feedbackService.getAllFeedback(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No feedback received yet.'));
          }

          final feedbacks = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: feedbacks.length,
            itemBuilder: (context, index) {
              final f = feedbacks[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.withValues(alpha: 0.1),
                    child: Text(
                      f.rating.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  title: Text(
                    f.category ?? 'General Feedback',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${f.userName} (${f.userRole}) • ${DateFormat('MMM dd').format(f.createdAt)}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Comment:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(f.content),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ...List.generate(5, (i) {
                                return Icon(
                                  i < f.rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 20,
                                );
                              }),
                              const Spacer(),
                              Text(
                                f.createdAt.toString().split('.')[0],
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
