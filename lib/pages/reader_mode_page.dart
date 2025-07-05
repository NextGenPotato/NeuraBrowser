import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

class ReaderModePage extends StatelessWidget {
  final String htmlContent;

  const ReaderModePage({super.key, required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Reader Mode',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Html(
          data: htmlContent,
          style: {
            "body": Style(
              fontSize: FontSize(18.0),
              color: darkMode ? Colors.white : Colors.black,
            ),
          },
        ),
      ),
    );
  }
}
