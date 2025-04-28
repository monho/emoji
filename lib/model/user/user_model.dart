class User {
  final String uid;
  final String userName;
  final int age;
  final String gender;
  final String roomId;
  final String address;
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
      coordinates: [map['coordinates'][0], map['coordinates'][1]],
      isMatched: map['isMatched'],
      isOnline: map['isOnline']
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
