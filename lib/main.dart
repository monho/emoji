import 'package:emoji/firebase_options.dart';
import 'package:emoji/view/chatroom/chatroom_view.dart';
import 'package:emoji/view/main/main_page.dart';
import 'package:emoji/view/registration/profile_setup_page.dart';
import 'package:emoji/view/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FlutterNaverMap().init(
    clientId: "s4ddmne9i5",
    onAuthFailed: (ex) {
      print(ex);
    },
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
