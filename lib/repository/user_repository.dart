import 'package:emoji/model/user/user_model.dart';

class UserRepository {
  final List<User> dummyUsers = [
    User(
        uid: 'user1',
        userName: 'Alice',
        age: 25,
        gender: 'Female',
        roomId: '',
        address: 'Seoul',
        coordinates: [37.5665, 126.9780], // 서울
        reportCnt: 0,
        isMatched: false,
        isOnline: false
      ),
    User(
        uid: 'user2',
        userName: 'Bob',
        age: 28,
        gender: 'Male',
        roomId: '',
        address: 'Busan',
        coordinates: [35.1796, 129.0756], // 부산
        reportCnt: 0,
        isMatched: false,
        isOnline: false
      ),
    User(
        uid: 'user3',
        userName: 'Charlie',
        age: 23,
        gender: 'Male',
        roomId: '',
        address: 'Incheon',
        coordinates: [37.4563, 126.7052], // 인천
        reportCnt: 0,
        isMatched: false,
        isOnline: false
      ),
    User(
        uid: 'user4',
        userName: 'Diana',
        age: 26,
        gender: 'Female',
        roomId: '',
        address: 'Daegu',
        coordinates: [35.8714, 128.6014], // 대구
        reportCnt: 0,
        isMatched: false,
        isOnline: false
      ),
    User(
        uid: 'user5',
        userName: 'Eve',
        age: 30,
        gender: 'Female',
        roomId: '',
        address: 'Gwangju',
        coordinates: [35.1595, 126.8526], // 광주
        reportCnt: 0,
        isMatched: false,
        isOnline: false
      ),
  ];
}
