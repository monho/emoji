import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String? text;
  final String? stickerUrl;
  final DateTime sentAt;
  final String type; // text / sticker / mixed

  ChatMessage({
    required this.senderId,
    this.text,
    this.stickerUrl,
    required this.sentAt,
    required this.type,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'],
      text: map['text'],
      stickerUrl: map['stickerUrl'],
      sentAt: (map['sentAt'] as Timestamp).toDate(),
      type: map['type'] ?? 'text',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'stickerUrl': stickerUrl,
      'sentAt': Timestamp.fromDate(sentAt),
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
