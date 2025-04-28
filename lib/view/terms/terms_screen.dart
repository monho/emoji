import 'package:flutter/material.dart';

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
      String label, bool value, Function(bool?) onChanged, VoidCallback onTapDetail) {
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
이 약관은 [앱 이름]이 제공하는 서비스의 이용 조건 및 절차, 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 회사가 제공하는 모바일 앱과 관련된 제반 서비스를 말합니다.
2. "이용자"란 본 약관에 따라 서비스를 이용하는 모든 회원을 의미합니다.

제3조 (회원가입)
1. 이용자는 회사가 정한 가입 양식에 따라 정보를 입력하고 약관에 동의함으로써 회원가입을 신청합니다.
2. 회사는 신청에 대해 승낙함으로써 회원가입이 완료됩니다.

제4조 (회원의 의무)
1. 회원은 정확한 정보를 제공하고 이를 유지·갱신해야 합니다.
2. 회원은 회사의 서비스를 법령 및 본 약관에 따라 성실히 이용해야 합니다.

제5조 (서비스의 변경 및 중단)
회사는 서비스의 내용을 변경하거나 중단할 수 있으며, 사전 고지 후 진행합니다.

제6조 (면책조항)
회사는 천재지변, 불가항력적 사유로 인한 서비스 중단에 대해 책임을 지지 않습니다.
''', () {
              setState(() {
                term1 = true;
                updateIndividual();
              });
            });
          }),
          buildTermTile('[필수] 개인정보 수집/이용', term2, (v) => term2 = v ?? false, () {
            showTermDialog('개인정보 수집/이용', '''
1. 수집하는 개인정보 항목
  - 필수항목: 이름, 이메일, 휴대전화번호

2. 수집 및 이용 목적
  - 회원 가입 의사 확인, 회원제 서비스 제공
  - 고객 상담 및 불만 처리

3. 보유 및 이용 기간
  - 수집된 정보는 회원 탈퇴 시까지 보유하며, 이후에는 파기합니다.

4. 동의 거부 권리 및 불이익
  - 사용자는 동의를 거부할 권리가 있으며, 거부 시 회원가입이 제한될 수 있습니다.
''', () {
              setState(() {
                term2 = true;
                updateIndividual();
              });
            });
          }),
          buildTermTile('[필수] 위치기반 서비스 이용약관', term3, (v) => term3 = v ?? false, () {
            showTermDialog('위치기반 서비스 이용약관', '''
1. 위치정보의 수집
  - 회사는 정확한 위치기반 서비스를 제공하기 위해 사용자의 위치정보를 수집할 수 있습니다.

2. 위치정보의 이용 목적
  - 사용자 맞춤형 서비스 제공 (예: 근처 매장 안내, 실시간 길찾기 등)

3. 보유 및 이용기간
  - 위치정보는 서비스 이용 목적 달성 시까지 보유하며, 이후에는 파기합니다.

4. 이용자의 권리
  - 사용자는 언제든지 위치정보 이용에 대한 동의를 철회할 수 있으며, 열람을 요구할 수 있습니다.
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
                    ? () {
                        // 동의 완료 후 다음 로직
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
