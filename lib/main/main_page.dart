import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final random = Random();
    final int nearByPeople = 10;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 700,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(nearByPeople, (index) {
                  double xPos = random.nextInt(260) + 70;
                  double yPos = random.nextInt(220) + 230;
                  return Positioned(
                    left: xPos, // 70 ~330
                    top: yPos, //230 ~ 450
                    child: Image.asset(
                      'assets/image/question_mark.png',
                      width: 20,
                      height: 20,
                    ),
                  );
                }),
                Positioned(
                  child: Transform.scale(
                    scale: 2.8,
                    child: Lottie.asset(
                      'assets/lottie/radar.json',
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 0.3,
                  child: Lottie.asset(
                    'assets/lottie/emoji.json',
                  ),
                ),
                
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 20),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  )),
              child: Text(
                '랜덤 채팅 시작',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
