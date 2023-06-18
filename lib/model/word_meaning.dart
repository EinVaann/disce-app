import 'dart:ffi';

class WordMeaning {
  String wordType;
  String meaning;
  List<String> usage;

  WordMeaning({
    required this.wordType,
    required this.meaning,
    required this.usage,
  });

  factory WordMeaning.fromJsonToWordMeaning(Map<String, dynamic> json) =>
      WordMeaning(
        wordType: json['wordType'],
        meaning: json['meaning'],
        usage: List<String>.from(json['usage'].map((x) => x.toString())),
      );

  // Map<String, String> toJsonFromWordMeaning() => {
  //       "wordType": wordType,
  //       "meaning": meaning,
  //       "usage": usage.join(','),
  //     };
}
