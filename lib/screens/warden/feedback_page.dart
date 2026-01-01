import 'package:flutter/material.dart';

class WardenFeedbackPage extends StatelessWidget {
  const WardenFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hostel Feedback')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          final feedback = [
            {'user': 'Rahul S.', 'text': 'The hostel security needs more presence at night.', 'date': '2 days ago'},
            {'user': 'Anjali P.', 'text': 'Awareness session last week was very helpful.', 'date': '3 days ago'},
            {'user': 'Kevin M.', 'text': 'Emergency exit signs are missing on the 3rd floor.', 'date': '1 week ago'},
            {'user': 'Sneha R.', 'text': 'Request for more anti-ragging posters in the mess.', 'date': '1 week ago'},
            {'user': 'Vikram T.', 'text': 'The reporting process is smooth now.', 'date': '2 weeks ago'},
          ][index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person, size: 20)),
                      const SizedBox(width: 12),
                      Text(feedback['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(feedback['date']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(feedback['text']!, style: const TextStyle(height: 1.4)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
