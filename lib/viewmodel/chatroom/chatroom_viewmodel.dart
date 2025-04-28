import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji/model/chatroom/chatroom_model.dart';
import 'package:flutter/services.dart';

final chatViewModelProvider =
    StateNotifierProvider.family<ChatViewModel, ChatState, String>(
        (ref, roomId) {
  return ChatViewModel(roomId: roomId);
});

class ChatState {
  final List<ChatMessage> messages;
  final List<Stick> stickers;
  final Stick? selectedSticker;

  ChatState({
    this.messages = const [],
    this.stickers = const [],
    this.selectedSticker,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<Stick>? stickers,
    Stick? selectedSticker,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      stickers: stickers ?? this.stickers,
      selectedSticker: selectedSticker,
    );
  }
}

class ChatViewModel extends StateNotifier<ChatState> {
  final String roomId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ChatViewModel({required this.roomId}) : super(ChatState()) {
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
      final msgs =
          snapshot.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList();
      state = state.copyWith(messages: msgs);
    });
  }

  Future<void> sendTextMessage(String senderId, String text) async {
    final message = ChatMessage(
      senderId: senderId,
      content: text,
      sentAt: DateTime.now(),
      type: 'text',
    );

    await firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .add(message.toMap());
  }

  Future<void> sendStickerMessage(String senderId, String stickerUrl) async {
    final message = ChatMessage(
      senderId: senderId,
      content: stickerUrl,
      sentAt: DateTime.now(),
      type: 'sticker',
    );

    await firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .add(message.toMap());
  }

  void selectSticker(Stick sticker) {
    state = state.copyWith(selectedSticker: sticker);
  }

  void cancelSticker() {
    state = state.copyWith(selectedSticker: null);
  }

  Future<void> sendMixedMessage(String senderId,
      {String? text, String? stickerUrl}) async {
    final message = ChatMessage(
      senderId: senderId,
      text: text,
      stickerUrl: stickerUrl,
      sentAt: DateTime.now(),
      type: 'mixed', content: '', // ✅ 둘 다 있을 때 mixed
    );

    await firestore
        .collection('chatRooms')
        .doc(roomId)
        .collection('messages')
        .add(message.toMap());
  }

  Future<void> loadStickers(int type) async {
    try {
      final value = await rootBundle.loadString('assets/emoji/CommentImage');
      final mapList = json.decode(value) as Map<String, dynamic>;

      final group = mapList["result"]["stickerGroups"][type];
      final String groupId = group["id"];

      final List<Stick> loadedStickers = [];
      final List<dynamic> stickerList = group["stickers"];

      for (int i = 0; i < stickerList.length; i++) {
        final sticker = stickerList[i];
        loadedStickers.add(Stick(
          idItem: i,
          background:
              "https://storep-phinf.pstatic.net/$groupId/original_${i + 1}.gif?type=mfullfill108_100",
          imgName: sticker["id"].toString(),
          testX: sticker["id"].toString(),
        ));
      }

      state = state.copyWith(stickers: loadedStickers);
    } catch (e) {
      state = state.copyWith(stickers: []);
    }
  }
}
