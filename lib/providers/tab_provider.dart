import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:neura_browser/helpers/biometric_helper.dart';

class TabData {
  final WebViewController controller;
  final TextEditingController urlController;
  final FocusNode urlFocusNode;
  String title;
  String faviconUrl;
  bool isHome;
  final bool isIncognito;

  TabData({
    required this.controller,
    required this.urlController,
    required this.urlFocusNode,
    this.title = 'New Tab',
    this.faviconUrl = '',
    this.isHome = true,
    this.isIncognito = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'faviconUrl': faviconUrl,
      'isHome': isHome,
      'isIncognito': isIncognito,
      'url': urlController.text,
    };
  }

  factory TabData.fromJson(Map<String, dynamic> json) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    final urlController = TextEditingController(text: json['url']);
    final urlFocusNode = FocusNode();
    return TabData(
      controller: controller,
      urlController: urlController,
      urlFocusNode: urlFocusNode,
      title: json['title'],
      faviconUrl: json['faviconUrl'],
      isHome: json['isHome'],
      isIncognito: json['isIncognito'],
    );
  }
}

class TabProvider with ChangeNotifier {
  final List<TabData> _tabs = [];
  final List<TabData> _incognitoTabs = [];
  int _currentTabIndex = 0;
  bool _isIncognitoMode = false;

  List<TabData> get tabs => _isIncognitoMode ? _incognitoTabs : _tabs;
  int get currentTabIndex => _currentTabIndex;
  TabData get currentTab => tabs[_currentTabIndex];
  bool get isIncognitoMode => _isIncognitoMode;

  TabProvider() {
    addNewTab();
  }

  void addNewTab({
    bool isIncognito = false,
    Function(TabData)? onPageStarted,
  }) {
    final urlController = TextEditingController();
    final urlFocusNode = FocusNode();
    late final TabData tab;
    late final WebViewController controller;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            tab.urlController.text = url;
            tab.isHome = false;
            if (onPageStarted != null) {
              onPageStarted(tab);
            }
            notifyListeners();
          },
          onPageFinished: (url) async {
            final title = await controller.getTitle();
            tab.title = title ?? 'Untitled';
            tab.faviconUrl =
                'https://www.google.com/s2/favicons?domain=$url&sz=64';
            notifyListeners();
          },
          onNavigationRequest: (request) {
            if (request.url.startsWith('https://www.google.com')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    tab = TabData(
      controller: controller,
      urlController: urlController,
      urlFocusNode: urlFocusNode,
      isHome: true,
      isIncognito: isIncognito,
    );

    if (isIncognito) {
      _incognitoTabs.add(tab);
      _isIncognitoMode = true;
      _currentTabIndex = _incognitoTabs.length - 1;
    } else {
      _tabs.add(tab);
      _isIncognitoMode = false;
      _currentTabIndex = _tabs.length - 1;
    }
    notifyListeners();
  }

  void setCurrentTab(int index, {bool incognitoLock = false}) async {
    if (_currentTabIndex == index) return;

    final selectedTab = tabs[index];
    if (selectedTab.isIncognito && incognitoLock) {
      final authenticated = await BiometricHelper()
          .authenticate(localizedReason: 'Authenticate to view incognito tab');
      if (!authenticated) {
        return;
      }
    }
    _currentTabIndex = index;
    _isIncognitoMode = selectedTab.isIncognito;
    notifyListeners();
  }

  void closeTab(int index) {
    if (tabs.length == 1) return;

    tabs[index].urlController.dispose();
    tabs[index].urlFocusNode.dispose();
    tabs.removeAt(index);

    if (_currentTabIndex >= tabs.length) {
      _currentTabIndex = tabs.length - 1;
    }
    notifyListeners();
  }

  void goHome() {
    currentTab.isHome = true;
    notifyListeners();
  }

  void loadUrl(String url) {
    String finalUrl = url.trim();
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }

    final urlRegex = RegExp(
        r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$');

    if (urlRegex.hasMatch(finalUrl)) {
      currentTab.controller.loadRequest(Uri.parse(finalUrl));
    } else {
      finalUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(url)}';
      currentTab.controller.loadRequest(Uri.parse(finalUrl));
    }

    currentTab.isHome = false;
    currentTab.urlFocusNode.unfocus();
    notifyListeners();
  }

  @override
  void dispose() {
    for (final tab in _tabs) {
      tab.urlController.dispose();
      tab.urlFocusNode.dispose();
    }
    for (final tab in _incognitoTabs) {
      tab.urlController.dispose();
      tab.urlFocusNode.dispose();
    }
    super.dispose();
  }
}
