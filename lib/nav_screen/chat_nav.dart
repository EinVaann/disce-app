import 'dart:async';
import 'dart:convert';

import 'package:disce/screen/chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:disce/global.dart' as globals;
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

class ChatNav extends StatefulWidget {
  const ChatNav({super.key});

  @override
  State<ChatNav> createState() => _ChatNavState();
}

class _ChatNavState extends State<ChatNav> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late List<dynamic> _friendList = [];
  late List<dynamic> _findList = [];
  late String _userId = '';
  late int _selectedIndex = 0;
  late IO.Socket _socket;
  bool _isLoading = false;

  void connectSocket() {
    // _socket = IO.io('http://192.168.1.133:3000',
    //     OptionBuilder().setTransports(['websocket']).build());
    _socket = IO.io('https://${globals.apiLinks}',
        OptionBuilder().setTransports(['websocket']).build());
    _socket.connect();
  }

  Future<http.Response> getFriends() async {
    setState(() {
      _isLoading = true;
    });
    String token = await SessionManager().get('accessToken');
    Map<String, String> queryParam = {'token': token};
    final response = await http.get(
      Uri.https(globals.apiLinks, "/api/v1/users/friends", queryParam),
    );
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _userId = json.decode(response.body)['userInfo']['userId'];
          _friendList = List<dynamic>.from(json
              .decode(response.body)['userInfo']['friendList']
              .map((x) => {'id': x['_id'], 'name': x['username']}));
        });
      }
    }
    return response;
  }

  Future<http.Response> findUser(String username) async {
    setState(() {
      _isLoading = true;
    });
    String token = await SessionManager().get('accessToken');
    Map<String, String> queryParam = {
      'token': token,
      'search_username': username
    };
    final response = await http.get(
      Uri.https(globals.apiLinks, "/api/v1/users/get-users", queryParam),
    );
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _findList = List<dynamic>.from(json
              .decode(response.body)
              .map((x) => {'id': x['_id'], 'name': x['username']}));
        });
      }
    }
    for (var i in _findList) {
      debugPrint('notfriends$i');
    }
    return response;
  }

  void switchTab() {
    setState(() {
      _selectedIndex = _selectedIndex == 1 ? 0 : 1;
      if (_selectedIndex == 1) onGoBack();
    });
  }

  void onGoBack() {
    if (mounted) {
      getFriends();
      _searchController.text = '';
      setState(() {
        _findList = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getFriends();
    connectSocket();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: [
            tabSwitch(_selectedIndex, switchTab),
            _isLoading
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
                : friendList(
                    _friendList, _selectedIndex == 0, _userId, _socket),
            unknowUser(_searchController, _selectedIndex == 1, findUser,
                _findList, _socket, _userId, onGoBack),
          ],
        ),
      ),
    );
  }
}

Widget tabSwitch(int selectedIndex, Function switchFunction) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      tabSwitcher(selectedIndex == 0, 'Friends', switchFunction),
      tabSwitcher(selectedIndex == 1, 'Find', switchFunction)
    ],
  );
}

Widget tabSwitcher(bool isSelect, String text, Function switchFunction) {
  return Container(
    width: 100,
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: isSelect ? Colors.black : Colors.transparent,
          width: 2,
        ),
      ),
    ),
    child: TextButton(
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        overlayColor:
            MaterialStateColor.resolveWith((states) => Colors.transparent),
      ),
      onPressed: () {
        switchFunction();
      },
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget unknowUser(
    TextEditingController searchController,
    bool isSelect,
    Function findUser,
    List<dynamic> findList,
    IO.Socket socket,
    String userId,
    Function onGoBack) {
  return Builder(builder: (context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.identity()
        ..translate(
          isSelect ? 0.0 : MediaQuery.of(context).size.width,
          0.0,
        ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 60, 10, 5),
            child: SizedBox(
              child: TextFormField(
                enabled: isSelect,
                controller: searchController,
                onFieldSubmitted: (text) {
                  debugPrint(text);
                  findUser(text);
                },
                decoration: InputDecoration(
                  hintText: "Tìm kiếm người dùng",
                  contentPadding: const EdgeInsets.all(8.0),
                  prefixIcon: SizedBox(
                    height: 40,
                    child: InkWell(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
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
          findList.isNotEmpty
              ? Column(
                  children: [
                    for (var i in findList)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 236, 236, 236),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20))),
                          child: TextButton(
                            onPressed: () {
                              socket.emit(
                                "make_friend",
                                {
                                  'userId': userId,
                                  'otherUserId': i['id'].toString(),
                                },
                              );
                              onGoBack();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatRoomScreen(
                                            userId: userId,
                                            otherUserId: i['id'].toString(),
                                            socket: socket,
                                            otherUsername: i['name'].toString(),
                                          )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Icon(Icons.chat_bubble,
                                          color: Colors.black),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        i['name'],
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                )
              : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Emply list of users"),
                )
        ],
      ),
    );
  });
}

Widget friendList(
    List<dynamic> list, bool isSelect, String userId, IO.Socket socket) {
  return Builder(builder: (context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()
          ..translate(
            isSelect ? 0.0 : -MediaQuery.of(context).size.width,
            0.0,
          ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 60, 10, 10),
          child: SingleChildScrollView(
            child: list.isNotEmpty
                ? Column(
                    children: [
                      for (var i in list)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 236, 236, 236),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatRoomScreen(
                                              userId: userId,
                                              otherUserId: i['id'].toString(),
                                              socket: socket,
                                              otherUsername:
                                                  i['name'].toString(),
                                            )));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        const Icon(Icons.chat_bubble,
                                            color: Colors.black),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          i['name'],
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Colors.black,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                    ],
                  )
                : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Emply list of users"),
                  ),
          ),
        ));
  });
}
