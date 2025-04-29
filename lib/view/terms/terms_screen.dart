import 'package:emoji/view/registration/profile_setup_page.dart'; // ProfileSetupPage로 이동하는 데 사용되는 경로
import 'package:flutter/material.dart'; // Flutter UI 관련 패키지
import 'package:geolocator/geolocator.dart'; // 위치 권한 요청 및 위치 정보 관련 패키지
import 'package:flutter/services.dart'; // rootBundle을 사용하여 애셋 파일을 읽기 위한 패키지

class TermsAgreementPage extends StatefulWidget {
  const TermsAgreementPage({super.key});

  @override
  State<TermsAgreementPage> createState() => _TermsAgreementPageState();
}

class _TermsAgreementPageState extends State<TermsAgreementPage> {
  // 약관 동의 여부를 저장하는 상태 변수
  bool allChecked = false; // "약관 모두 동의하기" 체크박스 상태
  bool term1 = false; // "회원 이용약관" 동의 여부
  bool term2 = false; // "개인정보 수집/이용" 동의 여부
  bool term3 = false; // "위치기반 서비스 이용약관" 동의 여부

  final Color primaryBlue = const Color(0xFF004FFF); // 주요 색상

  // "약관 모두 동의하기" 체크박스를 클릭했을 때의 동작
  void updateAll(bool? value) {
    setState(() {
      allChecked = value ?? false;
      term1 = allChecked; // 모든 약관이 동의 상태일 때, 개별 약관들도 동의로 설정
      term2 = allChecked;
      term3 = allChecked;
    });
  }

  // 개별 약관 체크박스를 클릭했을 때의 동작
  void updateIndividual() {
    setState(() {
      allChecked = term1 && term2 && term3; // 모든 개별 약관이 동의되어야 "약관 모두 동의하기"가 체크됨
    });
  }

  // 위치 권한을 요청하는 메서드
  Future<bool> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission(); // 현재 위치 권한 상태 확인

    if (permission == LocationPermission.denied) { // 권한이 거부된 경우
      permission = await Geolocator.requestPermission(); // 권한 요청
      if (permission == LocationPermission.denied) { // 여전히 거부된 경우
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) { // 권한이 영구히 거부된 경우
      return false;
    }

    return true; // 위치 권한이 승인된 경우
  }

  // 텍스트 파일을 읽어서 다이얼로그에 표시하는 메서드
  Future<void> showTermDialog(String title, String filePath, VoidCallback onAgree) async {
    // rootBundle을 사용하여 assets 폴더에 있는 약관 파일을 읽음
    String content = await rootBundle.loadString(filePath);

    // 약관을 표시할 다이얼로그 창을 생성
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: Colors.black)), // 다이얼로그 제목
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(color: Colors.black)), // 파일 내용을 텍스트로 표시
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // "닫기" 버튼
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              onAgree(); // 동의 버튼 클릭 시 onAgree 콜백 실행
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryBlue, // 버튼 색상
            ),
            child: const Text('동의'), // "동의" 버튼
          ),
        ],
      ),
    );
  }

  // 약관 항목을 표시하는 ListTile 위젯
  Widget buildTermTile(String label, bool value, Function(bool?) onChanged, VoidCallback onTapDetail) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩 설정
      leading: Checkbox(
        value: value, // 체크박스 상태
        onChanged: (val) {
          onChanged(val); // 체크박스를 변경할 때 호출되는 콜백
          updateIndividual(); // 개별 약관의 동의 상태를 업데이트
        },
        activeColor: primaryBlue, // 체크박스 선택 색상
        checkColor: Colors.white, // 체크박스 내 선택 색상
      ),
      title: Text(label, style: const TextStyle(fontSize: 16)), // 약관 제목
      trailing: IconButton(
        icon: const Icon(Icons.chevron_right), // 우측 화살표 아이콘
        onPressed: onTapDetail, // 아이콘 클릭 시 약관 상세보기
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색
      appBar: AppBar(
        leading: const BackButton(), // 뒤로 가기 버튼
        title: const Text(''), // 앱바 제목
        elevation: 0, // 앱바 그림자 없음
        backgroundColor: Colors.white, // 앱바 배경색
        foregroundColor: Colors.black, // 앱바 텍스트 색상
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 세로 정렬
        children: [
          const Divider(thickness: 1), // 구분선
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16), // 상하 좌우 패딩
            child: Text(
              '이용자님의 동의가 필요합니다.', // 동의 문구
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(thickness: 1), // 구분선
          CheckboxListTile(
            title: const Text('약관 모두 동의하기',
                style: TextStyle(fontWeight: FontWeight.bold)), // "약관 모두 동의하기" 항목
            value: allChecked, // 전체 동의 체크박스 상태
            onChanged: updateAll, // 체크박스 상태 변경 시 호출
            controlAffinity: ListTileControlAffinity.leading, // 체크박스 왼쪽에 위치
            activeColor: primaryBlue, // 체크박스 선택 색상
            checkColor: Colors.white, // 체크박스 내 선택 색상
            contentPadding: const EdgeInsets.symmetric(horizontal: 16), // 좌우 패딩
          ),
          const Divider(thickness: 1), // 구분선
          // 개별 약관 항목
          buildTermTile('[필수] 회원 이용약관', term1, (v) => term1 = v ?? false, () {
            showTermDialog('회원 이용약관', 'assets/terms/term1.txt', () {
              setState(() {
                term1 = true;
                updateIndividual(); // 동의 후 상태 업데이트
              });
            });
          }),
          buildTermTile('[필수] 개인정보 수집/이용', term2, (v) => term2 = v ?? false,
              () {
            showTermDialog('개인정보 수집/이용', 'assets/terms/term2.txt', () {
              setState(() {
                term2 = true;
                updateIndividual(); // 동의 후 상태 업데이트
              });
            });
          }),
          buildTermTile('[필수] 위치기반 서비스 이용약관', term3, (v) => term3 = v ?? false,
              () {
            showTermDialog('위치기반 서비스 이용약관', 'assets/terms/term3.txt', () {
              setState(() {
                term3 = true;
                updateIndividual(); // 동의 후 상태 업데이트
              });
            });
          }),
          const Divider(thickness: 1), // 구분선
          const Spacer(), // 공간을 차지하여 버튼을 화면 하단에 위치시킴
          Padding(
            padding: const EdgeInsets.all(16.0), // 상하 좌우 패딩
            child: SizedBox(
              width: double.infinity, // 버튼 너비를 화면 너비로 설정
              height: 50, // 버튼 높이 설정
              child: ElevatedButton(
                onPressed: (term1 && term2 && term3) // 모든 약관에 동의했을 때만 버튼 활성화
                    ? () async {
                        bool permissionGranted =
                            await _requestLocationPermission(); // 위치 권한 요청

                        if (permissionGranted) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileSetupPage()), // 동의 후 프로필 설정 페이지로 이동
                            (Route<dynamic> route) => false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('위치 권한이 필요합니다. 설정에서 허용해주세요.'),
                              action: SnackBarAction(
                                label: '설정 열기',
                                onPressed: Geolocator.openAppSettings, // 설정으로 이동
                              ),
                            ),
                          );
                        }
                      }
                    : null, // 동의하지 않으면 버튼 비활성화
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue, // 버튼 배경색
                  foregroundColor: Colors.white, // 버튼 텍스트 색상
                ),
                child: const Text('동의'), // 버튼 텍스트
              ),
            ),
          ),
        ],
      ),
    );
  }
}
