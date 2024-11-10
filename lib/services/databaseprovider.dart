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
  final db = FirebaseFirestore.instance;
  final _auth = Authservice();
  final auth = FirebaseAuth.instance;

  final currentUserId = Authservice().getcurrentuid();

  List<Post> _allposts = [];
  List<Post> get allposts => _allposts;

  List<Post> _originalPosts = []; // To hold the original list of posts

  // Get user profile given uid
  Future<UserProfile?> userprofile(String uid) => _db.getuserfromfirebase(uid);

  // Sort posts based on different criteria
  void sortPosts(String sortOption) {
    // Reset to the original unfiltered list if filtering is applied
    if (sortOption != 'Pending Only' && sortOption != 'Completed Only') {
      _allposts = List.from(_originalPosts); // Reset to unfiltered posts
    }

    switch (sortOption) {
      case 'Most Recent':
        _allposts.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort by timestamp
        break;
      case 'Most Rated':
        _allposts.sort((a, b) => b.likecount.compareTo(a.likecount)); // Sort by like count (rating)
        break;
      case 'Pending Only':
        _allposts = _originalPosts.where((post) => post.status == 'Pending').toList();
        break;
      case 'Completed Only':
        _allposts = _originalPosts.where((post) => post.status == 'Completed').toList();
        break;
      default:
        break;
    }
    notifyListeners(); // Notify listeners to update UI after sorting/filtering
  }

  // Post a complaint
  Future<void> postcomplaint(String complaint, String complainttype, String hostelname, String registernumber) async {
    await _db.postmessageinfirebase(complaint, complainttype, hostelname, registernumber);
    await loadallposts();
  }

  // Get all posts
  Future<void> loadallposts() async {
    final allposts = await _db.getallpostsfromfirebase();
    _originalPosts = List.from(allposts); // Store the original list
    _allposts = allposts;
    initializelikemap();
    notifyListeners();
  }

  // Get the number of people who liked a specific post
  Future<int> getStarCount(String postid) async {
    try {
      DocumentSnapshot postSnapshot = await db.collection("Posts").doc(postid).get();
      if (postSnapshot.exists) {
        return postSnapshot['likecount'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      debugprint("Error fetching star count: $e");
      return 0;
    }
  }

  // Return user-specific complaints
  List<Post> filteruserposts(String uid) {
    return _allposts.where((post) => post.uid == uid).toList();
  }

  void debugprint(String message) {
    assert(() {
      print(message);
      return true;
    }());
  }

  // Method to delete the post
  Future<void> deletepost(String postid) async {
    await _db.deletepostfromfirebase(postid);
    await loadallposts();
  }

  // LIKES
  Map<String, int> _likecounts = {};

  // Local list to track posts liked by the current user
  List<String> _likedposts = [];

  // Does the current user like the post?
  bool ispostlikedbycurrentuser(String postid) => _likedposts.contains(postid);

  // Get a like count
  int getlikecount(String postid) => _likecounts[postid] ?? 0;

  // Initializing the like map locally
  void initializelikemap() {
    final currentuseruid = _auth.getcurrentuid();

    for (var post in _allposts) {
      _likecounts[post.id] = post.likecount;
      if (post.likedby.contains(currentuseruid)) {
        _likedposts.add(post.id);
      }
    }
  }

  // Toggling the like method
  Future<void> togglelike(String postid) async {
    final likedpostsoriginal = _likedposts;
    final likecountsoriginal = _likecounts;

    if (_likedposts.contains(postid)) {
      _likedposts.remove(postid);
      _likecounts[postid] = (_likecounts[postid] ?? 0) - 1;
    } else {
      _likedposts.add(postid);
      _likecounts[postid] = (_likecounts[postid] ?? 0) + 1;
    }

    notifyListeners();

    try {
      await _db.togglelikeinfirebase(postid);
    } catch (e) {
      _likedposts = likedpostsoriginal;
      _likecounts = likecountsoriginal;
      notifyListeners();
    }
  }

  // Check if the current user is an admin
  Future<bool> isCurrentUserAdmin() async {
    try {
      String uid = auth.currentUser!.uid;
      DocumentSnapshot userDoc = await db.collection("Users").doc(uid).get();

      if (userDoc.exists && userDoc['isadmin'] == true) {
        return true;
      }
    } catch (e) {
      debugprint("Error checking admin status: $e");
    }
    return false;
  }

  // Method to add a user as an admin
  Future<void> addAdmin(String uid) async {
    try {
      await db.collection("Users").doc(uid).set({
        'isadmin': true,
      }, SetOptions(merge: true));
      debugprint("User added as admin successfully.");
    } catch (e) {
      debugprint("Error adding user as admin: $e");
    }
  }

  // Update complaint status
  Future<void> updateComplaintStatus(String postId, String status) async {
    try {
      await db.collection("Posts").doc(postId).update({
        'status': status,
      });
    } catch (e) {
      debugprint("Error updating complaint status: $e");
    }
  }
}
