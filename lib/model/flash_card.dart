import 'package:disce/model/word.dart';

class FlashCard {
  String id;
  String name;
  List<Word> wordList;

  FlashCard({
    required this.id,
    required this.name,
    required this.wordList,
  });

  factory FlashCard.fromJson(Map<String, dynamic> json) => FlashCard(
        id: json['_id'],
        name: json['name'],
        wordList:
            List<Word>.from(json['wordList'].map((x) => Word.fromJson(x))),
      );
}
