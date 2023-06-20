import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:disce/global.dart' as globals;
import 'package:loading_indicator/loading_indicator.dart';

import '../model/flash_list.dart';
import '../model/word.dart';

class DictNav extends StatefulWidget {
  final String searchText;
  const DictNav({
    super.key,
    required this.searchText,
  });

  @override
  State<DictNav> createState() => _DictNavState();
}

class _DictNavState extends State<DictNav> {
  late TextEditingController _searchController;
  late List<FlashList> _fList = [];
  List<Word> _list = [];
  bool _isLoading = false;
  bool _foundExact = false;
  bool _isSearching = false;
  bool _found = false;
  late Word _exactWord;
  late List<String> _recentWord = [];
  Future<http.Response> getFlashCard() async {
    String token = await SessionManager().get('accessToken');
    Map<String, String> queryParam = {'token': token};
    final response = await http.get(
      Uri.https(globals.apiLinks, "/api/v1/flashCard", queryParam),
    );
    List<FlashList> tempList = [];
    for (var i in json.decode(response.body)['cardList']) {
      tempList.add(FlashList.fromJson(i));
    }
    if (mounted) {
      setState(() {
        _fList = tempList;
      });
    }
    return response;
  }

  Future<http.Response> sendAddWordRequest(String flashCardId) async {
    String token = await SessionManager().get('accessToken');
    Map<String, String> queryParam = {'token': token};
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'flashCardId': flashCardId,
      'wordId': _exactWord.id,
    };
    final response = await http.put(
      Uri.https(globals.apiLinks, "/api/v1/flashCard/addWord", queryParam),
      headers: headers,
      body: jsonEncode(jsonBody),
    );
    debugPrint(response.body.toString());
    if (response.statusCode == 200) {
      showAddSuccess();
    }
    return response;
  }

  void showAddSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Đã thêm vào FlashCard!!',
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

  Future<http.Response> getWord() async {
    String token = await SessionManager().get('accessToken');
    dynamic recentWord = await SessionManager().get('recentWord');
    List<String> tempRecent = [];
    if (recentWord != null) {
      tempRecent = recentWord
          .toString()
          .trim()
          .replaceAll(RegExp(r'\[|\]'), '')
          .split(',');
    }
    List<String> tempRecent2 = [];
    if (tempRecent.isNotEmpty) {
      for (var i in tempRecent) {
        if (i.isNotEmpty) {
          tempRecent2.add(i.trim());
        }
      }
    }
    setState(() {
      _isSearching = _searchController.text != '';
      _isLoading = true;
      _found = false;
      _foundExact = false;
      _recentWord = tempRecent2.isNotEmpty ? tempRecent2 : [];
    });
    // Map<String, String> headers = {
    //   "Content-type": "application/json; charset=UTF-8"
    // };
    Map<String, String> queryParam = {
      'token': token,
      'search_query': _searchController.text
    };
    final response = await http.get(
      Uri.https(globals.apiLinks, "/api/v1/words/find", queryParam),
      // headers: headers,
    );
    List<Word> tempList = [];
    for (var i in json.decode(response.body)['queriedWord']) {
      tempList.add(Word.fromJson(i));
    }
    if (mounted) {
      setState(() {
        _list = tempList;
        if (tempList.isNotEmpty) {
          if (tempList[0].word == _searchController.text) {
            _foundExact = true;
            _exactWord = tempList[0];
            if (!_recentWord.contains(tempList[0].word)) {
              if (_recentWord.isNotEmpty && _recentWord.length == 10) {
                _recentWord.remove(recentWord.last);
              }
              _recentWord.add(tempList[0].word);
            }
          } else {
            _found = true;
          }
        }
        _isLoading = false;
      });
      await SessionManager().set("recentWord", _recentWord.toString());
    }

    return response;
  }

  void showAddOption() {
    showGeneralDialog(
      barrierLabel: "Label",
      barrierDismissible: true,
      barrierColor: const Color.fromARGB(255, 71, 79, 255).withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 350),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 250,
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
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Column(
                  children: [
                    const Text(
                      "Lưu vào Flash Card.",
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Linotte',
                        fontSize: 30,
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i in _fList)
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                  sendAddWordRequest(i.id);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      const Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(8, 0, 8, 0),
                                        child: Icon(Icons.filter_none_sharp),
                                      ),
                                      Text(
                                        i.name,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Linotte',
                                          decoration: TextDecoration.none,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
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

  void setRecentWordToSession() async {
    await SessionManager().set("recentWord", _recentWord.toString());
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _searchController = TextEditingController();
      _searchController.text = widget.searchText;
      _isSearching = _searchController.text != '';
      _found = false;
      _foundExact = false;
    });
    getFlashCard();
    getWord();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  child: TextFormField(
                    controller: _searchController,
                    onFieldSubmitted: (text) {
                      getWord();
                    },
                    decoration: InputDecoration(
                      hintText: "Tìm kiếm từ vựng",
                      contentPadding: const EdgeInsets.all(8.0),
                      prefixIcon: SizedBox(
                        height: 40,
                        child: InkWell(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            getWord();
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
                height: 5,
              ),
              _isSearching
                  ? _isLoading
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
                      : _foundExact
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _list[0].word.capitalize(),
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "/${_list[0].pronunciation}/",
                                              style: const TextStyle(
                                                fontSize: 20,
                                                // fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.volume_up),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8, 0, 8, 0),
                                              child: IconButton(
                                                icon: const Icon(Icons.close),
                                                onPressed: () {
                                                  setState(() {
                                                    _searchController.text = '';
                                                    getWord();
                                                  });
                                                },
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...wordMeaningList(),
                                  const SizedBox(
                                    height: 50,
                                  )
                                ],
                              ),
                            )
                          : _found
                              ? Column(
                                  children: [
                                    const Text(
                                        "Có thể bạn đang tìm các từ này:"),
                                    ...similarWordList(),
                                  ],
                                )
                              : const Text("Không tìm thấy từ nào phù hợp")
                  : Column(
                      children: [
                        const Text("Các từ tìm kiểm gần đây"),
                        ...recentWordList(),
                      ],
                    ),
            ],
          ),
        ),
        floatingActionButton: _foundExact && _fList.isNotEmpty
            ? FloatingActionButton(
                onPressed: () {
                  showAddOption();
                },
                // elevation: 3,
                child: const Icon(Icons.add_to_photos),
              )
            : Container(),
      ),
    );
  }

  List<Widget> recentWordList() {
    List<Widget> children = [];
    if (_recentWord.isNotEmpty) {
      for (var i = 0; i < _recentWord.length && i < 10; i++) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 238, 240, 247),
                  borderRadius: BorderRadius.circular(10)),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _searchController.text = _recentWord[i];
                  });
                  getWord();
                },
                onLongPress: () {
                  setState(() {
                    if (_recentWord.isNotEmpty) {
                      _recentWord.remove(_recentWord[i]);
                    }
                  });
                  setRecentWordToSession();
                },
                child: Center(
                  child: Text(
                    _recentWord[i].capitalize(),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 82, 95, 127),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return children;
  }

  List<Widget> similarWordList() {
    List<Widget> children = [];
    if (_list.isNotEmpty) {
      for (var i = 0; i < _list.length && i < 10; i++) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 238, 240, 247),
                  borderRadius: BorderRadius.circular(10)),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _found = false;
                    _foundExact = true;
                    _exactWord = _list[i];
                    if (_recentWord.isNotEmpty &&
                        _recentWord.length == 10 &&
                        !_recentWord.contains(_list[i].word)) {
                      _recentWord.remove(_recentWord.last);
                    }
                    _recentWord.add(_list[i].word);
                  });
                  setRecentWordToSession();
                },
                child: Center(
                  child: Text(
                    _list[i].word.capitalize(),
                    style: const TextStyle(
                      color: Color.fromARGB(255, 82, 95, 127),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return children;
  }

  List<Widget> wordMeaningList() {
    List<Widget> children = [];
    String wordTypeBefore = '';
    if (_list[0].meaning.isNotEmpty) {
      for (var i in _exactWord.meaning) {
        Widget childWidget;
        List<Widget> usageWidget = [];
        for (var j in i.usage) {
          usageWidget.add(Text(
            j.replaceAll('+', ':'),
            style: const TextStyle(
              // fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ));
        }
        if (i.wordType != wordTypeBefore) {
          childWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Text(
                  i.wordType.capitalize(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromARGB(255, 152, 163, 199),
                  ),
                ),
              ),
              Text(
                '• ${i.meaning}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text(
                "Ví dụ:",
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ...usageWidget,
            ],
          );
          wordTypeBefore = i.wordType;
        } else {
          childWidget = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                thickness: 1,
                indent: 10,
                endIndent: 100,
              ),
              Text(
                '• ${i.meaning}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Text(
                "Ví dụ:",
                style: TextStyle(
                  // fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              ...usageWidget,
            ],
          );
        }
        children.add(childWidget);
      }
    }
    return children;
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
