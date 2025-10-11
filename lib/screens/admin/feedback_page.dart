import 'package:flutter/material.dart';

class AdminFeedbackPage extends StatelessWidget {
  const AdminFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Feedback Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
