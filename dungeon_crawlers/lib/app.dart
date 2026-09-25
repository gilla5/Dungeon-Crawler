import 'package:flutter/material.dart';

import 'game_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dungeon Crawlers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3D2C1E),
          brightness: Brightness.dark,
        ),
      ),
      home: const GamePage(),
    );
  }
}
