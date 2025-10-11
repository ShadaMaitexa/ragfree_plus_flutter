import 'package:flutter/material.dart';

class PoliceAwarenessPage extends StatelessWidget {
  const PoliceAwarenessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Police Awareness Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
