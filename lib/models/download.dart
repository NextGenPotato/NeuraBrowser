import 'package:hive/hive.dart';

part 'download.g.dart';

@HiveType(typeId: 2)
class Download {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final String filePath;

  @HiveField(2)
  final double progress;

  @HiveField(3)
  final int totalBytes;

  @HiveField(4)
  final int receivedBytes;

  @HiveField(5)
  final String status;

  Download({
    required this.url,
    required this.filePath,
    required this.progress,
    required this.totalBytes,
    required this.receivedBytes,
    required this.status,
  });
}
