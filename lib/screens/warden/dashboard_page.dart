import 'package:flutter/material.dart';

class WardenDashboardPage extends StatelessWidget {
  const WardenDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Warden Dashboard Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
