import 'package:emoji/view/main/main_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return MainPage();
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Emoji',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 35,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
