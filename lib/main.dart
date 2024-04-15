import 'package:doodle_for_gdsc/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoodleAI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xff3b3734),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff3b3734),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashSceeen(),
    );
  }
}
