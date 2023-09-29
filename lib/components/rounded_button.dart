// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_typing_uninitialized_variables

//import 'package:flash_chat/screens/login_screen.dart';
//import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
//import 'package:animated_text_kit/animated_text_kit.dart';

class roundedButton extends StatelessWidget {
  const roundedButton(
      {super.key,
      required this.color,
      required this.text,
      required this.onpressed});
  final Color color;
  final String text;
  final void Function()? onpressed; //final to void Function()?

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onpressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            text,
          ),
        ),
      ),
    );
  }
}
