import 'dart:convert';

import 'package:disce/screen/landing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:disce/global.dart' as globals;
import 'package:http/http.dart' as http;

class AccountNav extends StatefulWidget {
  const AccountNav({super.key});

  @override
  State<AccountNav> createState() => _AccountNavState();
}

class _AccountNavState extends State<AccountNav> {
  late dynamic date = {};
  bool _isLoading = false;
  late List<DateTime> _highLightDate = [];
  late List<dynamic> _testResults = [];
  late TextEditingController _passController;
  late TextEditingController _confirmPassController;
  late TextEditingController _newPassController;
  Future<void> logOut() async {
    await SessionManager().set('accessToken', '');
    goToLanding();
  }

  void goToLanding() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LandingPage(),
      ),
      (r) {
        return false;
      },
    );
  }

  Future<http.Response> getProgress() async {
    String token = await SessionManager().get('accessToken');
    Map<String, String> queryParam = {
      'token': token,
    };
    final response = await http.get(
      Uri.https(globals.apiLinks, "/api/v1/quiz/progress", queryParam),
    );
    if (response.statusCode == 200) {
      if (mounted) {
        var temp = List<dynamic>.from(json.decode(response.body).map((x) => {
              'id': x['_id'],
              'date': DateTime.parse(x['date']),
              'result': x['quizResult']
            }));
        setState(() {
          _testResults = temp;
          for (var i in temp) {
            if (!_highLightDate.contains(i['date'])) {
              _highLightDate.add(i['date']);
            }
          }
        });
      }
    }
    return response;
  }

  Future<http.Response> sendChangePass() async {
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
      "oldPass": _passController.text,
      "newPass": _newPassController.text,
    };
    final response = await http.put(
        Uri.https(
            globals.apiLinks, "/api/v1/users/change-password", queryParam),
        headers: headers,
        body: jsonEncode(jsonBody));
    setState(() {
      _isLoading = false;
      _passController.text = '';
      _confirmPassController.text = '';
      _newPassController.text = '';
    });
    if (response.statusCode == 200) {
      if (mounted) {
        showSnackBar("Changed Password");
      }
    } else {
      showSnackBar("Error");
    }
    return response;
  }

  void showProgress() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text(
          'Your Progress',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              children: [
                for (var i in _testResults)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      //
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                                child: Icon(
                                  Icons.text_snippet,
                                  size: 40,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              SizedBox(
                                width: 150,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      i['date'].toString().substring(0, 10),
                                      style: const TextStyle(
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'Linotte',
                                        decoration: TextDecoration.none,
                                        fontSize: 22,
                                      ),
                                    ),
                                    Text(
                                      'Result: ${i['result']}/10',
                                      overflow: TextOverflow.ellipsis,
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showChangePass() {
    showDialog(
        context: context,
        builder: (context) {
          bool passwordVisible = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Change Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                height: 300,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _passController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            fontSize: 20,
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: Color.fromARGB(255, 104, 107, 255),
                          ),
                          suffixIcon: IconButton(
                            icon: passwordVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(
                                  () => passwordVisible = !passwordVisible);
                            },
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 104, 107, 255),
                              width: 2,
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 172, 172, 172),
                              width: 2,
                            ),
                          ),
                        ),
                        obscureText: !passwordVisible,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                      TextFormField(
                        controller: _confirmPassController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: const TextStyle(
                            fontSize: 20,
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: Color.fromARGB(255, 104, 107, 255),
                          ),
                          suffixIcon: IconButton(
                            icon: passwordVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(
                                  () => passwordVisible = !passwordVisible);
                            },
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 104, 107, 255),
                              width: 2,
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 172, 172, 172),
                              width: 2,
                            ),
                          ),
                        ),
                        obscureText: !passwordVisible,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                      TextFormField(
                        controller: _newPassController,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle: const TextStyle(
                            fontSize: 20,
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: Color.fromARGB(255, 104, 107, 255),
                          ),
                          suffixIcon: IconButton(
                            icon: passwordVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(
                                  () => passwordVisible = !passwordVisible);
                            },
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 104, 107, 255),
                              width: 2,
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 172, 172, 172),
                              width: 2,
                            ),
                          ),
                        ),
                        obscureText: !passwordVisible,
                        autocorrect: false,
                        enableSuggestions: false,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _passController.text = '';
                      _confirmPassController.text = '';
                      _newPassController.text = '';
                    });
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
                    if (_passController.text == _confirmPassController.text) {
                      Navigator.of(context).pop();
                      sendChangePass();
                    } else {
                      showSnackBar("Confirm password does not match");
                    }
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          });
        });
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
    super.initState();
    setState(() {
      date['year'] = DateTime.now().year;
      date['month'] = DateTime.now().month;
      date['maxDate'] = DateTime(date['year'], date['month'], 0).day;
      getProgress();
      _passController = TextEditingController();
      _confirmPassController = TextEditingController();
      _newPassController = TextEditingController();
    });
  }

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    _newPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
          : SizedBox.expand(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Progress",
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(
                      width: 300,
                      height: 400,
                      child: TableCalendar(
                        firstDay:
                            DateTime.utc(date['year'], date['month'] - 1, 1),
                        lastDay: DateTime.utc(
                            date['year'], date['month'], date['maxDate']),
                        focusedDay: DateTime.now(),
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month'
                        },
                        daysOfWeekVisible: false,
                        headerStyle: const HeaderStyle(
                          leftChevronVisible: false,
                          rightChevronVisible: false,
                          headerPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          formatButtonVisible: false,
                        ),
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            for (DateTime d in _highLightDate) {
                              if (day.day == d.day &&
                                  day.month == d.month &&
                                  day.year == d.year) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.lightGreen,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${day.day}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 2,
                    ),
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
                            showProgress();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "See Progress",
                                      style: TextStyle(
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
                    ),
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
                            showChangePass();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Change Password",
                                      style: TextStyle(
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 255, 69, 69),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: TextButton(
                          onPressed: () {
                            logOut();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Log Out",
                                      style: TextStyle(
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
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
