import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji/model/chatroom/chatroom_model.dart';
import 'package:flutter/material.dart';

class ChatViewModel extends ChangeNotifier {
  final String roomId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  ChatViewModel({required this.roomId}) {
    listenToMessages();
  }

  void listenToMessages() {
    firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .listen((snapshot) {
      _messages =
          snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList();
      notifyListeners();
    });
  }

  Future<void> sendMessage(String senderId, String content) async {
    print('🔍 roomId: $roomId');
    final message = ChatMessage(
      senderId: senderId,
      content: content,
      sentAt: DateTime.now(),
    );

    await firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .add(message.toMap());

    await firestore.collection('chatRooms').doc(roomId).set({
      'lastMessage': content,
      'lastMessageTime': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
