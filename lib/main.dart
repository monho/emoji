
import 'package:emoji/view/chatroom/chatroom_view.dart';
import 'package:emoji/view/main/main_page.dart';
import 'package:emoji/view/splash/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugShowCheckedModeBanner: false,
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}
