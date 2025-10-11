import 'package:flutter/material.dart';

class PoliceGenerateReportPage extends StatelessWidget {
  const PoliceGenerateReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Generate Report Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
