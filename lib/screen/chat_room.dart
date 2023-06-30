import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/scheduler/binding.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../model/chat_lines.dart';

class ChatRoomScreen extends StatefulWidget {
  final String userId;
  final String otherUserId;
  final String otherUsername;
  final IO.Socket socket;
  const ChatRoomScreen({
    super.key,
    required this.userId,
    required this.otherUserId,
    required this.socket,
    required this.otherUsername,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late TextEditingController _controller;
  late ScrollController _scrollController;
  late List<ChatLine> _chatLine;
  final FocusNode _focusNode = FocusNode();
  late DateTime _before;
  void joinAndListen() {
    widget.socket.emit(
      'join_room',
      {
        'userId': widget.userId,
        'otherUserId': widget.otherUserId,
      },
    );
    widget.socket.on(
      'pre_msg',
      (data) {
        var decodeData = json.decode(data);
        List<ChatLine> cl = [];
        for (var i in decodeData) {
          debugPrint(i.toString());
          cl.add(ChatLine.fromJson(i));
        }
        if (mounted) {
          setState(() {
            _chatLine = cl;
          });
          // scrollToBotton();
        }
      },
    );
    widget.socket.on(
      'rei_msg',
      (data) {
        debugPrint("receive message");
        var decodeData = json.decode(data);
        List<ChatLine> cl = _chatLine;
        cl.add(ChatLine.fromJson(decodeData));
        if (mounted) {
          setState(() {
            _chatLine = cl;
          });
          // scrollToBotton();
        }
      },
    );
  }

  void sendMessage() {
    if (_controller.text != '') {
      widget.socket.emit(
        'send_msg',
        {
          'userId': widget.userId,
          'otherUserId': widget.otherUserId,
          'content': _controller.text,
        },
      );
      _controller.text = '';
      _focusNode.unfocus();
      // scrollToBotton();
    }
  }

  void scrollToBotton() {
    debugPrint("scrol?");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _controller = TextEditingController();
      _scrollController = ScrollController();
      _chatLine = [];
      _before = DateTime(1900);
    });
    joinAndListen();
    // scrollToBotton();
    // _focusNode.addListener(() {
    //   if (_focusNode.hasFocus) {
    //     debugPrint('scroll');
    //     scrollToBotton();
    //   }
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {_focusNode.unfocus()},
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
            child: SafeArea(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.otherUsername,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 65),
          child: Container(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              reverse: true,
              // controller: _scrollController,
              child: Column(
                children: [
                  ..._chatLines(_chatLine, _before, widget.userId),
                  const SizedBox(
                    height: 30,
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              focusNode: _focusNode,
              controller: _controller,
              decoration: InputDecoration(
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 104, 107, 255),
                    width: 2,
                  ),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromARGB(255, 104, 107, 255),
                    width: 2,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Color.fromARGB(255, 104, 107, 255),
                  ),
                  onPressed: () {
                    sendMessage();
                  },
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

List<Widget> _chatLines(
    List<ChatLine> chatLines, DateTime before, String mySelf) {
  List<Widget> children = [];
  for (var i = 0; i < chatLines.length; i++) {
    DateTime temp = DateTime(
        chatLines[i].time.year, chatLines[i].time.month, chatLines[i].time.day);
    if (temp.isAfter(before)) {
      before = temp;
      children.add(Center(
        child: Text(chatLines[i].time.toString().substring(0, 10)),
      ));
    }
    children.add(Align(
      alignment: chatLines[i].sender == mySelf
          ? Alignment.bottomRight
          : Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300, minWidth: 100),
          decoration: BoxDecoration(
            color: chatLines[i].sender == mySelf
                ? Colors.blueAccent
                : const Color.fromARGB(255, 215, 215, 215),
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
                child: Text(
                  chatLines[i].content,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Positioned(
                bottom: 5,
                right: 10,
                child: Text(
                    "${chatLines[i].time.hour.toString().padLeft(2, '0')}:${chatLines[i].time.minute.toString().padLeft(2, '0')}"),
              )
            ],
          ),
        ),
      ),
    ));
  }

  return children;
}
