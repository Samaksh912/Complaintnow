import 'package:complaintnow/components/buttons.dart';
import 'package:complaintnow/components/textfield.dart';
import 'package:complaintnow/services/authservice.dart';
import 'package:complaintnow/services/firebaseservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/squaretile.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;

  RegisterPage({super.key, this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _db = database();

  // Text editing controllers
  final usernamecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final confirmpasswordcontroller = TextEditingController();

  void debugprint(String message) {
    assert(() {
      print(message);
      return true;
    }());
  }

  // Sign user up method
  void signuserup() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      // Check if the email ends with the college domain
      if (!usernamecontroller.text.endsWith('@srmist.edu.in')) {
        Navigator.pop(context); // Close loading dialog
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text('Invalid Email'),
              content: Text('Please use your college email address to register.'),
            );
          },
        );
        return; // Stop further registration if the email is invalid
      }

      // Check if passwords match
      if (passwordcontroller.text == confirmpasswordcontroller.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usernamecontroller.text,
          password: passwordcontroller.text,
        );
      } else {
        Navigator.pop(context); // Close loading dialog
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              title: Text("Passwords Don't Match"),
              content: Text('Please make sure both passwords are the same.'),
            );
          },
        );
        return; // Stop further registration if passwords don't match
      }

      await _db.saveuserinfoinfirebase(
        name: passwordcontroller.text,
        email: usernamecontroller.text,
      );

      Navigator.pop(context); // Close loading spinner after success
    } on FirebaseAuthException catch (e) {
      debugprint(e.code);
      Navigator.pop(context); // Close loading spinner before showing error

      // Show appropriate error dialog
      if (e.code == 'invalid-email') {
        wrongemailmessage();
      } else if (e.code == 'wrong-password') {
        wrongpasswordmessage();
      } else {
        genericerrormessage();
      }
    }
  }

  // Function for incorrect email message
  void wrongemailmessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Incorrect Email'),
          content: Text('The email address is badly formatted.'),
        );
      },
    );
  }

  // Function for incorrect password message
  void wrongpasswordmessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Incorrect Password'),
          content: Text('The password you entered is incorrect.'),
        );
      },
    );
  }

  // Function for generic error message
  void genericerrormessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('Error'),
          content: Text('An unexpected error occurred. Please try again later.'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white70,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Icon(Icons.account_circle_outlined, size: 100),
                const SizedBox(height: 30),
                const Text(
                  'Hello!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 15),
                textfield(
                  controller: usernamecontroller,
                  hinttext: 'Email',
                  obscuretext: false,
                ),
                const SizedBox(height: 15),
                textfield(
                  controller: passwordcontroller,
                  hinttext: 'Password',
                  obscuretext: true,
                ),
                const SizedBox(height: 15),
                textfield(
                  controller: confirmpasswordcontroller,
                  hinttext: 'Confirm Password',
                  obscuretext: true,
                ),
                const SizedBox(height: 15),
                Text('Forgot Password?'),
                const SizedBox(height: 15),
                MyButton(
                  text: "Sign Up",
                  onTap: signuserup,
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          "Or continue with",
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Squaretile(
                      imagepath: 'lib/assets/img_6.png',
                      onTap: () => Authservice().googlesignin(context),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Login now!",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
