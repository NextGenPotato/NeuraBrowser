import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neura_browser/providers/bookmark_provider.dart';
import 'package:neura_browser/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:neura_browser/pages/passcode_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _incognitoLock = false;
  String _autoDeleteHistory = '30';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _incognitoLock = prefs.getBool('incognitoLock') ?? false;
      _autoDeleteHistory = prefs.getString('autoDeleteHistory') ?? '30';
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('incognitoLock', _incognitoLock);
    await prefs.setString('autoDeleteHistory', _autoDeleteHistory);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final darkMode = themeProvider.darkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionTitle(context, 'General'),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: darkMode,
            onChanged: (value) {
              themeProvider.toggleDarkMode(value);
            },
          ),
          _buildSectionTitle(context, 'Privacy & Security'),
          ListTile(
            title: const Text('Auto-delete history'),
            trailing: DropdownButton<String>(
              value: _autoDeleteHistory,
              items: const [
                DropdownMenuItem(value: '24', child: Text('24 hours')),
                DropdownMenuItem(value: '7', child: Text('7 days')),
                DropdownMenuItem(value: '30', child: Text('30 days')),
                DropdownMenuItem(value: '90', child: Text('90 days')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _autoDeleteHistory = value;
                  });
                  _savePrefs();
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Reset All Bookmarks'),
            onTap: () => _showResetBookmarksDialog(context),
          ),
          SwitchListTile(
            title: const Text('Incognito Lock'),
            value: _incognitoLock,
            onChanged: (value) {
              setState(() {
                _incognitoLock = value;
              });
              _savePrefs();
            },
          ),
          ListTile(
            title: const Text('Add or Change Passcode'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const PasscodePage(isSettingPasscode: true),
                ),
              );
            },
          ),
          _buildSectionTitle(context, 'About'),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0 Alpha Build 2.0 (JUL0525)'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _showResetBookmarksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset All Bookmarks?'),
          content: const Text(
              'This will permanently delete all of your bookmarks. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<BookmarkProvider>(context, listen: false)
                    .clearBookmarks();
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }
}
