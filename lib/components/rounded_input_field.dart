import 'package:flutter/material.dart';

import '../constant.dart';
import 'text_field_container.dart';


class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;

  const RoundedInputField(
      {Key? key,
      required this.hintText,
      required this.icon,
      required this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      // ignore: prefer_const_constructors
      child: TextField(
        onChanged: onChanged,
        // ignore: prefer_const_constructors
        decoration: InputDecoration(
          icon: Icon(
            icon,
            color: kPrimaryColor,
          ),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
