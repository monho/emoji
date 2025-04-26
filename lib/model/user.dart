class User {
  final String uid;
  final String userName;
  final int age;
  final String gender;
  final String roomId;
  final String address;
  final int reportCnt;
  final List coordinates;
  bool isMatched;
  bool isOnline;

  User({
    required this.uid, // 기기 고유 id
    required this.userName,
    required this.age,
    required this.gender,
    this.roomId = '', // 현재 위치한 방id
    required this.address, // 읍면동
    this.reportCnt = 0, // 신고 당한 횟수
    required this.coordinates, // [위도, 경도]
    this.isMatched = false, // 현재 매칭 중인지 확인
    this.isOnline = false, // 현재 온라인 상태인지 확인
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      userName: map['userName'],
      age: map['age'],
      gender: map['gender'],
      roomId: map['roomId'],
      address: map['address'],
      coordinates: map['coordinates'],
      isMatched: map['isMatched'],
      isOnline: map['isOnline'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'age': age,
      'gender': gender,
      'roomId': roomId,
      'address': address,
      'coordinates': coordinates,
      'isMatched': isMatched,
      'isOnline': isOnline
    };
  }
}
