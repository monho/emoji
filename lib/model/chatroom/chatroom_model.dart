import 'package:cloud_firestore/cloud_firestore.dart';


class ChatMessage {
  final String senderId;
  final String content;
  final DateTime sentAt;

  ChatMessage({
    required this.senderId,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'],
      content: map['content'],
      sentAt: (map['sentAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'sentAt': sentAt,
    };
  }
}
