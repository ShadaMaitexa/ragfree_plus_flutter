import 'package:flutter/material.dart';

class WardenAwarenessPage extends StatelessWidget {
  const WardenAwarenessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Warden Awareness Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
