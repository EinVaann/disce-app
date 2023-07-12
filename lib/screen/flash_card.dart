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

class FlashCardScreen extends StatefulWidget {
  final String flashCardId;
  final Color appBarColor;
  final Function goToPage;
  const FlashCardScreen({
    super.key,
    required this.flashCardId,
    required this.appBarColor,
    required this.goToPage,
  });

  @override
  State<FlashCardScreen> createState() => _FlashCardScreenState();
}

class _FlashCardScreenState extends State<FlashCardScreen>
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
      Uri.https(globals.apiLinks, "/api/v1/flashCard/get", queryParam),
    );
    if (response.statusCode == 200) {
      setState(() {
        _flashCard = FlashCard.fromJson(jsonDecode(response.body)['flashCard']);
        _isLoading = false;
      });
    }
    return response;
  }

  Future<http.Response> sendDeleteRequest() async {
    setState(() {
      _isLoading = true;
    });
    String token = await SessionManager().get('accessToken');
    Map<String, String> queryParam = {
      'token': token,
      'cardId': widget.flashCardId
    };
    final response = await http.delete(
      Uri.https(globals.apiLinks, "/api/v1/flashCard/delete", queryParam),
    );
    if (response.statusCode == 200) {
      goBack();
      showSnackBar('Xoá FlashCard thành công.');
    } else {
      showSnackBar('Error');
    }
    return response;
  }

  Future<http.Response> sendEditRequest() async {
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
    Map<String, String> jsonBody = {
      'flashCardId': widget.flashCardId,
      'newName': _nameController.text,
    };
    final response = await http.put(
      Uri.https(globals.apiLinks, "/api/v1/flashCard/rename", queryParam),
      headers: headers,
      body: jsonEncode(jsonBody),
    );
    if (response.statusCode == 200) {
      getFlashCard();
      showSnackBar('Editing Success');
    } else {
      showSnackBar('Error');
    }
    return response;
  }

  FutureOr onGoBack(dynamic value) {
    if (value == "edited") {
      getFlashCard();
    }
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

  void showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Alert',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          "Are you sure that you want to delete this?",
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              sendDeleteRequest();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  void showEdit() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Renaming Flash Card',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: 90,
          child: Column(
            children: [
              const Text(
                "Enter new card name.",
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(8.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 104, 107, 255),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 172, 172, 172),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _nameController.text = '';
            },
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              sendEditRequest();
            },
            child: const Text(
              "Confirm",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showOption() {
    showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: true,
      barrierColor: const Color.fromARGB(255, 137, 143, 253).withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 350),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 330,
            margin: const EdgeInsets.only(bottom: 0, left: 0, right: 0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Text(
                        "Action",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Linotte',
                          fontSize: 22,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WordListScreen(
                              appBarColor: widget.appBarColor,
                              flashCard: _flashCard,
                            ),
                          ),
                        ).then(onGoBack);
                      },
                      child: const SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                          child: Text(
                            'Xem danh sách từ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Linotte',
                              decoration: TextDecoration.none,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (_flashCard.wordList.length < 10) {
                          Navigator.pop(context);
                          showSnackBar("Need atleast 10 words to do quiz");
                        } else {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QuizScreen(
                                        flashCardId: _flashCard.id,
                                      )));
                        }
                      },
                      child: const SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                          child: Text(
                            'Kiểm tra nhanh',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Linotte',
                              decoration: TextDecoration.none,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 2,
                      endIndent: 10,
                      indent: 10,
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Text(
                        "Edit",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Linotte',
                          fontSize: 22,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        showEdit();
                      },
                      child: const SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                          child: Text(
                            'Sửa tên Flash Card',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Linotte',
                              decoration: TextDecoration.none,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context, rootNavigator: true).pop();
                        showDeleteConfirmation();
                      },
                      child: const SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
                          child: Text(
                            'Xóa Flash Card',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                              fontFamily: 'Linotte',
                              decoration: TextDecoration.none,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 2,
                      endIndent: 10,
                      indent: 10,
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
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
                  Positioned(
                    bottom: 10,
                    right: 20,
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        // color: const Color.fromARGB(120, 230, 230, 230),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () {
                            showOption();
                          },
                          icon: const Icon(
                            Icons.tune,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
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
      );
    }
  }

  List<Widget> stackOfCard() {
    List<Widget> children = [];
    List<Word> wordList = _flashCard.wordList.reversed.toList();
    for (var i = 0; i < wordList.length; i++) {
      children.add(
        CardWidget(
          enable: true,
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
