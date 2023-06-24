import 'dart:async';
import 'dart:convert';

import 'package:disce/screen/review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:disce/global.dart' as globals;
import 'package:loading_indicator/loading_indicator.dart';

import '../model/quiz.dart';

class QuizScreen extends StatefulWidget {
  final String flashCardId;
  const QuizScreen({super.key, required this.flashCardId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late double _animatedBar;
  bool _haveQuiz = false;
  bool _isLoading = false;
  List<Quiz> _quizList = [];
  late int _selectIndex = 0;
  late List<int> _answerIndexs;

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
      Uri.https(globals.apiLinks, "/api/v1/quiz/generate", queryParam),
    );

    if (response.statusCode == 200) {
      setState(() {
        _quizList = jsonDecode(response.body)['quizQuestionList']
            .map<Quiz>(
              (x) => Quiz.fromJson(x),
            )
            .toList();
        _isLoading = false;
        _haveQuiz = true;
        startTimer();
      });
    }
    return response;
  }

  void startTimer() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_haveQuiz) {
      setState(() {
        _animatedBar = 0;
      });
    }
    await Future.delayed(const Duration(minutes: 1));
    goToReview();
  }

  void goToReview() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReviewScreen(
            answerIndexs: _answerIndexs,
            quizList: _quizList,
          ),
        ),
      ).then(onGoBack);
    }
  }

  FutureOr onGoBack(dynamic value) {
    Navigator.of(context).pop();
  }

  void setAnswer(int questionIndex, int answerIndex) {
    setState(() {
      _answerIndexs[questionIndex] = answerIndex;
      _selectIndex = _selectIndex + 1;
    });
    if (_selectIndex == 10) {
      _selectIndex = 9;
      goToReview();
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _animatedBar = 370;
      _answerIndexs = List.generate(10, (index) => 0);
    });
    getFlashCard();
  }

  @override
  Widget build(BuildContext context) {
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
                        "Quiz",
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
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  height: 50,
                  child: LoadingIndicator(
                    indicatorType: Indicator.circleStrokeSpin,
                    colors: [Color.fromARGB(255, 104, 107, 255)],
                    strokeWidth: 2,
                  ),
                ),
              )
            : Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 30, 10, 10),
                    child: Container(
                      height: 20,
                      width: 400,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: AnimatedContainer(
                              duration: const Duration(minutes: 1),
                              width: _animatedBar,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      CustomPaint(
                        painter: OpenPainter(),
                      ),
                      CustomPaint(
                        painter: OpenPainter(),
                      )
                    ],
                  ),
                  Center(
                    child: Container(
                      width: 300,
                      height: 400,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 136, 138, 255),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              "${"Question${_selectIndex + 1}"}/ 10",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                              ),
                            ),
                            Text(
                              _quizList[_selectIndex].word,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            SizedBox(
                              height: 270,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (var i = 0; i < 4; i++)
                                      Container(
                                        height: 55,
                                        width: 280,
                                        decoration: const BoxDecoration(
                                          color:
                                              Color.fromARGB(255, 60, 26, 87),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(40)),
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                            setAnswer(_selectIndex, i);
                                          },
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                _quizList[_selectIndex]
                                                    .allAnswer[i],
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Positioned.fill(
                  //   bottom: 50,
                  //   child: Align(
                  //     alignment: Alignment.bottomCenter,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         Container(
                  //           width: 150,
                  //           decoration: const BoxDecoration(
                  //               gradient: LinearGradient(
                  //                 colors: [
                  //                   Color.fromARGB(255, 255, 0, 0),
                  //                   Color.fromARGB(255, 182, 146, 92),
                  //                 ],
                  //               ),
                  //               borderRadius: BorderRadius.only(
                  //                 topLeft: Radius.circular(40),
                  //                 bottomLeft: Radius.circular(40),
                  //               )),
                  //           child: TextButton(
                  //             style: ButtonStyle(
                  //                 splashFactory: NoSplash.splashFactory,
                  //                 overlayColor: MaterialStateColor.resolveWith(
                  //                     (states) => Colors.transparent)),
                  //             onPressed: () {
                  //               debugPrint(_answerIndexs.toString());
                  //               goToReview();
                  //             },
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: const [
                  //                 Text(
                  //                   "Done",
                  //                   style: TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 30,
                  //                     fontWeight: FontWeight.bold,
                  //                   ),
                  //                 ),
                  //                 SizedBox(
                  //                   width: 10,
                  //                 ),
                  //                 Icon(
                  //                   Icons.done_all,
                  //                   color: Colors.white,
                  //                 )
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //         Container(
                  //           width: 150,
                  //           decoration: const BoxDecoration(
                  //               color: Color.fromARGB(255, 59, 59, 59),
                  //               borderRadius: BorderRadius.only(
                  //                 topRight: Radius.circular(40),
                  //                 bottomRight: Radius.circular(40),
                  //               )),
                  //           child: TextButton(
                  //             style: ButtonStyle(
                  //                 splashFactory: NoSplash.splashFactory,
                  //                 overlayColor: MaterialStateColor.resolveWith(
                  //                     (states) => Colors.transparent)),
                  //             onPressed: () {
                  //               if (_selectIndex < 9) {
                  //                 setState(() {
                  //                   _selectIndex = _selectIndex + 1;
                  //                 });
                  //               }
                  //             },
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: const [
                  //                 Text(
                  //                   "Next",
                  //                   style: TextStyle(
                  //                     color: Colors.white,
                  //                     fontSize: 30,
                  //                     fontWeight: FontWeight.bold,
                  //                   ),
                  //                 ),
                  //                 SizedBox(
                  //                   width: 10,
                  //                 ),
                  //                 Icon(
                  //                   Icons.keyboard_double_arrow_right_rounded,
                  //                   color: Colors.white,
                  //                 )
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // )
                ],
              ),
      ),
    );
  }
}

class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = const Color.fromARGB(255, 136, 138, 255)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(200, 180), 50, paint1);
    var paint2 = Paint()
      ..color = const Color.fromARGB(255, 136, 138, 255)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(200, 540), 50, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
