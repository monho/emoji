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
    double myLat = 37.56104;
    double myLon = 126.9257;
    List<Map<String, dynamic>> peoplePositions = [
      {'lat': 37.5450, 'lon': 126.9258, 'name': '1'},
      {'lat': 37.5736, 'lon': 126.9262, 'name': '2'},
      {'lat': 37.5694, 'lon': 126.9251, 'name': '3'},
      {'lat': 37.5559, 'lon': 126.9249, 'name': '4'},
      {'lat': 37.5633, 'lon': 126.9265, 'name': '5'},
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Text(
            '동네 사람 찾는 중...',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          SizedBox.square(
            dimension: MediaQuery.of(context).size.width, // 393
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(nearByPeople, (index) {
                  // x 186, y186 기준

                  double xPos =
                      (myLat - peoplePositions[index]['lat']) * 10000 + 186;
                  double yPos =
                      (myLon - peoplePositions[index]['lon']) * 10000 + 186;
                  return Positioned(
                    left: xPos,
                    top: yPos,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/image/question_mark.png',
                          width: 20,
                          height: 20,
                        ),
                        Text('${distance[index]} m'),
                      ],
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
          Spacer(),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 50),
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
