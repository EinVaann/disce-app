import 'dart:convert';

import 'package:disce/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:disce/global.dart' as globals;
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late bool _passwordVisible;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late bool _isLoading;
  late bool _error;
  late String _errorMessage;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _usernameController.text = 'user001';
    _passwordController.text = '123456';
    _isLoading = false;
    _error = false;
    _errorMessage = "None";
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<http.Response> loginRequest() async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'username': _usernameController.text,
      'password': _passwordController.text,
    };
    final response = await http.post(
        Uri.https(globals.apiLinks, "/api/v1/users/login"),
        headers: headers,
        body: jsonEncode(jsonBody));
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = !_isLoading;
        _error = false;
        _passwordVisible = false;
      });
      await SessionManager()
          .set("accessToken", json.decode(response.body)['accessToken']);
      goToHome();
    } else {
      setState(() {
        _isLoading = !_isLoading;
        _error = true;
        _errorMessage = json.decode(response.body)['message'];
      });
    }
    return response;
  }

  void goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeHub(),
      ),
      (r) {
        return false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
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
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Bắt đầu học",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Text(
                      "Đăng nhập tài khoản của bạn",
                      style: TextStyle(
                        fontSize: 25,
                        color: Color.fromARGB(255, 152, 163, 199),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(
                            fontSize: 20,
                          ),
                          floatingLabelStyle: TextStyle(
                            color: Color.fromARGB(255, 104, 107, 255),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 104, 107, 255),
                              width: 2,
                            ),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Color.fromARGB(255, 172, 172, 172),
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(
                            fontSize: 20,
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: Color.fromARGB(255, 104, 107, 255),
                          ),
                          suffixIcon: IconButton(
                            icon: _passwordVisible
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
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
                        obscureText: !_passwordVisible,
                        autocorrect: false,
                        enableSuggestions: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                    ),
                    _error
                        ? Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      height: 150,
                    )
                  ],
                ),
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: !_isLoading
          ? Container(
              height: 75,
              width: 300,
              margin: const EdgeInsets.all(15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 104, 107, 255),
                  ),
                  child: const Text(
                    "Đăng nhập",
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = !_isLoading;
                      });
                      loginRequest();
                    }
                  },
                ),
              ),
            )
          : Container(),
    );
  }
}
