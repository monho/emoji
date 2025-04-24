import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    /// 미터 단위 포맷해주는 함수 ex) 1000 -> 1km, 600 -> 600m
    String formatDistance(int meters) {
      if (meters >= 1000) {
        double km = meters / 1000;
        return '${km.toStringAsFixed(1)}km';
      } else {
        return '${meters.toStringAsFixed(0)}m';
      }
    }

    //
    // 예시 데이터 (나중에 firebase와 연동)
    double myLat = 37.56104;
    double myLon = 126.9257;
    List<Map<String, dynamic>> peoplePositions = [
      {'lat': 37.5450, 'lon': 126.9328, 'name': '1'},
      {'lat': 37.5736, 'lon': 126.9162, 'name': '2'},
      {'lat': 37.5694, 'lon': 126.9361, 'name': '3'},
      {'lat': 37.5559, 'lon': 126.9149, 'name': '4'},
      {'lat': 37.5553, 'lon': 126.9265, 'name': '5'},
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
                Transform.scale(
                  scale: 2.8,
                  child: Lottie.asset('assets/lottie/radar.json'),
                ),
                Transform.scale(
                  scale: 0.3,
                  child: Lottie.asset('assets/lottie/emoji.json'),
                ),
                ...List.generate(nearByPeople, (index) {
                  // 중심 x 186, y186 기준 (393/2 - ㅈ)
                  double xPos =                           // 배율 나중에 조정해야함!
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
                        Text(
                          formatDistance(distance[index]),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
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
