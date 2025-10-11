import 'package:flutter/material.dart';

class WardenFeedbackPage extends StatelessWidget {
  const WardenFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Warden Feedback Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
