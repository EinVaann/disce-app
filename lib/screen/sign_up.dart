import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:disce/global.dart' as globals;
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;
import 'package:loading_indicator/loading_indicator.dart';

import 'home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late bool _passwordVisible;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmController;
  late TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  late bool _isLoading;
  late bool _error;
  late String _errorMessage;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
    _emailController = TextEditingController();
    _isLoading = false;
    _error = false;
    _errorMessage = "None";
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<http.Response> signupRequest() async {
    Map<String, String> headers = {
      "Content-type": "application/json; charset=UTF-8"
    };
    Map<String, String> jsonBody = {
      'username': _usernameController.text,
      'password': _passwordController.text,
      'email': _emailController.text,
    };
    debugPrint(globals.apiLinks);
    final response = await http.post(
        Uri.https(globals.apiLinks, "/api/v1/users/register"),
        headers: headers,
        body: jsonEncode(jsonBody));
    debugPrint(response.statusCode.toString());
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
    debugPrint(response.body);
    return response;
  }

  void goToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeHub(),
      ),
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
            : SingleChildScrollView(
                reverse: true,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Tạo tài khoản",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        "Nhập các thông tin dưới",
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
                            floatingLabelStyle: const TextStyle(
                              color: Color.fromARGB(255, 104, 107, 255),
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
                            if (value.length < 6) {
                              return 'Password much be at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: _confirmController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
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
                            if (value != _passwordController.text) {
                              return "Two passwords isn't the same";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
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
                            if (!RegExp(
                                    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                .hasMatch(value)) {
                              return 'Email format incorrect';
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
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
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
              "Sign up",
              style: TextStyle(
                fontSize: 30,
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Processing Data')),
                // );
                setState(() {
                  _isLoading = !_isLoading;
                });
                signupRequest();
              }
            },
          ),
        ),
      ),
    );
  }
}
