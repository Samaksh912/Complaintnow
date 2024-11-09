import 'package:flutter/material.dart';

class textfield extends StatelessWidget {
  final controller;//used to control what the user is going to type in the box
  final hinttext;
  final obscuretext;

  const textfield(
      {super.key, this.controller, this.hinttext, this.obscuretext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: TextField(
        controller: controller,
        obscureText: obscuretext,//hide characters such as in passwords
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          fillColor: Colors.grey.shade400,
          filled: true,
          hintText: hinttext,
          hintStyle: TextStyle(color: Colors.grey.shade500)
        ),
      ),
    );
  }
}
