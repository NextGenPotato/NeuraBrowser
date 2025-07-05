import 'package:flutter/material.dart';

class DownloadManagerPage extends StatelessWidget {
  const DownloadManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Downloads")),
      body: Center(child: Text("Downloaded files will be listed here.")),
    );
  }
}
