import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String content;
  final DateTime sentAt;
  final String? text;
  final String? stickerUrl;
  final String type;

  ChatMessage({
    required this.senderId,
    required this.content,
    required this.sentAt,
    this.text,
    this.stickerUrl,
    required this.type,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'],
      content: map['content'],
      text: map['text'],
      stickerUrl: map['stickerUrl'],
      sentAt: (map['sentAt'] as Timestamp).toDate(),
      type: map['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'sentAt': Timestamp.fromDate(sentAt),
      'text': text,
      'stickerUrl': stickerUrl,
      'type': type,
    };
  }
}

class Stick {
  final int idItem;
  final String background;
  final String imgName;
  final String testX;

  Stick({
    required this.idItem,
    required this.background,
    required this.imgName,
    required this.testX,
  });
}
