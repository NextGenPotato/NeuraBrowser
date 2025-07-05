import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:neura_browser/models/download.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadProvider with ChangeNotifier {
  late Box<Download> _downloadBox;

  List<Download> get downloads => _downloadBox.values.toList();

  DownloadProvider() {
    _init();
  }

  Future<void> _init() async {
    _downloadBox = await Hive.openBox<Download>('downloads');
    notifyListeners();
  }

  Future<void> startDownload(BuildContext context, String url) async {
    final status = await Permission.storage.request();
    if (status.isGranted) {
      final externalDir = await getExternalStorageDirectory();
      final filePath = '${externalDir?.path}/${url.split('/').last}';
      final download = Download(
        url: url,
        filePath: filePath,
        progress: 0.0,
        totalBytes: 0,
        receivedBytes: 0,
        status: 'Downloading',
      );
      final key = await _downloadBox.add(download);
      notifyListeners();

      try {
        await Dio().download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              final existingDownload = _downloadBox.get(key);
              if (existingDownload != null) {
                final updatedDownload = Download(
                  url: existingDownload.url,
                  filePath: existingDownload.filePath,
                  progress: progress,
                  totalBytes: total,
                  receivedBytes: received,
                  status: 'Downloading',
                );
                _downloadBox.put(key, updatedDownload);
                notifyListeners();
              }
            }
          },
        );
        final existingDownload = _downloadBox.get(key);
        if (existingDownload != null) {
          final updatedDownload = Download(
            url: existingDownload.url,
            filePath: existingDownload.filePath,
            progress: 1.0,
            totalBytes: existingDownload.totalBytes,
            receivedBytes: existingDownload.totalBytes,
            status: 'Completed',
          );
          _downloadBox.put(key, updatedDownload);
          notifyListeners();
        }
      } catch (e) {
        final existingDownload = _downloadBox.get(key);
        if (existingDownload != null) {
          final updatedDownload = Download(
            url: existingDownload.url,
            filePath: existingDownload.filePath,
            progress: existingDownload.progress,
            totalBytes: existingDownload.totalBytes,
            receivedBytes: existingDownload.receivedBytes,
            status: 'Failed',
          );
          _downloadBox.put(key, updatedDownload);
          notifyListeners();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading file: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission denied')),
      );
    }
  }
}
