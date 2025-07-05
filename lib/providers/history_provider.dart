import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:neura_browser/models/history.dart';

class HistoryProvider with ChangeNotifier {
  late Box<History> _historyBox;

  List<History> get history => _historyBox.values.toList();

  HistoryProvider() {
    _init();
  }

  Future<void> _init() async {
    _historyBox = await Hive.openBox<History>('history');
    notifyListeners();
  }

  Future<void> addToHistory(History history) async {
    await _historyBox.add(history);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _historyBox.clear();
    notifyListeners();
  }
}
