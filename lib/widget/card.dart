import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../model/word.dart';
import 'flip_card.dart';

class CardWidget extends StatefulWidget {
  final Word word;
  final bool isFront;
  final Function changeOrder;
  const CardWidget({
    super.key,
    required this.word,
    required this.isFront,
    required this.changeOrder,
  });

  @override
  State<CardWidget> createState() => _CardWidgetState();
}

class _CardWidgetState extends State<CardWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  Offset _position = Offset.zero;
  bool _isDragging = false;
  bool _isChanging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future nextCard() async {
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      _isChanging = true;
    });
    widget.changeOrder();
    _controller.reset();
    setState(() {
      _position = Offset.zero;
    });
    await Future.delayed(const Duration(milliseconds: 10));
    setState(() {
      _isChanging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isFront ? buildFrontCard() : buildCard();
  }

  Widget buildFrontCard() => GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isDragging = true;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _position = Offset(_position.dx + details.delta.dx, 0);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _isDragging = false;
            if (_position.dx > 50 || _position.dx < -50) {
              _position = _position +
                  Offset(MediaQuery.of(context).size.width / 3 * 2, 0) *
                      ((_position.dx < 0) ? -1 : 1);
              nextCard();
            } else {
              _position = Offset.zero;
            }
          });
        },
        child: Builder(builder: (context) {
          final milliseconds = !_isChanging
              ? _isDragging
                  ? 0
                  : 200
              : 0;
          return AnimatedContainer(
            duration: Duration(milliseconds: milliseconds),
            curve: Curves.easeInOut,
            transform: Matrix4.identity()
              ..translate(
                _position.dx,
                _position.dy,
              ),
            child: FlipCard(
              word: widget.word,
              controller: _controller,
            ),
          );
        }),
      );

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
}
