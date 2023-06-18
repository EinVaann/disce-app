import 'package:disce/screen/login.dart';
import 'package:disce/screen/sign_up.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Đã có tài khoản?',
              style: TextStyle(
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                debugPrint("to Login");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 104, 107, 255),
                ),
                minimumSize: MaterialStateProperty.all(
                  const Size(300, 20),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Đăng nhập",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 70),
            const Divider(
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            const SizedBox(height: 70),
            const Text(
              'Bắt đầu từ hôm nay',
              style: TextStyle(
                fontSize: 40,
              ),
            ),
            const SizedBox(height: 50),
            OutlinedButton(
              onPressed: () {
                debugPrint("to signup");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  width: 2,
                  color: Color.fromARGB(255, 104, 107, 255),
                ),
                foregroundColor: const Color.fromARGB(255, 104, 107, 255),
                minimumSize: const Size(300, 20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  "Đăng Ký",
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
