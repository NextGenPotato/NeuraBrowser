import 'package:flutter/material.dart';
import 'package:neura_browser/providers/tab_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neura_browser/pages/passcode_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TabsPage extends StatefulWidget {
  final Function(TabData)? onPageStarted;
  const TabsPage({super.key, this.onPageStarted});

  @override
  State<TabsPage> createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabProvider = Provider.of<TabProvider>(context);
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    final regularTabs =
        tabProvider.tabs.where((tab) => !tab.isIncognito).toList();
    final incognitoTabs =
        tabProvider.tabs.where((tab) => tab.isIncognito).toList();

    return Scaffold(
      backgroundColor: darkMode ? Colors.grey[900] : Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Tabs',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: darkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              final tabProvider =
                  Provider.of<TabProvider>(context, listen: false);
              final isIncognito = _tabController.index == 1;
              tabProvider.addNewTab(
                  isIncognito: isIncognito,
                  onPageStarted: widget.onPageStarted);
              Navigator.pop(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) async {
            if (index == 1) {
              final prefs = await SharedPreferences.getInstance();
              final passcode = prefs.getString('passcode');
              if (passcode != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PasscodePage(),
                  ),
                );
                if (result != true) {
                  _tabController.index = 0;
                }
              }
            }
          },
          tabs: const [
            Tab(text: 'Tabs'),
            Tab(text: 'Incognito'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabGrid(regularTabs, darkMode),
          _buildTabGrid(incognitoTabs, darkMode),
        ],
      ),
    );
  }

  Widget _buildTabGrid(List<TabData> tabs, bool darkMode) {
    final tabProvider = Provider.of<TabProvider>(context, listen: false);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: tabs.length,
      itemBuilder: (context, index) {
        final tab = tabs[index];
        final originalIndex = tabProvider.tabs.indexOf(tab);
        return Dismissible(
          key: Key(tab.urlController.text),
          onDismissed: (direction) {
            tabProvider.closeTab(originalIndex);
          },
          child: GestureDetector(
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              final incognitoLock = prefs.getBool('incognitoLock') ?? false;
              tabProvider.setCurrentTab(originalIndex,
                  incognitoLock: incognitoLock);
              Navigator.pop(context);
            },
            child: _NeumorphicTabCard(
              tab: tab,
              darkMode: darkMode,
              onClose: () => tabProvider.closeTab(originalIndex),
            ),
          ),
        );
      },
    );
  }
}

class _NeumorphicTabCard extends StatelessWidget {
  final TabData tab;
  final bool darkMode;
  final VoidCallback onClose;

  const _NeumorphicTabCard({
    required this.tab,
    required this.darkMode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _neumorphicDecoration(
        isDark: darkMode,
        isIncognito: tab.isIncognito,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                color: darkMode ? Colors.grey[700] : Colors.grey[300],
              ),
              child: Center(
                child: tab.faviconUrl.isNotEmpty
                    ? Image.network(
                        tab.faviconUrl,
                        width: 48,
                        height: 48,
                      )
                    : Icon(
                        tab.isIncognito ? Icons.security : Icons.web,
                        size: 48,
                        color: darkMode ? Colors.white54 : Colors.black54,
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              tab.title,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                color: darkMode ? Colors.white : Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close,
                  size: 18, color: darkMode ? Colors.white : Colors.black),
              onPressed: onClose,
            ),
          )
        ],
      ),
    );
  }
}

BoxDecoration _neumorphicDecoration({
  required bool isDark,
  double radius = 16,
  bool isIncognito = false,
}) {
  final baseColor = isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE0E0E0);
  final shadowColorDark =
      isDark ? Colors.black.withOpacity(0.3) : Colors.grey.shade500;
  final shadowColorLight = isDark ? Colors.grey.shade800 : Colors.white;

  return BoxDecoration(
    color: baseColor,
    borderRadius: BorderRadius.circular(radius),
    border: isIncognito
        ? Border.all(color: Colors.purple.withOpacity(0.5), width: 2)
        : null,
    boxShadow: [
      BoxShadow(
        color: shadowColorDark,
        offset: const Offset(4, 4),
        blurRadius: 8,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: shadowColorLight,
        offset: const Offset(-4, -4),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  );
}
