import 'dart:convert';

import 'package:disce/providers/chat_provider.dart';
import 'package:disce/utils/socket_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/chat_lines.dart';

class SocketMethods {
  final _socketClient = SocketClient.instance.socket!;

  joinRoom(String userId, String otherUserId) {
    _socketClient
        .emit('join_room', {'userId': userId, 'otherUserId': otherUserId});
  }

  leaveRoom(String userId, String otherUserId) {
    _socketClient
        .emit('leave_room', {'userId': userId, 'otherUserId': otherUserId});
  }

  receiveSavedMsg(BuildContext context) {
    _socketClient.on('pre_msg', (data) {
      var decodeData = json.decode(data);
      List<ChatLine> cl = [];
      debugPrint("aaaaaaaa" + data);
      for (var i in decodeData) {
        debugPrint(i.toString());
        cl.add(ChatLine.fromJson(i));
      }
      for (var i in cl) {
        debugPrint(i.content);
      }
      Provider.of<ChatStateProvider>(context, listen: false)
          .updateChatState(chatLine: cl);
    });
  }
}
