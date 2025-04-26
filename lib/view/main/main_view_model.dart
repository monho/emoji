import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainViewModel extends Notifier<List<User>> {
  @override
  build() {
    return [];
  }

  Future<void> getUser() async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('users');
    final snapshot = await collectionRef.get();
    final documentSnapshot = snapshot.docs;

    state = documentSnapshot.map((e) {
      return User.fromMap(e.data());
    }).toList();
  }

  Future<void> addUser(User user) async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('users');
    final documentRef = collectionRef.doc();
    await documentRef.set(user.toMap());
  }
}

final mainViewModelProvider = NotifierProvider<MainViewModel, List<User>>(() {
  return MainViewModel();
});
