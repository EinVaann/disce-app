import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class ChatNav extends StatefulWidget {
  const ChatNav({super.key});

  @override
  State<ChatNav> createState() => _ChatNavState();
}

class _ChatNavState extends State<ChatNav> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("title"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 200,
              width: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.blueAccent,
                // gradient: const LinearGradient(
                //   colors: [
                //     Color.fromARGB(255, 194, 194, 194),
                //     Color.fromARGB(255, 206, 206, 206),
                //   ],
                // ),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromARGB(255, 47, 47, 47).withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SizedBox.expand(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "Bao tri",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Text(
                              "asf0121nsfa0124",
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                // fontWeight: FontWeight.bold,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                              child: Row(
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                                    child: Icon(
                                      Icons.work_history,
                                      color: Color.fromARGB(255, 121, 255, 125),
                                    ),
                                  ),
                                  Text(
                                    "Dang thuc hien",
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 121, 255, 125),
                                      fontSize: 20,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 35,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color.fromARGB(255, 47, 47, 47)
                                      .withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                              color: Color.fromARGB(255, 173, 53, 53),
                            ),
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "chitiet",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            height: 35,
                            width: 67,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  bottomRight: Radius.circular(15),
                                ),
                                color: Color.fromARGB(255, 53, 165, 56),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromARGB(255, 47, 47, 47)
                                        .withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ]),
                            child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "edit",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
