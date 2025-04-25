import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emoji/view/main/main_page.dart';

class TermsAgreementPage extends StatefulWidget {
  const TermsAgreementPage({super.key});

  @override
  State<TermsAgreementPage> createState() => _TermsAgreementPageState();
}

class _TermsAgreementPageState extends State<TermsAgreementPage> {
  bool allChecked = false;
  bool term1 = false;
  bool term2 = false;
  bool term3 = false;

  final Color primaryBlue = const Color(0xFF004FFF);

  @override
  void initState() {
    super.initState();
    _checkAlreadyAgreed(); //이미 약관 동의했는지 확인
  }

  //약관 동의 여부 확인 → true면 MainPage로 이동
  Future<void> _checkAlreadyAgreed() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyAgreed = prefs.getBool('agreed_terms') ?? false;

    if (alreadyAgreed && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainPage()),
      );
    }
  }

  void updateAll(bool? value) {
    setState(() {
      allChecked = value ?? false;
      term1 = allChecked;
      term2 = allChecked;
      term3 = allChecked;
    });
  }

  void updateIndividual() {
    setState(() {
      allChecked = term1 && term2 && term3;
    });
  }

  void showTermDialog(String title, String content, VoidCallback onAgree) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: Colors.black)),
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(color: Colors.black)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onAgree();
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryBlue,
            ),
            child: const Text('동의'),
          ),
        ],
      ),
    );
  }

  Widget buildTermTile(
    String label,
    bool value,
    Function(bool?) onChanged,
    VoidCallback onTapDetail,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Checkbox(
        value: value,
        onChanged: (val) {
          onChanged(val);
          updateIndividual();
        },
        activeColor: primaryBlue,
        checkColor: Colors.white,
      ),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed: onTapDetail,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(''),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(thickness: 1),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
            child: Text(
              '이용자님의 동의가 필요합니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(thickness: 1),
          CheckboxListTile(
            title: const Text('약관 모두 동의하기', style: TextStyle(fontWeight: FontWeight.bold)),
            value: allChecked,
            onChanged: updateAll,
            controlAffinity: ListTileControlAffinity.leading,
            activeColor: primaryBlue,
            checkColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          const Divider(thickness: 1),
          buildTermTile('[필수] 회원 이용약관', term1, (v) => term1 = v ?? false, () {
            showTermDialog('회원 이용약관', '''
제1조 (목적)
이 약관은 본 앱이 제공하는 모든 서비스의 이용 조건과 절차, 회원과 회사의 권리, 의무, 책임사항 등을 규정함을 목적으로 합니다.

제2조 (회원 가입)
회원은 회사가 정한 절차에 따라 가입을 신청하고, 회사가 이를 승낙함으로써 서비스 이용 계약이 체결됩니다.

제3조 (회원의 의무)
- 타인의 정보를 도용하거나 허위 정보를 제공해서는 안 됩니다.
- 서비스 이용 시 법령을 준수해야 합니다.

제4조 (서비스 이용)
회사는 회원에게 안정적인 서비스를 제공하기 위해 노력하며, 기술적 사유로 일시 중단될 수 있습니다.

제5조 (계약 해지 및 이용 제한)
회사는 회원이 본 약관을 위반한 경우 사전 통지 없이 서비스 이용을 제한하거나 계약을 해지할 수 있습니다.

제6조 (면책조항)
- 회사는 천재지변, 불가항력 등으로 인한 서비스 장애에 대해 책임지지 않습니다.
''', () {
              setState(() {
                term1 = true;
                updateIndividual();
              });
            });
          }),
          buildTermTile('[필수] 개인정보 수집/이용', term2, (v) => term2 = v ?? false, () {
            showTermDialog('개인정보 수집/이용', '''
1. 수집 항목
- 필수: 이름, 이메일, 휴대폰 번호
- 선택: 프로필 사진

2. 수집 목적
- 회원 가입 및 본인 확인
- 서비스 제공 및 운영
- 고객 응대 및 민원 처리

3. 보유 기간
- 회원 탈퇴 시까지
- 관계 법령에 따라 일정 기간 보존될 수 있음

4. 동의 거부 시 불이익
- 필수 항목에 대한 동의가 없을 경우 회원가입이 불가능합니다.
''', () {
              setState(() {
                term2 = true;
                updateIndividual();
              });
            });
          }),
          buildTermTile('[필수] 위치기반 서비스 이용약관', term3, (v) => term3 = v ?? false, () {
            showTermDialog('위치기반 서비스 이용약관', '''
1. 위치정보 수집
- 앱은 서비스 제공을 위해 사용자 단말기의 GPS 정보 등 위치정보를 수집할 수 있습니다.

2. 수집 목적
- 사용자의 위치 기반 맞춤형 서비스 제공 (예: 주변 정보 제공)

3. 보유 및 이용기간
- 수집된 위치정보는 이용 목적 달성 후 지체 없이 파기합니다.

4. 이용자의 권리
- 위치정보 수집 동의 철회 가능
- 위치정보 제공 사실 확인 요구 가능
''', () {
              setState(() {
                term3 = true;
                updateIndividual();
              });
            });
          }),
          const Divider(thickness: 1),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (term1 && term2 && term3)
                    ? () async {
                        //동의 후 SharedPreferences에 저장
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('agreed_terms', true);

                        if (!mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MainPage()),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('동의'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
