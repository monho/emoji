import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji/model/user/user_model.dart';
import 'package:emoji/repository/user_repository.dart';

class UserViewModel{
  final UserRepository userRepository = UserRepository();

Future<List<User>> fetchUsers() async {
  await Future.delayed(Duration(milliseconds: 500)); // 더 현실적인 딜레이
  if (userRepository.dummyUsers.isEmpty) {
    print('❗ dummyUsers 비어있음');
    return [];
  }

  print('✅ 첫 주소: ${userRepository.dummyUsers[0].address}');
  return userRepository.dummyUsers;
}

  Future<void> createUser(User user)async{
    final test = FirebaseFirestore.instance;
    final collectRef = test.collection('users');
    final docRef = collectRef.doc();
    await docRef.set(user.toMap());
  }

}