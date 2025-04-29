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
    final documentRef = collectionRef.doc(user.uid); // 문서이름을 uid로 생성
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

  Future<void> matchingUsers(User user) async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('waiting_users');
    final documentRef = collectionRef.doc(user.address);
    final collectionRef_2 = documentRef.collection('users');
    final snapshot = await collectionRef_2.get();
    final documentSnapshot = snapshot.docs;
    // [uid1, uid2, ...]
    final waitingUsers = documentSnapshot.map((e) {
      return e.id;
    }).toList();
    if (waitingUsers.length >= 2) {
      // roomId는 두 유저의 uid를 더해서 생성
      final String roomId = waitingUsers[0] + waitingUsers[1];
      // 유저1의 roomId 부여
      final _firestore = FirebaseFirestore.instance;
      final _collectionRef = _firestore.collection('users');
      final _snapshot = await _collectionRef.get();
      final _documentSnapshot = _snapshot.docs;
      _documentSnapshot.forEach((e) async {
        if (roomId.contains(e.data()['uid'])) {
          await e.reference.update({'roomId': roomId});
        }
      });
      collectionRef_2.doc(waitingUsers[0]).delete();
      collectionRef_2.doc(waitingUsers[1]).delete();
      _documentSnapshot.forEach((e) async {
        if (roomId.contains(e.data()['uid'])) {
          await e.reference.update({'roomId': ''});
        }
      });
    }
  }
}

final mainViewModelProvider = NotifierProvider<MainViewModel, List<User>?>(() {
  return MainViewModel();
});
