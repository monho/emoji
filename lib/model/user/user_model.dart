class User {
  final String uid;
  final String userName;
  final int age;
  final String gender;
  final String roomId;
  final String address;
  final int reportCnt;
  final List<double> coordinates;
  bool isMatched;
  bool isOnline;

  User({
    required this.uid,
    required this.userName,
    required this.age,
    required this.gender,
    required this.roomId,
    required this.address,
    this.reportCnt = 0,
    required this.coordinates,
    this.isMatched = false,
    this.isOnline = false,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'],
      userName: map['userName'],
      age: map['age'],
      gender: map['gender'],
      roomId: map['roomId'],
      address: map['address'],
      coordinates: map['coordinates'].values.toList(),
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
      'coordinates': coordinates
    };
  }
}
