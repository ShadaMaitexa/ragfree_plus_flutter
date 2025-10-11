import 'package:flutter/material.dart';

class CounsellorChatPage extends StatelessWidget {
  const CounsellorChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Counsellor Chat Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
