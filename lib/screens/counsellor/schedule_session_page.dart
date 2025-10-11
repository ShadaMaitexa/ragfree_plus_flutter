import 'package:flutter/material.dart';

class CounsellorScheduleSessionPage extends StatelessWidget {
  const CounsellorScheduleSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Schedule Session Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
