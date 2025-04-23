import 'package:flutter/material.dart';

class ChatRoomView extends StatelessWidget {
  const ChatRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    // Future<void> onFieldSubmitted() async {
    //   addMessage();

    //   // 스크롤 위치를 맨 아래로 이동 시킴
    //   scrollController.animateTo(
    //     0,
    //     duration: const Duration(milliseconds: 300),
    //     curve: Curves.easeInOut,
    //   );

    //   textEditingController.text = '';
    // }


    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(232, 238, 242, 1),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
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
              onTap: (){
                FocusScope.of(context).unfocus();
              },
              child: Align(
                child: Text("ss"),
              ),
            ),
            // Align(
            //     alignment: Alignment.topCenter,
            //   	child: ListView.separated(
            //     shrinkWrap: true,
            //     reverse: true,
            //     controoler:scrollController,
            //     itemCount: chatList.length,
            //     itemBuilder: (context, index) {
            //     return Bubble(chat: chatList[index]);
            //     },
            //   );
            // )
          ),
        ],
      ),
    );
  }
}
