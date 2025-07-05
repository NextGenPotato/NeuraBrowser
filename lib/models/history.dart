import 'package:hive/hive.dart';

part 'history.g.dart';

@HiveType(typeId: 1)
class History {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final DateTime timestamp;

  History({required this.title, required this.url, required this.timestamp});
}
