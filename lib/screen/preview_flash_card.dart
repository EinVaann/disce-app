import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:disce/screen/quiz.dart';
import 'package:disce/screen/word_list.dart';
import 'package:disce/widget/card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:disce/global.dart' as globals;
import 'package:loading_indicator/loading_indicator.dart';

import '../model/flash_card.dart';
import '../model/word.dart';

class PreViewFlashCardScreen extends StatefulWidget {
  final String flashCardId;
  final Color appBarColor;
  final Function goToPage;
  const PreViewFlashCardScreen({
    super.key,
    required this.flashCardId,
    required this.appBarColor,
    required this.goToPage,
  });

  @override
  State<PreViewFlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<PreViewFlashCardScreen>
    with SingleTickerProviderStateMixin {
  late FlashCard _flashCard;
  bool _isLoading = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    getFlashCard();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<http.Response> getFlashCard() async {
    setState(() {
      _isLoading = true;
    });
    String token = await SessionManager().get('accessToken');
    Map<String, String> queryParam = {
      'token': token,
      'cardId': widget.flashCardId
    };
    final response = await http.get(
      Uri.https(globals.apiLinks, "/api/v1/flashCard/get-preview", queryParam),
    );
    if (response.statusCode == 200) {
      setState(() {
        _flashCard = FlashCard.fromJson(jsonDecode(response.body)['flashCard']);
        _isLoading = false;
      });
    }
    return response;
  }

  Future<http.Response> sendCopyRequest() async {
    setState(() {
      _isLoading = true;
    });
    String token = await SessionManager().get('accessToken');
    Map<String, String> queryParam = {
      'token': token,
    };
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, dynamic> jsonBody = {
      'flashCardId': widget.flashCardId,
    };
    final response = await http.post(
      Uri.https(globals.apiLinks, "/api/v1/flashCard/make-a-copy", queryParam),
      headers: headers,
      body: jsonEncode(jsonBody),
    );
    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      goBack();
      showSnackBar("Copied Flash Card");
    } else {
      showSnackBar("Error");
    }
    return response;
  }

  void goBack() {
    Navigator.of(context).pop();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            // Some code to undo the change.
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: const Center(
          child: SizedBox(
            height: 50,
            child: LoadingIndicator(
              indicatorType: Indicator.circleStrokeSpin,
              colors: [Color.fromARGB(255, 104, 107, 255)],
              strokeWidth: 2,
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            height: double.infinity,
            decoration: BoxDecoration(
                color: widget.appBarColor,
                borderRadius: const BorderRadius.only(
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
                            const Text(
                              "FlashCard",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              _flashCard.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 20,
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(120, 230, 230, 230),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _flashCard.wordList.length.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                child: Stack(
                  children: [
                    ...stackOfCard(),
                  ],
                ),
              ),
              const SizedBox(
                height: 70,
              )
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: 200,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: TextButton(
              style: ButtonStyle(
                splashFactory: NoSplash.splashFactory,
                overlayColor: MaterialStateColor.resolveWith(
                    (states) => Colors.transparent),
              ),
              onPressed: () {
                sendCopyRequest();
              },
              child: const Center(
                  child: Text(
                "Copy",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              )),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    }
  }

  List<Widget> stackOfCard() {
    List<Widget> children = [];
    List<Word> wordList = _flashCard.wordList.reversed.toList();
    for (var i = 0; i < wordList.length; i++) {
      children.add(
        CardWidget(
          enable: false,
          word: wordList[i],
          isFront: i == wordList.length - 1,
          changeOrder: putTopToBottom,
          goToPage: widget.goToPage,
        ),
      );
    }
    return children;
  }

  void putTopToBottom() {
    List<Word> wordList = _flashCard.wordList;
    Word firstWord = wordList.first;
    wordList.remove(firstWord);
    wordList.add(firstWord);
    setState(() {
      _flashCard.wordList = wordList;
    });
  }
}
