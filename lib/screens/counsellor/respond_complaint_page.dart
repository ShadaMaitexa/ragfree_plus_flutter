import 'package:flutter/material.dart';

class CounsellorRespondComplaintPage extends StatelessWidget {
  const CounsellorRespondComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Respond Complaint Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
