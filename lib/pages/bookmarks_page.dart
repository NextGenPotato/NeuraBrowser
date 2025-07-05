import 'package:flutter/material.dart';
import 'package:neura_browser/models/bookmark.dart';
import 'package:neura_browser/providers/bookmark_provider.dart';
import 'package:provider/provider.dart';


class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarks = bookmarkProvider.bookmarks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBookmarkDialog(context),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = bookmarks[index];
          return ListTile(
            leading: bookmark.favicon != null
                ? Image.network(bookmark.favicon!)
                : const Icon(Icons.bookmark),
            title: Text(bookmark.name),
            subtitle: Text(bookmark.url),
            onTap: () {
              // Handle tapping on a bookmark
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      _showEditBookmarkDialog(context, index, bookmark),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => bookmarkProvider.removeBookmark(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddBookmarkDialog(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Bookmark'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final url = urlController.text;
                if (name.isNotEmpty && url.isNotEmpty) {
                  Provider.of<BookmarkProvider>(context, listen: false)
                      .addBookmark(Bookmark(name: name, url: url));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditBookmarkDialog(
      BuildContext context, int index, Bookmark bookmark) {
    final nameController = TextEditingController(text: bookmark.name);
    final urlController = TextEditingController(text: bookmark.url);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Bookmark'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final url = urlController.text;
                if (name.isNotEmpty && url.isNotEmpty) {
                  Provider.of<BookmarkProvider>(context, listen: false)
                      .updateBookmark(
                          index, Bookmark(name: name, url: url));
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
