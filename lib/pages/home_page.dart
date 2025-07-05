import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:neura_browser/providers/tab_provider.dart';
import 'package:neura_browser/pages/tabs_page.dart';
import 'package:neura_browser/providers/download_provider.dart';
import 'package:neura_browser/pages/reader_mode_page.dart';
import 'package:neura_browser/providers/theme_provider.dart';
import 'package:neura_browser/models/history.dart';
import 'package:neura_browser/providers/history_provider.dart';
import 'package:neura_browser/widgets/floating_nav_bar.dart';
import 'package:neura_browser/providers/bookmark_provider.dart';
import 'package:neura_browser/models/bookmark.dart';
import 'package:neura_browser/pages/settings_page.dart';
import 'package:neura_browser/widgets/home_page_header.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isFullScreen = false;
  bool _incognitoLock = false;
  final ScrollController _scrollController = ScrollController();
  bool _showNavBar = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 100 && _showNavBar) {
        setState(() {
          _showNavBar = false;
        });
      } else if (_scrollController.position.pixels < 100 && !_showNavBar) {
        setState(() {
          _showNavBar = true;
        });
      }
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _incognitoLock = prefs.getBool('incognitoLock') ?? false;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('incognitoLock', _incognitoLock);
  }

  void _goToUrl(TabProvider tabProvider) {
    final url = tabProvider.currentTab.urlController.text.trim();
    if (url.isNotEmpty) {
      tabProvider.loadUrl(url);
    }
  }

  Future<void> _goBack(TabProvider tabProvider) async {
    if (await tabProvider.currentTab.controller.canGoBack()) {
      tabProvider.currentTab.controller.goBack();
    }
  }

  Future<void> _goForward(TabProvider tabProvider) async {
    if (await tabProvider.currentTab.controller.canGoForward()) {
      tabProvider.currentTab.controller.goForward();
    }
  }

  Future<void> _refresh(TabProvider tabProvider) async {
    await tabProvider.currentTab.controller.reload();
  }

  void _addToHistory(TabData tab) {
    if (tab.urlController.text.isNotEmpty && !tab.isIncognito) {
      final history = History(
        title: tab.title,
        url: tab.urlController.text,
        timestamp: DateTime.now(),
      );
      Provider.of<HistoryProvider>(context, listen: false)
          .addToHistory(history);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.darkMode;

    return Consumer<TabProvider>(
      builder: (context, tabProvider, child) {
        if (tabProvider.tabs.isEmpty) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary),
            ),
          );
        }

        final currentTab = tabProvider.currentTab;

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              _goBack(tabProvider);
            } else if (details.primaryVelocity! < 0) {
              _goForward(tabProvider);
            }
          },
          child: Scaffold(
            backgroundColor:
                darkMode ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0E0),
            appBar: HomePageHeader(
              darkMode: darkMode,
              onNewTab: () {
                Provider.of<TabProvider>(context, listen: false)
                    .addNewTab(onPageStarted: _addToHistory);
              },
              onNewIncognitoTab: () {
                Provider.of<TabProvider>(context, listen: false)
                    .addNewTab(isIncognito: true, onPageStarted: _addToHistory);
              },
              onOpenSettings: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
              onToggleFullScreen: () {
                setState(() {
                  _showNavBar = !_showNavBar;
                });
              },
            ),
            body: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: currentTab.isHome
                            ? _HomeScreen(
                                tab: currentTab,
                                darkMode: darkMode,
                                onAddBookmark: () =>
                                    _showAddBookmarkDialog(context),
                              )
                            : RefreshIndicator(
                                onRefresh: () => _refresh(tabProvider),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: GestureDetector(
                                    onLongPress: () async {
                                      final url = await currentTab.controller
                                          .currentUrl();
                                      if (url != null) {
                                        Provider.of<DownloadProvider>(context,
                                                listen: false)
                                            .startDownload(context, url);
                                      }
                                    },
                                    child: WebViewWidget(
                                        controller: currentTab.controller),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                  if (_showNavBar)
                    FloatingNavBar(
                      isDark: darkMode,
                      onGoBack: () => _goBack(tabProvider),
                      onGoForward: () => _goForward(tabProvider),
                      onGoHome: () => tabProvider.goHome(),
                      onGoToUrl: () => _goToUrl(tabProvider),
                      onGoToTabs: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TabsPage(),
                          ),
                        );
                      },
                      urlController: currentTab.urlController,
                      urlFocusNode: currentTab.urlFocusNode,
                      onSubmitted: (_) => _goToUrl(tabProvider),
                    ),
                  if (!currentTab.isHome)
                    Positioned(
                      bottom: 80,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFullScreen = !_isFullScreen;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: _isFullScreen
                              ? Colors.black.withOpacity(0.5)
                              : Colors.blue.withOpacity(0.8),
                          child: Icon(
                            _isFullScreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _enterReaderMode() async {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    final html = await tabProvider.currentTab.controller
        .runJavaScriptReturningResult('document.documentElement.outerHTML');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReaderModePage(htmlContent: html.toString()),
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
}

class _HomeScreen extends StatelessWidget {
  final TabData tab;
  final bool darkMode;
  final VoidCallback onAddBookmark;

  const _HomeScreen({
    required this.tab,
    required this.darkMode,
    required this.onAddBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarkProvider = Provider.of<BookmarkProvider>(context);
    final bookmarks = bookmarkProvider.bookmarks;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NeuraBrowser',
              style: theme.textTheme.displaySmall?.copyWith(
                color: darkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: onAddBookmark,
              icon: const Icon(Icons.add),
              label: const Text('+ New Bookmark'),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMode
                    ? const Color(0xFF2E2E2E)
                    : const Color(0xFFE0E0E0),
                foregroundColor: darkMode ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 8,
                shadowColor: darkMode ? Colors.black : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
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
                      Provider.of<TabProvider>(context, listen: false)
                          .loadUrl(bookmark.url);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
