import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class Authservice {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();  // Explicit instance for better management

  void debugprint(String message) {
    assert(() {
      print(message);
      return true;
    }());
  }

  // Get current user UID
  String getcurrentuid() => _auth.currentUser!.uid;

  // Google Sign-In method with email validation
  Future<User?> googlesignin(BuildContext context) async {
    try {
      // First, ensure any previous Google session is cleared
      await _googleSignIn.signOut();  // Clears cached sign-in session

      // Begin the interactive sign-in process
      final GoogleSignInAccount? guser = await _googleSignIn.signIn();

      if (guser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain auth details from the request
      final GoogleSignInAuthentication gauth = await guser.authentication;

      // Creating credentials
      final credential = GoogleAuthProvider.credential(
        accessToken: gauth.accessToken,
        idToken: gauth.idToken,
      );

      // Sign in with Firebase using the credentials
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null && user.email != null && user.email!.endsWith('@srmist.edu.in')) {
        // Proceed if email domain matches the college domain
        return user;
      } else {
        // Sign out if the email domain does not match
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please use your college email address to sign in.')),
        );
        return null; // Return null if email domain is invalid
      }
    } catch (e) {
      debugprint("Google Sign-In Error: $e");
      return null;
    }
  }

  // Sign out method
  Future<void> signOut() async {
    try {
      // Ensure to clear both Firebase and Google Sign-In sessions
      await _googleSignIn.signOut();  // Explicitly sign out from GoogleSignIn
      await _auth.signOut();          // Sign out from Firebase
      debugprint("User signed out.");
    } catch (e) {
      debugprint("Error during sign out: $e");
    }
  }

  // Change password method
  Future<void> changePassword(
      BuildContext context, String currentPassword, String newPassword) async {
    try {
      // Get current user
      User? user = _auth.currentUser;

      if (user == null) {
        // Handle case if there is no current user logged in
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user is currently logged in.'))
    );
    return;
    }

    // Reauthenticate the user
    AuthCredential credential = EmailAuthProvider.credential(
    email: user.email!,
    password: currentPassword,
    );

    // Reauthenticate with the provided credentials
    await user.reauthenticateWithCredential(credential);

    // Check for password strength (add your own validation if necessary)
    if (newPassword.length < 6) {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Password should be at least 6 characters long.')));
    return;
    }

    // Update the password
    await user.updatePassword(newPassword);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Password changed successfully.')));
    } on FirebaseAuthException catch (e) {
    // Handle specific Firebase errors
    if (e.code == 'wrong-password') {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Incorrect current password.')));
    } else if (e.code == 'weak-password') {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('New password is too weak.')));
    } else {
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('An error occurred: ${e.message}')));
    }
    } catch (e) {
    debugprint("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('An unexpected error occurred.')));
    }
  }
}
