import 'package:complaintnow/pages/settingspage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:complaintnow/services/authservice.dart';

import '../pages/statuspage.dart';
class drawerwidget extends StatelessWidget {
  const drawerwidget({super.key});
  // Sign out user method
  Future<void> signuserout() async {
    // Sign out with firebase
    await FirebaseAuth.instance.signOut();
    // Sign out with google
    // Create an instance of GoogleSignIn
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }



  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Color(0xFF388E3C),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(children: [
            //logo
            DrawerHeader(child: Center(child: Icon(Icons.account_circle_outlined,
              color: Color(0xFFFFFFFF)
              ,
              size: 45,
            ),)),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: ListTile(

                title: const Text("HOME",
                  style: TextStyle(color: Color(0xFFFFFFFF)),
                  
                    
                ),
                leading: const Icon(Icons.home_rounded,color: Color(0xFFFFFFFF),),
                onTap: (){
                  //pop the drawer
                  Navigator.pop(context);
                },

              ),
            ),
            Padding(padding: EdgeInsets.only(left: 20),
                child: ListTile(
                  title: Text("MY COMPLAINTS",
                    style: TextStyle(color: Color(0xFFFFFFFF)),),
                  leading: Icon(Icons.access_time,color:Color(0xFFFFFFFF),),
                  onTap: (){
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  StatusPage(uid: '',))
                    );
                  },
                )
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: ListTile(
                title: const Text("SETTINGS",
                  style: TextStyle(color: Color(0xFFFFFFFF)),),
                leading: const Icon(Icons.settings_outlined,color: Color(0xFFFFFFFF),),
                onTap: (){
                  Navigator.pop(context);
                  //navigate to seetings aswell
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Settingspage())
                  );
                },

              ),
            ),

            
          ],),
          Padding(
            padding: const EdgeInsets.only(left: 20.0,bottom: 30),
            child: ListTile(
              title: const Text("LOGOUT",style: TextStyle(color: Colors.white),),
              leading: const Icon(Icons.logout_outlined,color: Colors.white,),
              onTap: signuserout,

            ),
          )
        ],
      ),
    );
    //home tile
  }
}
