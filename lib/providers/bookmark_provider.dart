import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:neura_browser/models/bookmark.dart';

class BookmarkProvider with ChangeNotifier {
  late Box<Bookmark> _bookmarkBox;

  List<Bookmark> get bookmarks => _bookmarkBox.values.toList();

  BookmarkProvider() {
    _init();
  }

  Future<void> _init() async {
    _bookmarkBox = await Hive.openBox<Bookmark>('bookmarks');
    notifyListeners();
  }

  Future<void> addBookmark(Bookmark bookmark) async {
    await _bookmarkBox.add(bookmark);
    notifyListeners();
  }

  Future<void> removeBookmark(int index) async {
    await _bookmarkBox.deleteAt(index);
    notifyListeners();
  }

  Future<void> updateBookmark(int index, Bookmark bookmark) async {
    await _bookmarkBox.putAt(index, bookmark);
    notifyListeners();
  }

  Future<void> clearBookmarks() async {
    await _bookmarkBox.clear();
    notifyListeners();
  }
}
