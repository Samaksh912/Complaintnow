import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintnow/services/authservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:complaintnow/components/postmodel.dart';
import 'package:complaintnow/components/usermodel.dart';
import 'package:complaintnow/services/firebaseservice.dart';
import 'package:flutter/foundation.dart';

class DatabaseProvider extends ChangeNotifier {
  final _db = database();
  final db = FirebaseFirestore.instance; // Your Firestore service class
  final _auth = Authservice();
  final auth = FirebaseAuth.instance;

  final currentUserId = Authservice().getcurrentuid();

  List<Post> _allposts = [];
  List<Post> get allposts => _allposts;

  // Get user profile given uid
  Future<UserProfile?> userprofile(String uid) => _db.getuserfromfirebase(uid);

  // Post a complaint
  Future<void> postcomplaint(String complaint, String complainttype, String hostelname, String registernumber) async {
    await _db.postmessageinfirebase(complaint, complainttype, hostelname, registernumber);
    await loadallposts();
  }

  // Get all posts
  Future<void> loadallposts() async {
    final allposts = await _db.getallpostsfromfirebase();
    // Update local data
    _allposts = allposts;
    // Initialization of local like data
    initializelikemap();

    notifyListeners();
  }

  // Get the number of people who liked a specific post
  Future<int> getStarCount(String postid) async {
    try {
      DocumentSnapshot postSnapshot = await db.collection("Posts").doc(postid).get();
      if (postSnapshot.exists) {
        // Return the like count from the post
        return postSnapshot['likecount'] ?? 0;
      } else {
        return 0; // Return 0 if the post doesn't exist
      }
    } catch (e) {
      print("Error fetching star count: $e");
      return 0; // Return 0 in case of error
    }
  }


  // Return user-specific complaints
  List<Post> filteruserposts(String uid) {
    return _allposts.where((post) => post.uid == uid).toList();
  }

  // Method to delete the post
  Future<void> deletepost(String postid) async {
    // Delete from firebase
    await _db.deletepostfromfirebase(postid);
    // Reloading the data from firebase
    await loadallposts();
  }

  // LIKES
  Map<String, int> _likecounts = {
    // Like for each post id
  };

  // Local list to track posts liked by the current user
  List<String> _likedposts = [];

  // Does the current user like the post?
  bool ispostlikedbycurrentuser(String postid) => _likedposts.contains(postid);

  // Get a like count
  int getlikecount(String postid) => _likecounts[postid]!;

  // Initializing the like map locally
  void initializelikemap() {
    // Getting the current uid
    final currentuseruid = _auth.getcurrentuid();

    // Getting the like data for each post
    for (var post in _allposts) {
      // Updating the like count map
      _likecounts[post.id] = post.likecount;

      if (post.likedby.contains(currentuseruid)) {
        // Then adding the post id to the list of liked posts
        _likedposts.add(post.id);
      }
    }
  }

  // Toggling the like method
  Future<void> togglelike(String postid) async {
    // This first part updates the local values first so that the UI feels immediate and responsive
    final likedpostsoriginal = _likedposts;
    final likecountsoriginal = _likecounts;

    // Performing the like/unlike function
    if (_likedposts.contains(postid)) {
      _likedposts.remove(postid);
      _likecounts[postid] = (_likecounts[postid] ?? 0) - 1;
    } else {
      _likedposts.add(postid);
      _likecounts[postid] = (_likecounts[postid] ?? 0) + 1;
    }

    // Updating UI locally
    notifyListeners();

    // Attempting to add like data to database
    try {
      await _db.togglelikeinfirebase(postid);
    } catch (e) {
      // Reverting back to initial state if the update fails
      _likedposts = likedpostsoriginal;
      _likecounts = likecountsoriginal;

      // Again update UI
      notifyListeners();
    }
  }

  // Check if the current user is an admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      String uid = auth.currentUser!.uid;
      DocumentSnapshot userDoc = await db.collection("Users").doc(uid).get();

      // Check if user document has the 'isAdmin' field and is set to true
      if (userDoc.exists && userDoc['isadmin'] == true) {
        return true;
      }
    } catch (e) {
      print("Error checking admin status: $e");
    }
    return false;
  }

  // Method to add a user as an admin
  Future<void> addAdmin(String uid) async {
    try {
      await db.collection("Users").doc(uid).set({
        'isadmin': true,
      }, SetOptions(merge: true)); // Merge to avoid overwriting other fields
      print("User added as admin successfully.");
    } catch (e) {
      print("Error adding user as admin: $e");
    }
  }

  // Update complaint status
  Future<void> updateComplaintStatus(String postId, String status) async {
    try {
      await db.collection("Posts").doc(postId).update({
        'status': status,
      });
    } catch (e) {
      print("Error updating complaint status: $e");
    }
  }
}
