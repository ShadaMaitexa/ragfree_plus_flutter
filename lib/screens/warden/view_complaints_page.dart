import 'package:flutter/material.dart';

class WardenViewComplaintsPage extends StatelessWidget {
  const WardenViewComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'View Complaints Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
