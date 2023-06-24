class Quiz {
  String word;
  List<String> allAnswer;
  int rightAnswerIndex;

  Quiz({
    required this.word,
    required this.allAnswer,
    required this.rightAnswerIndex,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) => Quiz(
      word: json['word'],
      allAnswer: List<String>.from(json['allAnswer'].map((x) => x.toString())),
      rightAnswerIndex: json['rightAnswerIndex']);
}
