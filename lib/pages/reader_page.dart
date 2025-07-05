import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class ReaderPage extends StatelessWidget {
  final String content;
  const ReaderPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reader Mode')),
      body: SingleChildScrollView(child: Html(data: content)),
    );
  }
}
