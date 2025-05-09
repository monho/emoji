import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

class CoreViewModel {
  Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // 또는 androidInfo.androidId (고유 ID)
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    } else {
      return 'unsupported_platform';
    }
  }

  Future<bool> findUserByUid(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final collectionRef = firestore.collection('users');
    final snapshot = await collectionRef.get();
    final documentSnapshot = snapshot.docs;
    try {
      documentSnapshot.firstWhere(
        (e) => e.data()['uid'] == uid,
      );
    } catch (e) {
      return false;
    }
    return true;
  }
}
