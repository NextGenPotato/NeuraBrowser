import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:neura_browser/providers/history_provider.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatelessWidget {
  final Function(String) onGoToUrl;

  const HistoryPage({
    super.key,
    required this.onGoToUrl,
  });

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    final historyProvider = Provider.of<HistoryProvider>(context);
    final history = historyProvider.history;

    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900] : Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'History',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: history.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final historyItem = history[index];
          return ListTile(
            leading: const Icon(Icons.web),
            title: Text(
              historyItem.title,
              style: TextStyle(color: darkMode ? Colors.white : Colors.black),
            ),
            subtitle: Text(
              historyItem.url,
              style: TextStyle(color: darkMode ? Colors.grey : Colors.grey[600]),
            ),
            onTap: () {
              onGoToUrl(historyItem.url);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
