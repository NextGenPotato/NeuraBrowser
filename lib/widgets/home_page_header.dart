import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neura_browser/pages/bookmarks_page.dart';
import 'package:neura_browser/pages/downloads_page.dart';
import 'package:neura_browser/pages/history_page.dart';
import 'package:neura_browser/providers/tab_provider.dart';
import 'package:provider/provider.dart';

class HomePageHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool darkMode;
  final VoidCallback onNewTab;
  final VoidCallback onNewIncognitoTab;
  final VoidCallback onOpenSettings;
  final VoidCallback onToggleFullScreen;

  const HomePageHeader({
    super.key,
    required this.darkMode,
    required this.onNewTab,
    required this.onNewIncognitoTab,
    required this.onOpenSettings,
    required this.onToggleFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            _buildPopupMenuItem(
              context,
              'New Tab',
              'new_tab',
              Icons.add_to_photos,
              darkMode,
            ),
            _buildPopupMenuItem(
              context,
              'New Incognito Tab',
              'new_incognito_tab',
              Icons.security,
              darkMode,
            ),
            const PopupMenuDivider(),
            _buildPopupMenuItem(
              context,
              'Bookmarks',
              'bookmarks',
              Icons.bookmark,
              darkMode,
            ),
            _buildPopupMenuItem(
              context,
              'History',
              'history',
              Icons.history,
              darkMode,
            ),
            _buildPopupMenuItem(
              context,
              'Downloads',
              'downloads',
              Icons.download,
              darkMode,
            ),
            const PopupMenuDivider(),
            _buildPopupMenuItem(
              context,
              'Settings',
              'settings',
              Icons.settings,
              darkMode,
            ),
            const PopupMenuDivider(),
            _buildPopupMenuItem(
              context,
              'Full Screen',
              'fullscreen',
              Icons.fullscreen,
              darkMode,
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'new_tab':
                onNewTab();
                break;
              case 'new_incognito_tab':
                onNewIncognitoTab();
                break;
              case 'bookmarks':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookmarksPage(),
                  ),
                );
                break;
              case 'history':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(
                      onGoToUrl: (url) {
                        Provider.of<TabProvider>(context, listen: false)
                            .loadUrl(url);
                      },
                    ),
                  ),
                );
                break;
              case 'downloads':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DownloadsPage(),
                  ),
                );
                break;
              case 'settings':
                onOpenSettings();
                break;
              case 'fullscreen':
                onToggleFullScreen();
                break;
            }
          },
        ),
      ],
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    bool darkMode,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: darkMode ? Colors.white : Colors.black),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.lato(
              color: darkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
