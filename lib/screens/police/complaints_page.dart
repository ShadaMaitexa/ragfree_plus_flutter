import 'package:flutter/material.dart';

class PoliceComplaintsPage extends StatelessWidget {
  const PoliceComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Police Complaints Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
