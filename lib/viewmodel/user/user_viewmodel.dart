import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji/model/user/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainViewModel extends Notifier<List<User>?> {
  @override
  build() {
    return [];
  }

  Future<void> getUser(String address) async {
    // n초마다 유저정보 불러옴
    await Future.delayed(Duration(seconds: 5));
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('users');
    final snapshot = await collectionRef.get();
    final documentSnapshot = snapshot.docs;
    state = documentSnapshot.where((e) {
      return e.data()['address'] == address;
    }).map((e) {
      return User.fromMap(e.data());
    }).toList();
  }

  Future<void> addUser(User user) async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('users');
    final documentRef = collectionRef.doc();
    await documentRef.set(user.toMap());
  }

  Future<void> addWaiting(User user) async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('waiting_users');
    final documentRef = collectionRef.doc(user.address);
    await documentRef.set({
      user.uid: true,
    });
  }
}

final mainViewModelProvider = NotifierProvider<MainViewModel, List<User>?>(() {
  return MainViewModel();
});
