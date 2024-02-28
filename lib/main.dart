import 'package:flutter/material.dart';
import 'package:pull_animation/archery_page.dart';

const kDefaultArcheryTriggerOffset = 200.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Archery Animation',
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green,brightness: Brightness.dark)
      ),
      home: const Archery_Page(),
    );
  }
}
