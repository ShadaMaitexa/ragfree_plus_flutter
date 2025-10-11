import 'package:flutter/material.dart';

class PoliceDashboardPage extends StatelessWidget {
  const PoliceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Police Dashboard Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
