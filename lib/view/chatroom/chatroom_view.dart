import 'package:flutter/material.dart';

class ChatRoomView extends StatefulWidget {
  const ChatRoomView({super.key});

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  final scrollController = ScrollController();
  final textEditingController = TextEditingController();
  final List<String> chatList = []; // 임시 대체. 나중엔 MessageModel 리스트로 대체

  void addMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      chatList.add(text); // ✅ 아래로 추가
    });
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
              child: ListView.separated(
                controller: scrollController,
                reverse: false,
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  final message = chatList[index];
                  return Align(
                    alignment: Alignment.centerRight, // 임시: 항상 오른쪽 정렬
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue.shade100,
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
          const Divider(height: 1),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: InputBorder.none,
                      ),
                      onSubmitted: addMessage,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => addMessage(textEditingController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
