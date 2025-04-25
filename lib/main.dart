import 'package:emoji/firebase_options.dart';
import 'package:emoji/view/main/main_page.dart';
import 'package:emoji/view/splash/splash_screen.dart';
import 'package:emoji/viewmodel/chatroom/chatroom_viewmodel.dart';
import 'package:emoji/viewmodel/code/code_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(

    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ChatViewModel(roomId: 'EZZw5zrJEKAM0mIAMJ1A'),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
