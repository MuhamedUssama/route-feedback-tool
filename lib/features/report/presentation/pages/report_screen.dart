import 'package:flutter/material.dart';
import 'package:mentor_assistant/core/widgets/custom_appbar.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Report'),
      body: const Center(child: Text('Report Content')),
    );
  }
}
