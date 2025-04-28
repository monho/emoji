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
    print('addUser');
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('users');
    final documentRef = collectionRef.doc();
    await documentRef.set(user.toMap());
  }

  Future<void> addWaiting(User user) async {
    print('addWaiting');
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('waiting_users');
    final documentRef = collectionRef.doc(user.address);
    final collectionRef_2 = documentRef.collection('users');
    final documentRef_2 = collectionRef_2.doc(user.uid);
    documentRef_2.set(user.toMap());
  }

  Future<void> removeWaiting(User user) async {
    print('removeWaiting');
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('waiting_users');
    final documentRef = collectionRef.doc(user.address);
    final collectionRef_2 = documentRef.collection('users');
    final documentRef_2 = collectionRef_2.doc(user.uid);
    await documentRef_2.delete();
  }

  Future<User> findUserByUid(String uid) async {
    print('findUserByUid');
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('users');
    final snapshot = await collectionRef.get();
    final documentSnapshot = snapshot.docs;
    final map = documentSnapshot
        .firstWhere(
          (e) => e.data()['uid'] == uid,
        )
        .data();
    return User.fromMap(map);
  }
}

final mainViewModelProvider = NotifierProvider<MainViewModel, List<User>?>(() {
  return MainViewModel();
});
