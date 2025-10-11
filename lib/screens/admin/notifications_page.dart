import 'package:flutter/material.dart';

class AdminNotificationsPage extends StatelessWidget {
  const AdminNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Notifications Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
