import 'package:complaintnow/components/buttons.dart';
import 'package:complaintnow/components/textfield.dart';
import 'package:complaintnow/services/authservice.dart';
import 'package:complaintnow/services/firebaseservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/squaretile.dart';

class registerpage extends StatefulWidget {

  final Function()? onTap;

  registerpage({super.key, this.onTap});

  @override
  State<registerpage> createState() => _registerpageState();
}

class _registerpageState extends State<registerpage> {

  final _db = database();

  //text editing controllers
  final usernamecontroller = TextEditingController();

  final passwordcontroller = TextEditingController();
  final confirmpasswordcontroller = TextEditingController();

  //loading circle

// sign user in method
  void signuserup() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevent dismissing the dialog by tapping outside
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      if (passwordcontroller.text == confirmpasswordcontroller.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: usernamecontroller.text,
          password: passwordcontroller.text,


        );
      }

      else {
        //show error message for unmatching opasswords

        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Text('passwords don\'t match'),
                content: Text('The password is badly formatted.'),
              );
            });
        Navigator.pop(context);
      }
      await _db.saveuserinfoinfirebase(name: passwordcontroller.text, email: usernamecontroller.text);

      // Close the loading spinner after successful sign-in
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      // Close the loading spinner before showing an error
      Navigator.pop(context);

      // Show appropriate error dialog based on the error code
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
          content: Text(
              'An unexpected error occurred. Please try again later.'),
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
                const SizedBox(height: 30,),
                //logo
                const Icon(Icons.account_circle_outlined, size: 100,),
                const SizedBox(height: 30,),
                //welcome text
                const Text('Hello!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 15,),
                //username textfield
                textfield(
                  controller: usernamecontroller,
                  hinttext: 'Email ',
                  obscuretext: false,

                ),

                const SizedBox(height: 15,),

                //password textfiled
                textfield(
                  controller: passwordcontroller,
                  hinttext: ' Password',
                  obscuretext: true,
                ),
                //confirmpassword
                const SizedBox(height: 15,),
                textfield(
                  controller: confirmpasswordcontroller,
                  hinttext: 'Confirm Password',
                  obscuretext: true,
                ),
                //forgot password
                const SizedBox(height: 15,),
                Text('Forgot Password?'),

                const SizedBox(height: 15,),
                //sign button
                MyButton(
                  text: "Sign Up",
                  onTap: signuserup,
                ),

                const SizedBox(height: 15,),
                //or continue with part
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(child:
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade400,
                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text("Or continue with", style: TextStyle(
                            color: Colors.grey.shade700),),
                      ),

                      Expanded(child:
                      Divider(
                        thickness: 1,
                        color: Colors.grey.shade400,
                      ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                // google and apple sign buttons here
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //google button
                    Squaretile(imagepath: 'lib/assets/img_6.png',
                      onTap: () => Authservice().googlesignin(context),
                    ),


                  ],
                ),

                const SizedBox(height: 20,),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account? ",
                      style: TextStyle(color: Colors.grey.shade700),

                    ),

                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text("Login now!",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )


              ],
            ),
          ),
        ),
      ),
    );
  }
}
