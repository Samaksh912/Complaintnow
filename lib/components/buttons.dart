import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;

 final Function()? onTap;
  const MyButton({super.key, this.onTap, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
            color: Colors.black,
                borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,style: const TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          ),
        ),
      ),
    );
  }
}
