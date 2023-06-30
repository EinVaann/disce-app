import 'package:disce/model/word.dart';

class ChatLine {
  String sender;
  List<String> participant;
  String content;
  DateTime time;

  ChatLine({
    required this.sender,
    required this.participant,
    required this.content,
    required this.time,
  });

  static ChatLine fromJson(Map<String, dynamic> json) => ChatLine(
      participant: List<String>.from(json['participant']
          .toString()
          .replaceAll(RegExp(r"\p{P}", unicode: true), "")
          .trim()
          .split(',')),
      sender: json['sender'],
      content: json['content'].toString(),
      time: DateTime.parse((json['time'])));
}
