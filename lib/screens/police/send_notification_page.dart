import 'package:flutter/material.dart';

class PoliceSendNotificationPage extends StatelessWidget {
  const PoliceSendNotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Send Notification Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
