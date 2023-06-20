import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../model/word.dart';

class FlipCard extends StatefulWidget {
  final Word word;
  final AnimationController controller;
  const FlipCard({
    super.key,
    required this.word,
    required this.controller,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with TickerProviderStateMixin {
  late Animation _animation;
  AnimationStatus _status = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();

    _animation = Tween(begin: 0.0, end: 1.0).animate(widget.controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _status = status;
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_status == AnimationStatus.dismissed) {
          widget.controller.forward();
        } else {
          widget.controller.reverse();
        }
      },
      child: Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(2, 1, 0.0015)
          ..rotateY(3.14 * _animation.value),
        child: _animation.value <= 0.5 ? buildCard() : buildMeaningCard(),
      ),
    );
  }

  Widget buildCard() => Container(
        height: 250,
        width: 250,
        decoration: BoxDecoration(
          // color: Colors.blueAccent,
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 107, 166, 254),
              Color.fromARGB(255, 54, 41, 109),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(1, 2), // changes position of shadow
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.word.word,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
      );
  Widget buildMeaningCard() => Transform(
        alignment: FractionalOffset.center,
        transform: Matrix4.identity()
          ..setEntry(2, 1, 0.0015)
          ..rotateY(3.14),
        child: Container(
          height: 250,
          width: 250,
          decoration: BoxDecoration(
            // color: Colors.blueAccent,
            gradient: const LinearGradient(
              colors: [
                Color.fromARGB(255, 107, 166, 254),
                Color.fromARGB(255, 54, 41, 109),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            border: Border.all(color: Colors.black, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(1, 2), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 49,
                width: 250,
                decoration: const BoxDecoration(
                  // color: Colors.white,
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(255, 107, 166, 254),
                      Color.fromARGB(255, 97, 142, 227),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.word.word.capitalize(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                height: 199,
                width: 250,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.word.meaning[0].wordType.capitalize(),
                        style: const TextStyle(
                          color: Color.fromARGB(255, 152, 163, 199),
                          fontSize: 20,
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '• ${widget.word.meaning[0].meaning.capitalize()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
