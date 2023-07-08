import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:http/http.dart' as http;
import 'package:disce/global.dart' as globals;
import '../model/flash_card.dart';

class WordListScreen extends StatefulWidget {
  final FlashCard flashCard;
  final Color appBarColor;
  const WordListScreen({
    super.key,
    required this.flashCard,
    required this.appBarColor,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late List<bool> _selectedIndex = [];
  late TextEditingController _listTextController;
  @override
  void initState() {
    super.initState();
    setState(() {
      _listTextController = TextEditingController();
      _selectedIndex = List<bool>.generate(
          widget.flashCard.wordList.length, (index) => false);
    });
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
          "Are you sure that you want to delete these?",
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

  Future<http.Response> sendDeleteRequest() async {
    setState(() {
      _isLoading = true;
    });
    List<String> wordIds = [];
    for (var i = 0; i < _selectedIndex.length; i++) {
      if (_selectedIndex[i]) {
        wordIds.add(widget.flashCard.wordList[i].id);
      }
    }
    String token = await SessionManager().get('accessToken');
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, dynamic> jsonBody = {
      'flashCardId': widget.flashCard.id,
      'wordIds': wordIds,
    };
    debugPrint(jsonEncode(jsonBody));
    Map<String, String> queryParam = {
      'token': token,
    };
    final response = await http.put(
      Uri.https(globals.apiLinks, "/api/v1/flashCard/remove-multiple-word",
          queryParam),
      headers: headers,
      body: jsonEncode(jsonBody),
    );
    setState(() {
      _isLoading = false;
    });
    debugPrint(response.body);
    if (response.statusCode == 200) {
      goBack();
      showSnackBar('Xoá Từ thành công.');
    } else {
      showSnackBar('Error');
    }
    return response;
  }

  void goBack() {
    Navigator.of(context).pop("edited");
  }

  void showAddWord() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Thêm từ vào Flash Card',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              const Text(
                "Danh sách từ \n(phân cách bởi dấu phẩy)",
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                child: TextFormField(
                  maxLines: 7,
                  controller: _listTextController,
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
              _listTextController.text = '';
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
              sendAddWordRequest();
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

  Future<http.Response> sendAddWordRequest() async {
    setState(() {
      _isLoading = true;
    });
    List<String> words = _listTextController.text.split(',');
    for (var i = 0; i < words.length; i++) {
      words[i] = words[i].toLowerCase().trim();
    }
    String token = await SessionManager().get('accessToken');
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, dynamic> jsonBody = {
      'flashCardId': widget.flashCard.id,
      'words': words,
    };
    debugPrint(jsonEncode(jsonBody));
    Map<String, String> queryParam = {
      'token': token,
    };
    final response = await http.put(
      Uri.https(
          globals.apiLinks, "/api/v1/flashCard/add-multiple-word", queryParam),
      headers: headers,
      body: jsonEncode(jsonBody),
    );
    setState(() {
      _isLoading = false;
    });
    debugPrint(response.body);
    if (response.statusCode == 200) {
      goBack();
      showSnackBar('Thêm từ thành công.');
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
                              "FlashCard - Word List",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              widget.flashCard.name,
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
                          widget.flashCard.wordList.length.toString(),
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
                        child: TextButton(
                            onPressed: () {
                              showAddWord();
                            },
                            child: const Center(
                              child: Text(
                                "Add",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: SizedBox.expand(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  for (var i = 0; i < widget.flashCard.wordList.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 238, 240, 247),
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.flashCard.wordList[i].word.capitalize(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedIndex[i] = !_selectedIndex[i];
                                  });
                                },
                                child: Icon(
                                  _selectedIndex[i]
                                      ? Icons.check_box_outlined
                                      : Icons.check_box_outline_blank,
                                  color: Colors.black,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _selectedIndex.contains(true)
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: 200,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 198, 68, 68),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: TextButton(
                    style: ButtonStyle(
                      splashFactory: NoSplash.splashFactory,
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => Colors.transparent),
                    ),
                    onPressed: () {
                      showDeleteConfirmation();
                    },
                    child: const Center(
                        child: Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                  ),
                ),
              )
            : Container(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      );
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
