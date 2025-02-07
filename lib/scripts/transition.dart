import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedSnackbar extends StatefulWidget {
  final String message;

  AnimatedSnackbar({required this.message});

  @override
  _AnimatedSnackbarState createState() => _AnimatedSnackbarState();
}

class _AnimatedSnackbarState extends State<AnimatedSnackbar> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Start fading in
    Future.delayed(Duration(milliseconds: 50), () {
      setState(() {
        _opacity = 1.0;
      });
    });
    // Start fading out after some time
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _opacity = 0.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: Duration(milliseconds: 500),
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.red,
        ),
        child: Text(
          widget.message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}