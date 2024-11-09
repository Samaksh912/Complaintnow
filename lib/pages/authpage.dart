import 'package:complaintnow/pages/loginorreg.dart';
import 'package:complaintnow/pages/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'homepage.dart';

class Authpage extends StatelessWidget {
  const Authpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              //user is logged in
              if (snapshot.hasData) {
                return Homepage();
              }
              //user is not logged in
              else{
                return Loginorreg();
              }
            }
            )
    );
  }
}
