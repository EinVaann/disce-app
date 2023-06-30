import 'package:disce/model/chat_lines.dart';
import 'package:disce/model/word.dart';

class ChatBox {
  List<ChatLine> chatLine;

  ChatBox({required this.chatLine});

  Map<String, dynamic> toJson() => {
        'chatLine': chatLine.toString(),
      };
}
