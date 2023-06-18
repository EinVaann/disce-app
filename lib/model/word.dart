import 'dart:convert';
import 'dart:core';

import 'package:disce/model/word_meaning.dart';

class Word {
  String id;
  String word;
  String pronunciation;
  List<WordMeaning> meaning;

  Word(
      {required this.id,
      required this.word,
      required this.pronunciation,
      required this.meaning});

  factory Word.fromJson(Map<String, dynamic> json) => Word(
        id: json['_id'],
        word: json['word'],
        pronunciation: json['pronunciation'],
        meaning: List<WordMeaning>.from(
            json['meaning'].map((x) => WordMeaning.fromJsonToWordMeaning(x))),
      );

  // Map<String, String> toJson() => {
  //       '_id': id,
  //       'word': word,
  //       'pronunciation': pronunciation,
  //       "meaning": meaning.toJsonFromWordMeaning().toString(),
  //     };
}
