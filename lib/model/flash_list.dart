class FlashList {
  String id;
  String name;
  List<String> wordList;

  FlashList({
    required this.id,
    required this.name,
    required this.wordList,
  });

  factory FlashList.fromJson(Map<String, dynamic> json) => FlashList(
        id: json['_id'],
        name: json['name'],
        wordList: List<String>.from(json['wordList'].map((x) => x.toString())),
      );
}
