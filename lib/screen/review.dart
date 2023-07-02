import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:disce/global.dart' as globals;
import 'package:loading_indicator/loading_indicator.dart';
import '../model/quiz.dart';

class ReviewScreen extends StatefulWidget {
  final List<int> answerIndexs;
  final List<Quiz> quizList;
  const ReviewScreen({
    super.key,
    required this.answerIndexs,
    required this.quizList,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late int _numOfRight;
  bool _isLoading = false;
  void reviewAnswers() {
    int numOfRightAnswers = 0;
    for (var i = 0; i < 10; i++) {
      if (widget.quizList[i].rightAnswerIndex == widget.answerIndexs[i]) {
        numOfRightAnswers += 1;
      }
    }
    setState(() {
      _numOfRight = numOfRightAnswers;
    });
  }

  Future<http.Response> sendSaveResult() async {
    setState(() {
      _isLoading = true;
    });
    String token = await SessionManager().get('accessToken');
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, dynamic> jsonBody = {
      'result': _numOfRight,
    };
    debugPrint(jsonEncode(jsonBody));
    Map<String, String> queryParam = {
      'token': token,
    };
    final response = await http.post(
      Uri.https(globals.apiLinks, "/api/v1/quiz/save-result", queryParam),
      headers: headers,
      body: jsonEncode(jsonBody),
    );
    setState(() {
      _isLoading = false;
    });
    debugPrint(response.body);
    if (response.statusCode == 200) {
      showSnackBar('Đã lưu kết quả');
    } else {
      showSnackBar('Error');
    }
    return response;
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
  void initState() {
    setState(() {
      _numOfRight = 0;
    });
    reviewAnswers();
    sendSaveResult();
    super.initState();
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
          preferredSize: const Size.fromHeight(70),
          child: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
                color: Color.fromARGB(255, 136, 138, 255),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
            child: SafeArea(
              child: Padding(
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
                      children: const [
                        Text(
                          "Review",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SizedBox.expand(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Container(
                  width: 300,
                  height: 230,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 136, 138, 255),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Stack(children: [
                    Positioned.fill(
                        bottom: 0,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 250,
                            height: 200,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color.fromARGB(255, 255, 175, 180),
                                  Color.fromARGB(255, 242, 203, 205),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 90,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 136, 138, 255),
                                  ),
                                  child: Center(
                                      child: Text(
                                    "$_numOfRight/10",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  )),
                                ),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    'You answered $_numOfRight out of 10 questions right.',
                                    maxLines: 4,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ))
                  ]),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      "Your answers: ",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 242, 242, 242),
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        for (var i = 0; i < 10; i++)
                          anwserRow(
                              (i + 1).toString(),
                              widget.quizList[i].word,
                              widget.quizList[i]
                                  .allAnswer[widget.answerIndexs[i]],
                              widget.quizList[i].rightAnswerIndex ==
                                  widget.answerIndexs[i],
                              widget.quizList[i].allAnswer[
                                  widget.quizList[i].rightAnswerIndex])
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}

Widget anwserRow(String num, String question, String answer, bool isCorrect,
    String rightAnswer) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
    child: Row(
      children: [
        Container(
          width: 70,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 217, 217, 217),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                num,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.capitalize(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isCorrect ? Colors.green : Colors.red,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 150,
              child: Text(
                answer,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isCorrect ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            !isCorrect
                ? SizedBox(
                    width: 150,
                    child: Text(
                      rightAnswer,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ],
    ),
  );
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
