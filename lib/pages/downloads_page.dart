import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neura_browser/providers/download_provider.dart';
import 'package:provider/provider.dart';


class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final downloadProvider = Provider.of<DownloadProvider>(context);
    final downloads = downloadProvider.downloads;
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900] : Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Downloads',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: downloads.length,
        itemBuilder: (context, index) {
          final download = downloads[index];
          return ListTile(
            title: Text(
              download.url.split('/').last,
              style: TextStyle(color: darkMode ? Colors.white : Colors.black),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(download.receivedBytes / 1024 / 1024).toStringAsFixed(2)} MB / ${(download.totalBytes / 1024 / 1024).toStringAsFixed(2)} MB',
                  style: TextStyle(
                      color: darkMode ? Colors.grey : Colors.grey[600]),
                ),
                LinearProgressIndicator(value: download.progress),
              ],
            ),
            trailing: Text(
              download.status,
              style: TextStyle(
                  color: download.status == 'Completed'
                      ? Colors.green
                      : download.status == 'Failed'
                          ? Colors.red
                          : darkMode
                              ? Colors.white
                              : Colors.black),
            ),
          );
        },
      ),
    );
  }
}
