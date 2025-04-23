import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    //
    // 예시 데이터
    double myLat = 37.5034138;
    double myLon = 126.7660309;
    List<Map<String, dynamic>> peoplePositions = [
      {'lat': 37.5665, 'lon': 126.9780, 'name': '서울'}, // 서울시청
      {'lat': 35.1587, 'lon': 129.0551, 'name': '부산'}, // 광안리 해수욕장
      {'lat': 35.8714, 'lon': 128.6014, 'name': '대구'}, // 대구시청
      {'lat': 35.1595, 'lon': 126.8526, 'name': '광주'}, // 광주광역시청
      {'lat': 33.5115, 'lon': 126.4927, 'name': '제주'}, // 제주국제공항
    ];
    //
    //

    final int nearByPeople = peoplePositions.length; // 같은 동네 사람 수

    /// 거리 계산 (lat1, lon1, lat2, lon2)
    int calculateDistance(double lat1, double lon1, double lat2, double lon2) {
      const R = 6371000; // 지구 반지름 (단위: 미터)
      final dLat = (lat2 - lat1) * pi / 180;
      final dLon = (lon2 - lon1) * pi / 180;
      final a = sin(dLat / 2) * sin(dLat / 2) +
          cos(lat1 * pi / 180) *
              cos(lat2 * pi / 180) *
              sin(dLon / 2) *
              sin(dLon / 2);
      final c = 2 * atan2(sqrt(a), sqrt(1 - a));
      return (R * c).toInt(); // (단위: 미터)
    }

    List<int> distance = peoplePositions.map(
      (e) {
        return calculateDistance(myLat, myLon, e['lat'], e['lon']);
      },
    ).toList();
    print(distance);

    return Scaffold(
      backgroundColor: Colors.white,
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
                    left: xPos,
                    top: yPos,
                    child: Image.asset(
                      'assets/image/question_mark.png',
                      width: 20,
                      height: 20,
                    ),
                  );
                }),
                Transform.scale(
                  scale: 2.8,
                  child: Lottie.asset('assets/lottie/radar.json'),
                ),
                Transform.scale(
                  scale: 0.3,
                  child: Lottie.asset('assets/lottie/emoji.json'),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 20),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
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
