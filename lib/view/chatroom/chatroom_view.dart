import 'package:emoji/viewmodel/chatroom/chatroom_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomView extends ConsumerStatefulWidget {
  final String roomId;
  const ChatRoomView({super.key, required this.roomId});

  @override
  ConsumerState<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends ConsumerState<ChatRoomView> {
  final textEditingController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void dispose() {
    textEditingController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(chatViewModelProvider(widget.roomId));
    final viewModelNotifier = ref.read(chatViewModelProvider(widget.roomId).notifier);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: viewModel.messages.length,
              itemBuilder: (context, index) {
                final msg = viewModel.messages[index];
                final isMe = msg.senderId == currentUserId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isMe
                          ? const Color.fromRGBO(191, 223, 255, 1)
                          : const Color.fromRGBO(230, 230, 230, 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.text != null && msg.text!.isNotEmpty)
                          Text(
                            msg.text!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        if (msg.stickerUrl != null && msg.stickerUrl!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.network(
                              msg.stickerUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (viewModel.selectedSticker != null) ...[
            Image.network(
              viewModel.selectedSticker!.background,
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(hintText: '메시지를 입력하세요'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.emoji_emotions),
                onPressed: () {
                  // 이모지 선택 모달 열기
                },
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final text = textEditingController.text.trim();
                  final selectedSticker = viewModel.selectedSticker;
                  
                  if (text.isNotEmpty && selectedSticker != null) {
                    // 텍스트 + 스티커 둘 다 있는 경우
                    viewModelNotifier.sendMixedMessage(
                      currentUserId,
                      text: text,
                      stickerUrl: selectedSticker.background,
                    );
                    textEditingController.clear();
                    viewModelNotifier.cancelSticker();
                  } else if (selectedSticker != null) {
                    // 스티커만 있는 경우
                    viewModelNotifier.sendStickerMessage(
                      currentUserId,
                      selectedSticker.background,
                    );
                    viewModelNotifier.cancelSticker();
                  } else if (text.isNotEmpty) {
                    // 텍스트만 있는 경우
                    viewModelNotifier.sendTextMessage(
                      currentUserId,
                      text,
                    );
                    textEditingController.clear();
                  }
                  scrollToBottom();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
