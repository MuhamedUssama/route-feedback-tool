import 'package:flutter/material.dart';
import 'package:mentor_assistant/core/widgets/custom_appbar.dart';

class FollowUpScreen extends StatelessWidget {
  const FollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Follow Up'),
      body: const Center(child: Text('Follow Up Content')),
    );
  }
}
