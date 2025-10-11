import 'package:flutter/material.dart';

class CounsellorAssignedComplaintsPage extends StatelessWidget {
  const CounsellorAssignedComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Assigned Complaints Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
