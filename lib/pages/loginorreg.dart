import 'package:complaintnow/pages/loginpage.dart';
import 'package:complaintnow/pages/registerpage.dart';
import 'package:flutter/material.dart';

class Loginorreg extends StatefulWidget {
  const Loginorreg({super.key});

  @override
  State<Loginorreg> createState() => _LoginorregState();
}

class _LoginorregState extends State<Loginorreg> {
  //bool to initially show login page at the beginning
  bool showloginpage = true;

  //toggle between the login and reg page
  void togglepage(){
    setState(() {
      showloginpage = !showloginpage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showloginpage) {
      return loginpage(
        onTap: togglepage,
      );
    }
    else{
      return RegisterPage(
        onTap: togglepage,
      );
    }
  }
}
