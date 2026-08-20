import 'package:flutter/material.dart';
import 'presentation/home_page.dart';

class HyperDropApp extends StatefulWidget {
  const HyperDropApp({super.key});
  @override
  State<HyperDropApp> createState() => _HyperDropAppState();
}

class _HyperDropAppState extends State<HyperDropApp> {
  ThemeMode mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperDrop',
      debugShowCheckedModeBanner: false,
      themeMode: mode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF8B80FF),
        brightness: Brightness.dark,
      ),
      home: HomePage(
        onToggleTheme: () => setState(() {
          mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        }),
      ),
    );
  }
}
