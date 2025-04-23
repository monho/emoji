import 'package:flutter/material.dart';

class ChatRoomView extends StatefulWidget {
  const ChatRoomView({super.key});

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  final scrollController = ScrollController();
  final textEditingController = TextEditingController();
  final List<String> chatList = [];

  void addMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      chatList.add(text);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    textEditingController.clear();
  }

  @override
  void dispose() {
    scrollController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(232, 238, 242, 1),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              '새로운 채팅',
              style: TextStyle(color: Color.fromRGBO(124, 124, 124, 1)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.separated(
                    controller: scrollController,
                    reverse: false,
                    itemCount: chatList.length,
                    itemBuilder: (context, index) {
                      final message = chatList[index];
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(191, 223, 255, 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(message),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: textEditingController,
                          decoration: const InputDecoration(
                            hintText: '메시지를 입력하세요',
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                          onSubmitted: addMessage,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.emoji_emotions_outlined,
                        ), // 😊 ← 이거!
                        onPressed: () {
                          // TODO: 이모지 선택 창 띄우기
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () => addMessage(textEditingController.text),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
