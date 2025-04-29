import 'package:emoji/model/user/user_model.dart';
import 'package:emoji/view/main/main_page.dart';
import 'package:emoji/viewmodel/code/code_viewmodel.dart';
import 'package:emoji/viewmodel/user/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:emoji/view/registration/location_select_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final CoreViewModel coreViewModel = CoreViewModel();
  String deviceId = '';

  String? selectedGender;
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  bool isAgeValid = true;
  String? selectedLocation;
  List<double>? latLon;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
    ageController.addListener(_validateAge);
  }

  @override
  void dispose() {
    ageController.dispose();
    nicknameController.dispose();
    super.dispose();
  }

  Future<void> _loadDeviceId() async {
    final id = await coreViewModel.getDeviceId();
    setState(() {
      deviceId = id;
    });
  }

  void _validateAge() {
    if (ageController.text.isEmpty) {
      setState(() {
        isAgeValid = true;
      });
      return;
    }

    try {
      int age = int.parse(ageController.text);
      setState(() {
        isAgeValid = age >= 19;
      });
    } catch (e) {
      setState(() {
        isAgeValid = false;
      });
    }
  }

  bool _isFormValid() {
    return selectedGender != null &&
        nicknameController.text.isNotEmpty &&
        ageController.text.isNotEmpty &&
        isAgeValid &&
        selectedLocation != null;
  }

  @override
  Widget build(BuildContext context) {
    final mainVm = ref.watch(mainViewModelProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('프로필 설정'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '성별',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGenderOption('남성'),
                _buildGenderOption('여성'),
              ],
            ),
            SizedBox(height: 32),
            Text(
              '닉네임',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: nicknameController,
              decoration: InputDecoration(
                hintText: '닉네임을 입력해주세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            SizedBox(height: 32),
            Text(
              '나이',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '나이를 입력해주세요.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                errorText: !isAgeValid ? '19세 미만은 가입이 불가능합니다' : null,
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  try {
                    int age = int.parse(value);
                    setState(() {
                      isAgeValid = age >= 19;
                    });
                  } catch (e) {
                    setState(() {
                      isAgeValid = false;
                    });
                  }
                } else {
                  setState(() {
                    isAgeValid = true;
                  });
                }
              },
            ),
            SizedBox(height: 32),
            Text(
              '활동지역',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationSelectPage(),
                  ),
                );

                if (result != null && result is Map) {
                  setState(() {
                    selectedLocation = result['fullAddress'];
                    latLon = result['initialPosition'];
                  });
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('현 위치 검색'),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(selectedLocation ?? '위치를 선택해주세요.'),
                ],
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isFormValid()
                    ? () async {
                        try {
                          // Show loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          
                          // Create user data
                          mainVm.addUser(User(
                            uid: deviceId,
                            userName: nicknameController.text,
                            age: int.parse(ageController.text),
                            gender: selectedGender!,
                            roomId: '',
                            address: selectedLocation!,
                            coordinates: [latLon![0], latLon![1]],
                          ));

                          // TODO: Add Firebase registration logic here
                          // await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          //   email: email,
                          //   password: password,
                          // );

                          // Navigate to main page
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainPage()),
                            (Route<dynamic> route) => false,
                          );
                        } catch (e) {
                          // Hide loading indicator
                          Navigator.pop(context);

                          // Show error message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('회원가입 중 오류가 발생했습니다: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isFormValid() ? Colors.blue : Colors.grey[200],
                  foregroundColor:
                      _isFormValid() ? Colors.white : Colors.black54,
                ),
                child: Text('가입하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    bool isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
            child: Icon(
              gender == '남성' ? Icons.person : Icons.person_outline,
              size: 40,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            gender,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
