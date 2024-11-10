import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Settingspage extends StatelessWidget {
  final currentuser = FirebaseAuth.instance.currentUser!;

  Settingspage({super.key});
void debugprint(String message){
  assert((){
    print(message);
    return true;
  }());
}
  // Function to launch URLs for social media or support
  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugprint("Error: Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.person, size: 100),
          const SizedBox(height: 15),
          // Display user's email
          Center(
            child: Text(
              currentuser.email!,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 20),

          // Change password section
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
            onTap: () {
              // Add password change logic (Firebase)
              _showChangePasswordDialog(context);
            },
          ),

          // FAQ section
          ListTile(
            leading: Icon(Icons.help),
            title: Text('FAQ'),
            onTap: () {
              _showFAQDialog(context);
            },
          ),

          // Contact Info section
          ListTile(
            leading: Icon(Icons.contact_mail),
            title: Text('Contact Info'),
            onTap: () {
              _showContactInfoDialog(context);
            },
          ),

          // Social Media Links section with smaller tile and icons
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: ListTile(
              contentPadding: EdgeInsets.zero, // remove default padding
              title: Row(
                children: [
                  // Share Icon
                  Icon(Icons.share),
                  const SizedBox(width: 10), // Space between icon and text
                  // "Follow Us" Text
                  Text(
                    'Follow Us',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    // Facebook Icon
                    IconButton(
                      icon: Image.asset(
                        'lib/assets/facebook.webp', // You can replace this with an image asset
                        height: 50,
                        width: 50,
                      ),
                      onPressed: () {
                        _launchURL('https://www.facebook.com/SRMUniversityOfficial/');
                      },
                    ),
                    // Twitter Icon
                    IconButton(
                      icon: Image.asset(
                        'lib/assets/srm.webp', // You can replace this with an image asset
                        height: 50,
                        width: 50,
                      ),
                      onPressed: () {
                        _launchURL('https://www.srmist.edu.in');
                      },
                    ),
                    // Instagram Icon
                    IconButton(
                      icon: Image.asset(
                        'lib/assets/instagram.png', // You can replace this with an image asset
                        height: 50,
                        width: 50,
                      ),
                      onPressed: () {
                        _launchURL('https://www.instagram.com/srmuniversityofficial');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show FAQ Dialog with detailed questions and answers
  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('FAQ'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ExpansionTile(
                  title: Text("1. How to use the app?"),
                  children: <Widget>[
                    Text("The app allows you to register complaints, view status updates, and engage with others through feedback. Simply log in, post your complaint, and interact with others."),
                  ],
                ),
                ExpansionTile(
                  title: Text("2. How to post a complaint?"),
                  children: <Widget>[
                    Text("To post a complaint, click the '+' button on the homepage at the bottom left of the screen, fill in the necessary details such as the register number(necessary to post a complaint), complaint, type, and hostel, and submit."),
                  ],
                ),
                ExpansionTile(
                  title: Text("3. How to view complaints?"),
                  children: <Widget>[
                    Text("To view complaints, navigate to the homepage where all complaints are listed. You can also filter complaints based on their status or your preferences, you can also go to mycomplaints to view complaints posted by you."),
                  ],
                ),
                ExpansionTile(
                  title: Text("4. How to contact support?"),
                  children: <Widget>[
                    Text("You can contact support via the Contact Info section in the settings page or reach out through email at support@srmist.com."),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Show Change Password dialog
  void _showChangePasswordDialog(BuildContext context) {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Current Password'),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'New Password'),
              ),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirm New Password'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                String currentPassword = currentPasswordController.text;
                String newPassword = newPasswordController.text;
                String confirmPassword = confirmPasswordController.text;

                if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please fill all the fields.'),
                  ));
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('New password and confirm password do not match.'),
                  ));
                  return;
                }

                try {
                  User user = FirebaseAuth.instance.currentUser!;
                  // Reauthenticate user
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPassword,
                  );
                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPassword);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Password changed successfully!'),
                  ));
                  // Clear text fields after success
                  currentPasswordController.clear();
                  newPasswordController.clear();
                  confirmPasswordController.clear();
                  Navigator.pop(context);
                } catch (e) {
                  debugprint("Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to change password. Please try again.'),
                  ));
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Show Contact Info Dialog
  void _showContactInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contact Info'),
          content: Text("For support, please contact:\nEmail: support@srmist.com\nPhone: +1234567890"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
