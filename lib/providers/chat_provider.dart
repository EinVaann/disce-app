import 'package:disce/model/chat_box.dart';
import 'package:disce/model/chat_lines.dart';
import 'package:flutter/material.dart';

class ChatStateProvider extends ChangeNotifier {
  ChatBox _chatState = ChatBox(chatLine: []);

  Map<String, dynamic> get chatState => _chatState.toJson();

  void updateChatState({
    required chatLine,
  }) {
    debugPrint("Updating chats");
    _chatState = ChatBox(chatLine: chatLine);
    notifyListeners();
  }
}
