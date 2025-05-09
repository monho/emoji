import 'dart:math';
import 'dart:async';
import 'package:emoji/model/user/user_model.dart';
import 'package:emoji/view/chatroom/chatroom_view.dart';
import 'package:emoji/viewmodel/code/code_viewmodel.dart';
import 'package:emoji/viewmodel/user/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  User? myData;
  late bool matching = myData?.isMatched ?? false;
  Timer? matchingTimer;
  Timer? refreshTimer;
  int time = 30;

  @override
  void initState() {
    super.initState();
    loadUserData();
    startAutoReload();
  }

  void startAutoReload() {
    refreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      loadUserData();
    });
  }

  void loadUserData() async {
    final mainVm = ref.read(mainViewModelProvider.notifier);
    CoreViewModel coreViewModel = CoreViewModel();
    final myUid = await coreViewModel.getDeviceId();
    myData = await mainVm.findUserByUid(myUid);
    mainVm.getUser(myData?.address ?? '');

    // roomId가 있다면 채팅방으로 이동
    if (myData!.roomId != '' && myData!.isMatched == true) {
      matchingTimer?.cancel();
      refreshTimer?.cancel();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return ChatRoomView(
          roomId: myData!.roomId,
          uid: myData!.uid,
        );
      }));
    }
    mainVm.matchingUsers(myData!);
    setState(() {}); // 데이터 다 불러오고 UI 새로고침
  }

  @override
  void dispose() {
    matchingTimer?.cancel();
    refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final mainState = ref.watch(mainViewModelProvider);
    final mainVm = ref.read(mainViewModelProvider.notifier);

    final myLat = myData?.coordinates[0];
    final myLon = myData?.coordinates[1];
    void startTimer() {
      time = 30;
      if (matching == false) {
        return;
      }
      matchingTimer = Timer.periodic(Duration(seconds: 1), (t) {
        setState(() {
          if (time <= 0) {
            matchingTimer?.cancel();
            matching = false;
            mainVm.removeWaiting(myData!);
          } else {
            time--;
          }
        });
      });
    }

    /// 미터 단위 포맷해주는 함수 ex) 1000 -> 1km, 600 -> 600m
    String formatDistance(int meters) {
      if (meters >= 1000) {
        double km = meters / 1000;
        return '${km.toStringAsFixed(1)}km';
      } else {
        return '${meters.toStringAsFixed(0)}m';
      }
    }

    /// 거리 계산 (lat1, lon1, lat2, lon2)
    int? calculateDistance(double lat1, double lon1, double lat2, double lon2) {
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

    List<int?> distance = mainState!.map((e) {
      return calculateDistance(
          (myLat ?? 0), (myLon ?? 0), e.coordinates[0], e.coordinates[1]);
    }).toList();
    return Scaffold(
      backgroundColor: !matching ? Colors.white : Colors.black,
      body: Column(
        children: [
          Spacer(),
          Text(
            !matching ? '동네 친구 찾는 중...' : '상대방을 찾는 중${'.' * (time % 3 + 1)}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: !matching ? Colors.black : Colors.white,
            ),
          ),
          SizedBox(height: 20),
          SizedBox.square(
            dimension: MediaQuery.of(context).size.width, // 393
            child: Stack(
              alignment: Alignment.center,
              children: [
                ...List.generate(mainState.length, (index) {//
                  // 중심 x 186, y186 기준 (393/2 - widgetSize/2)
                  double xPos = // 배율은 레이더 크기에 맞춰서 변경
                      ((myLat ?? 0) - mainState[index].coordinates[0]) * 10000 +
                          186;
                  double yPos =
                      ((myLon ?? 0) - mainState[index].coordinates[1]) * 10000 +
                          186;
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
                          formatDistance(distance[index]!),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: !matching ? Colors.black : Colors.white,
                          ),
                        ),
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
            child: ElevatedButton(//
              onPressed: () async {
                if (mainState.isNotEmpty) {
                  if (matching == false) {
                    mainVm.addWaiting(myData!);
                  } else {
                    mainVm.removeWaiting(myData!);
                  }
                  setState(() {
                    matchingTimer?.cancel();
                    matching = !matching;
                    startTimer();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: !matching
                    ? (mainState.isNotEmpty ? Colors.blue : Colors.grey)
                    : Colors.red,
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                !matching ? '랜덤 채팅 시작' : '매칭 취소 $time',
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
