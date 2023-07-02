import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:disce/screen/flash_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:disce/global.dart' as globals;
import 'package:loading_indicator/loading_indicator.dart';

import '../model/flash_list.dart';
import '../screen/quiz.dart';

class HomeNav extends StatefulWidget {
  final Function goToPage;
  const HomeNav({super.key, required this.goToPage});

  @override
  State<HomeNav> createState() => _HomeNavState();
}

class _HomeNavState extends State<HomeNav> {
  late List<FlashList> _list;
  late TextEditingController _searchController;
  bool _isLoading = false;
  final List<Color> _colorList = [
    const Color.fromARGB(255, 136, 138, 255),
    const Color.fromARGB(255, 255, 136, 136),
    const Color.fromARGB(255, 84, 159, 106),
    const Color.fromARGB(255, 136, 209, 255),
  ];
  late TextEditingController _nameController;

  Future<http.Response> getFlashCard() async {
    setState(() {
      _isLoading = true;
    });
    String token = await SessionManager().get('accessToken');
    // Map<String, String> headers = {
    //   "Content-type": "application/json; charset=UTF-8"
    // };
    Map<String, String> queryParam = {'token': token};
    final response = await http.get(
      Uri.https(globals.apiLinks, "/api/v1/flashCard", queryParam),
      // headers: headers,
    );
    List<FlashList> tempList = [];
    for (var i in json.decode(response.body)['cardList']) {
      tempList.add(FlashList.fromJson(i));
    }
    if (mounted) {
      setState(() {
        _list = tempList;
        _isLoading = false;
      });
    }
    return response;
  }

  FutureOr onGoBack(dynamic value) {
    getFlashCard();
  }

  Future<http.Response> sendCreateRequest() async {
    String token = await SessionManager().get('accessToken');
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {"name": _nameController.text};
    Map<String, String> queryParam = {'token': token};
    final response = await http.post(
      Uri.https(globals.apiLinks, "/api/v1/flashCard/create", queryParam),
      headers: headers,
      body: jsonEncode(jsonBody),
    );
    if (response.statusCode == 200) {
      getFlashCard();
      showCreateSuccess();
    }
    _nameController.text = '';
    return response;
  }

  void startQuickQuiz() {
    List<FlashList> temp = [];
    for (var i in _list) {
      if (i.wordList.length >= 10) {
        temp.add(i);
      }
    }
    if (temp.isNotEmpty) {
      var randomIndex = Random().nextInt(temp.length);
      String selectedFlashId = temp[randomIndex].id;
      goToQuiz(selectedFlashId);
    } else {
      showSnackBar("Không có FlashCard nào đủ từ để kiểm tra");
    }
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

  void goToQuiz(String flashCardId) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QuizScreen(
                  flashCardId: flashCardId,
                )));
  }

  void showCreateSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Flash Card Created!!',
          style: TextStyle(fontWeight: FontWeight.bold),
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
    super.initState();
    getFlashCard();
    setState(() {
      _list = [];
      _nameController = TextEditingController();
      _searchController = TextEditingController();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void showCreate() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Creating Flash Card',
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
                "Enter your card name.",
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
              sendCreateRequest();
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                child: TextFormField(
                  controller: _searchController,
                  onFieldSubmitted: (text) {
                    if (text != '') {
                      widget.goToPage(1, text);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Tìm kiếm từ vựng",
                    contentPadding: const EdgeInsets.all(8.0),
                    prefixIcon: SizedBox(
                      height: 40,
                      child: InkWell(
                        onTap: () {
                          if (_searchController.text != '') {
                            FocusManager.instance.primaryFocus?.unfocus();
                            widget.goToPage(1, _searchController.text);
                          }
                        },
                        child: const Icon(
                          Icons.search,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 104, 107, 255),
                        width: 2,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 172, 172, 172),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () {
                          startQuickQuiz();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 251, 241, 227),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                Text(
                                  "Hỏi Nhanh",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 82, 95, 127),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25,
                                  ),
                                ),
                                Text(
                                  "Kiểm tra quá trình",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 82, 95, 127),
                                  ),
                                )
                              ],
                            ),
                            const Icon(
                              Icons.task_alt,
                              color: Color.fromARGB(255, 82, 95, 127),
                              size: 40,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 84, 168, 216),
                            Color.fromARGB(255, 183, 138, 255)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: TextButton(
                        onPressed: () {
                          showCreate();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            Text(
                              "Thẻ mới",
                              style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255),
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            Icon(
                              Icons.history_edu,
                              color: Color.fromARGB(255, 255, 255, 255),
                              size: 40,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            //Start Flash Cards from here
            ..._showFlashCard(),
          ],
        ),
      ),
    );
  }

  List<Widget> _showFlashCard() {
    final children = <Widget>[];
    if (_isLoading) {
      children.add(const SizedBox(
        height: 200,
        child: Center(
          child: SizedBox(
            height: 50,
            child: LoadingIndicator(
              indicatorType: Indicator.circleStrokeSpin,
              colors: [Color.fromARGB(255, 104, 107, 255)],
              strokeWidth: 2,
            ),
          ),
        ),
      ));
      return children;
    }
    if (_list.isEmpty) {
      children.add(Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            SizedBox(
              height: 50,
            ),
            Text("You don't have any flash card yet. Try create one"),
          ],
        ),
      ));
    }
    for (var i = 0; i < _list.length; i++) {
      children.add(
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: _colorList[i % 4],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashCardScreen(
                              flashCardId: _list[i].id,
                              appBarColor: _colorList[i % 4],
                              goToPage: widget.goToPage,
                            ),
                          ),
                        ).then(onGoBack);
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "FlashCard",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            Text(
                              _list[i].name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 27,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
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
                        _list[i].wordList.length.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    return children;
  }
}
