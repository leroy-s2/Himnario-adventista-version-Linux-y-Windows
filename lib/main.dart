import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HimnarioApp());
}

class HimnarioApp extends StatelessWidget {
  const HimnarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Himnario Adventista',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B6914),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}
