import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:neura_browser/models/bookmark.dart';
import 'package:neura_browser/providers/bookmark_provider.dart';
import 'package:neura_browser/providers/download_provider.dart';
import 'package:neura_browser/providers/tab_provider.dart';
import 'package:neura_browser/providers/theme_provider.dart';
import 'package:neura_browser/providers/history_provider.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BookmarkAdapter());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TabProvider()),
        ChangeNotifierProvider(create: (context) => DownloadProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider()),
        ChangeNotifierProvider(create: (context) => BookmarkProvider()),
      ],
      child: const NeuraBrowserApp(),
    ),
  );
}

class NeuraBrowserApp extends StatelessWidget {
  const NeuraBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.darkMode
        ? ThemeData.dark(useMaterial3: true).copyWith(
            textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme)
                .apply(bodyColor: Colors.white, displayColor: Colors.white),
          )
        : ThemeData.light(useMaterial3: true).copyWith(
            textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme)
                .apply(bodyColor: Colors.black, displayColor: Colors.black),
          );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const HomePage(),
    );
  }
}
