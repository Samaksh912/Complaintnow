import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final bool isadmin;

  UserProfile({
    required this.name,
    required this.email,
    required this.uid,
    this.isadmin = false,

  });

  // Convert Firestore document to UserProfile (fetching from Firestore to the app)
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    return UserProfile(

      name: doc['name'],        // Match the Firestore field name
      email: doc['email'],  // Match the Firestore field name
      uid: doc['uid'],
      isadmin:  doc['isadmin'] ?? false,

    );
  }

  // Convert UserProfile to Map (sending app data to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'isadmin': isadmin,
};
  }
}
