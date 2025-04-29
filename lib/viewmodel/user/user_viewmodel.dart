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
    print('getUser');
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
    await documentRef_2.set(
      user.toMap(),
      SetOptions(merge: true), // ✅ 덮어쓰기 ❌, 병합(merge) ✅
    );
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

    // 1. waiting_users/{address}/users 컬렉션 접근
    final waitingUsersRef = firestore
        .collection('waiting_users')
        .doc(user.address)
        .collection('users');

    final waitingSnapshot = await waitingUsersRef.get();
    final waitingUserDocs = waitingSnapshot.docs;

    // 2. 대기 중인 유저들 리스트 (uid)
    final waitingUserIds = waitingUserDocs.map((doc) => doc.id).toList();

    if (waitingUserIds.length >= 2) {
      // 3. 두 명 뽑아서 uid를 오름차순 정렬
      final selectedUids = [waitingUserIds[0], waitingUserIds[1]]..sort();
      final String roomId = selectedUids[0] + selectedUids[1];

      print('생성된 roomId: $roomId');

      // 4. users 컬렉션에서 해당 두 명만 찾아서 roomId 업데이트
      final usersRef = firestore.collection('users');

      await Future.wait([
        usersRef.doc(selectedUids[0]).update({
          'roomId': roomId,
          'isMatched': true,
        }),
        usersRef.doc(selectedUids[1]).update({
          'roomId': roomId,
          'isMatched': true,
        }),
      ]);

      // 5. 대기열(waiting_users)에서는 두 명 삭제
      await Future.wait([
        waitingUsersRef.doc(selectedUids[0]).delete(),
        waitingUsersRef.doc(selectedUids[1]).delete(),
      ]);
    }
  }
}

final mainViewModelProvider = NotifierProvider<MainViewModel, List<User>?>(() {
  return MainViewModel();
});
