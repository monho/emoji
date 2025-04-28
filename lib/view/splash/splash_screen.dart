// 필요한 패키지 불러오기
import 'dart:async';
import 'dart:math';
import 'package:emoji/view/terms/terms_screen.dart';
import 'package:emoji/viewmodel/code/code_viewmodel.dart';
import 'package:flutter/material.dart';

// Splash 화면을 나타내는 StatefulWidget
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// SplashScreen의 실제 동작 부분
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // 스크롤을 제어할 컨트롤러
  late ScrollController _scrollController;
  late Timer _scrollTimer; // 공들이 자동으로 옆으로 이동할 타이머
  late Timer _stopTimer; // 멈추는 타이밍을 잡는 타이머
  late AnimationController _textController; // 글자 등장 애니메이션 컨트롤러
  late Animation<double> _textAnimation; // 글자 크기 애니메이션
  late AnimationController _faceController; // 이모지 얼굴 크기 애니메이션 컨트롤러
  late Animation<double> _faceScaleAnimation; // 얼굴 크기 커지는 애니메이션

  int selectedIndex = 0; // 멈췄을 때 보여줄 이모지 인덱스
  bool showFace = false; // 얼굴을 보여줄지 여부
  bool showText = false; // 글자를 보여줄지 여부

  final double itemSize = 200; // 공 하나 크기
  final double itemSpacing = 40; // 공들 간 간격

  // 뒤에 흐르는 공 이미지들 (지금은 모두 같은 이미지)
  final List<String> emojiBackImages = [
    'assets/image/blank_ball.png',
    'assets/image/blank_ball.png',
    'assets/image/blank_ball.png',
    'assets/image/blank_ball.png',
    'assets/image/blank_ball.png',
    'assets/image/blank_ball.png',
  ];

  // 이모지 얼굴 이미지들 (앞모습들)
  final List<String> emojiFaceImages = [
    'assets/image/splash_smile.png',
    'assets/image/splash_sunglasses.png',
    'assets/image/splash_kiss.png',
    'assets/image/splash_wink.png',
  ];

  List<int> randomSequence = []; // 공들이 지나갈 때 얼굴 랜덤 순서
  int previousFinalIndex = -1; // 마지막에 멈출 얼굴 인덱스 기억

  CoreViewModel coreViewModel = CoreViewModel();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final deviceId = coreViewModel.getDeviceId();
    // 글자가 띠용 띠용 커졌다 줄어드는 애니메이션 설정
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600), // 전체 0.6초 동안
    );

    _textAnimation = TweenSequence<double>([
      // 0.7배 크기 → 1.3배 크기 커지고
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      // 1.3배 크기 → 1.0배로 줄어들기
      TweenSequenceItem(
        tween:
            Tween(begin: 1.3, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_textController);

    // 얼굴 커지는 애니메이션 설정
    _faceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _faceScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _faceController, curve: Curves.easeOutBack),
    );

    generateRandomSequence(); // 처음에 랜덤 순서 만들기
    startSlotMachine(); // 슬롯머신 시작!
  }

  // 공들이 지나갈 때 랜덤 순서를 만들어주는 함수
  void generateRandomSequence() {
    final random = Random();
    randomSequence.clear();
    int previous = -1;

    for (int i = 0; i < 100; i++) {
      int newIndex = random.nextInt(emojiFaceImages.length);
      // 이전과 같은 얼굴 나오지 않게 반복
      while (newIndex == previous) {
        newIndex = random.nextInt(emojiFaceImages.length);
      }
      randomSequence.add(newIndex);
      previous = newIndex;
    }
  }

  // 슬롯머신 동작하는 함수
  void startSlotMachine() {
    final random = Random();
    int newFinalIndex = random.nextInt(emojiFaceImages.length);

    // 이전에 멈췄던 이모지랑 같지 않게 다시 뽑기
    while (newFinalIndex == previousFinalIndex) {
      newFinalIndex = random.nextInt(emojiFaceImages.length);
    }
    previousFinalIndex = newFinalIndex;
    selectedIndex = newFinalIndex;

    // 화면이 준비되자마자 중앙으로 맞추기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final screenWidth = MediaQuery.of(context).size.width;
        final itemTotalSize = itemSize + itemSpacing;
        final middleIndex = 50;
        final offset = (middleIndex * itemTotalSize) +
            (itemSpacing / 2) -
            (screenWidth - itemSize) / 2;
        _scrollController.jumpTo(offset);
      }
    });

    // 공이 쓱쓱 움직이게 0.016초마다 오른쪽으로 이동
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.offset + 40); // 움직이는 속도
      }
    });

    // 0.3초 후에 멈추게 설정
    _stopTimer = Timer(const Duration(milliseconds: 300), () {
      _scrollTimer.cancel();

      if (_scrollController.hasClients) {
        final screenWidth = MediaQuery.of(context).size.width;
        final itemTotalSize = itemSize + itemSpacing;
        final currentIndex = (_scrollController.offset +
                (screenWidth - itemSize) / 2 -
                (itemSpacing / 2)) ~/
            itemTotalSize;
        final correctOffset = (currentIndex * itemTotalSize) +
            (itemSpacing / 2) -
            (screenWidth - itemSize) / 2;
        _scrollController.jumpTo(correctOffset);
      }

      setState(() {
        showFace = true;
        showText = true;
      });

      // 얼굴과 글자 애니메이션 시작
      _textController.forward();
      _faceController.forward();
    });

    // 1초 지나면 메인 페이지로 이동
    Timer(const Duration(milliseconds: 2300), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TermsAgreementPage()),
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollTimer.cancel();
    _stopTimer.cancel();
    _textController.dispose();
    _faceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 공들이 가로로 지나가는 부분
          ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: randomSequence.length,
            itemBuilder: (context, index) {
              int emojiIndex = randomSequence[index % randomSequence.length];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: itemSpacing / 2),
                child: Image.asset(
                  emojiBackImages[0], // 뒷면 공
                  width: itemSize,
                  height: itemSize,
                ),
              );
            },
          ),
          // 멈췄을 때 나타나는 이모지 얼굴
          if (showFace)
            ScaleTransition(
              scale: _faceScaleAnimation,
              child: Container(
                width: itemSize,
                height: itemSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    // ✨ 이모지 테두리에 부드러운 Glow 효과
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    emojiFaceImages[selectedIndex],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          // 멈췄을 때 나타나는 'Emoji' 글자
          if (showText)
            Positioned(
              top: MediaQuery.of(context).size.height / 2 - itemSize / 2 - 90,
              child: ScaleTransition(
                scale: _textAnimation,
                child: Text(
                  'Emoji',
                  style: TextStyle(
                    color: Colors.yellow, // ✨ 글자색 노란색
                    fontSize: 65,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      // ✨ 글자에 퍼지는 노란 Glow 효과
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.8),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.2),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
