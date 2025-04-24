import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji/model/chatroom/chatroom_model.dart';
import 'package:flutter/widgets.dart';

class ChatViewModel extends ChangeNotifier {
  final String roomId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<ChatMessage> messages = [];

  ChatViewModel(this.roomId) {
    listenToMessages();
  }

  void listenToMessages() {
    firestore
      .collection('chatRooms')
      .doc(roomId)
      .collection('messages')
      .orderBy('sentAt')
      .snapshots()
      .listen((snapshot) {
        messages = snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.data()))
            .toList();
        notifyListeners();
      });
  }

  Future<void> sendMessage(String senderId, String content) async {
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

    // lastMessage 업데이트
    await firestore.collection('chatRooms').doc(roomId).update({
      'lastMessage': content,
      'lastMessageTime': DateTime.now(),
    });
  }
}
