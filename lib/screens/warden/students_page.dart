import 'package:flutter/material.dart';

class WardenStudentsPage extends StatelessWidget {
  const WardenStudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Students Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
