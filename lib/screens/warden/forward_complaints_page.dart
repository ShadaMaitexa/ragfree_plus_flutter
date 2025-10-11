import 'package:flutter/material.dart';

class WardenForwardComplaintsPage extends StatelessWidget {
  const WardenForwardComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Forward Complaints Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
