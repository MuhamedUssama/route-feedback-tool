import 'package:flutter/material.dart';
import 'package:mentor_assistant/core/widgets/custom_appbar.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Feedback'),
      body: const Center(child: Text('Feedback Content')),
    );
  }
}
