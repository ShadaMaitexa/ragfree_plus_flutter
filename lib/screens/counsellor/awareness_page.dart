import 'package:flutter/material.dart';

class CounsellorAwarenessPage extends StatelessWidget {
  const CounsellorAwarenessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Counsellor Awareness Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
