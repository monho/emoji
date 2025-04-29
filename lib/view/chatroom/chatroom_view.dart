import 'package:emoji/viewmodel/chatroom/chatroom_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomView extends ConsumerStatefulWidget {
  final String roomId;
  final String uid;
  const ChatRoomView({super.key, required this.roomId, required this.uid});

  @override
  ConsumerState<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends ConsumerState<ChatRoomView> {
  final textEditingController = TextEditingController();
  final scrollController = ScrollController();
  int selectedGroupIndex = 0; // ✅ 현재 선택된 그룹

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

  Future<void> openEmojiPicker(BuildContext context) async {
    final viewModelNotifier =
        ref.read(chatViewModelProvider(widget.roomId).notifier);
    await viewModelNotifier.loadStickers(selectedGroupIndex); // 초기 그룹 불러오기

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          // ✅ 추가
          builder: (context, setState) {
            final viewModel = ref.watch(chatViewModelProvider(widget.roomId));
            final viewModelNotifier =
                ref.read(chatViewModelProvider(widget.roomId).notifier);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ 스티커 그룹 탭
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(viewModelNotifier.groupIcons.length,
                        (index) {
                      final iconUrl = viewModelNotifier.groupIcons[index];
                      final isSelected = selectedGroupIndex == index;

                      return GestureDetector(
                        onTap: () async {
                          setState(() {
                            selectedGroupIndex = index; // ✅ 여기 setState로 갱신
                          });
                          await viewModelNotifier
                              .loadStickers(index); // ✅ 스티커 재로딩
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blueAccent.withOpacity(0.3)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            iconUrl,
                            width: 40,
                            height: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const Divider(),
                SizedBox(
                  height: 300,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: viewModel.stickers.length,
                    itemBuilder: (context, index) {
                      final sticker = viewModel.stickers[index];
                      return GestureDetector(
                        onTap: () {
                          viewModelNotifier.selectSticker(sticker);
                          Navigator.pop(context);
                        },
                        child: Image.network(
                          sticker.background,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(chatViewModelProvider(widget.roomId));
    final viewModelNotifier =
        ref.read(chatViewModelProvider(widget.roomId).notifier);
    final currentUserId = widget.uid;

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
                final isMe = msg.senderId == widget.uid;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                        if (msg.stickerUrl != null &&
                            msg.stickerUrl!.isNotEmpty)
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.network(
                      viewModel.selectedSticker!.background,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        viewModelNotifier.cancelSticker();
                      },
                      child: const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.black54,
                        child: Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                  openEmojiPicker(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final text = textEditingController.text.trim();
                  final sticker = viewModel.selectedSticker;

                  if (text.isNotEmpty && sticker != null) {
                    viewModelNotifier.sendMixedMessage(
                      widget.uid,
                      text: text,
                      stickerUrl: sticker.background,
                    );
                    textEditingController.clear();
                    viewModelNotifier.cancelSticker();
                  } else if (sticker != null) {
                    viewModelNotifier.sendStickerMessage(
                      currentUserId,
                      sticker.background,
                    );
                    viewModelNotifier.cancelSticker();
                  } else if (text.isNotEmpty) {
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
