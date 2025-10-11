import 'package:flutter/material.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Reports Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
