import 'package:flutter/material.dart';

class Squaretile extends StatelessWidget {

  Function()? onTap;

  final String imagepath;
  Squaretile({super.key, required this.imagepath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(border: Border.all(color: Colors.white54),
          borderRadius: BorderRadius.circular(30),
          color: Colors.grey.shade400
        ),
        child: Image.asset(imagepath,height: 40,),
      
      
      
      
      
      ),
    );
  }
}
