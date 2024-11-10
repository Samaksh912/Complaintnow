import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:complaintnow/services/databaseprovider.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../services/authservice.dart';

class Homepagetile extends StatefulWidget {
  final String postid;
  final String registernumber;
  final String complainttype;
  final String hostelname;
  final String complaint;
  final String uid;
  final String status;
  final Timestamp timestamp; // Add the timestamp
  final VoidCallback? onToggleStatus;

  Homepagetile({
    required this.postid,
    required this.registernumber,
    required this.complainttype,
    required this.hostelname,
    required this.complaint,
    required this.uid,
    required this.status,
    required this.timestamp, // Initialize timestamp
    this.onToggleStatus,
  });

  @override
  State<Homepagetile> createState() => _HomepagetileState();
}

class _HomepagetileState extends State<Homepagetile> {
  final currentUserId = Authservice().getcurrentuid();
  late DatabaseProvider databaseProvider;
  bool isAdmin = false; // To store admin status
  int starCount = 0; // To hold the star count

  @override
  void initState() {
    super.initState();
    databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    _fetchAdminStatus(); // Fetch the admin status when widget is initialized
    _fetchStarCount(); // Fetch the star count when the widget is initialized
  }

  void debugprint(String message) {
    assert(() {
      print(message);
      return true;
    }());
  }

  // Fetch the admin status for the current user
  void _fetchAdminStatus() async {
    try {
      bool adminStatus = await databaseProvider.isCurrentUserAdmin();
      setState(() {
        isAdmin = adminStatus; // Update the isAdmin value
      });
    } catch (e) {
      debugprint("Error fetching admin status: $e");
    }
  }

  // Method to fetch the star count for the post
  void _fetchStarCount() async {
    try {
      starCount = await databaseProvider.getStarCount(widget.postid); // Retrieve star count from the database
      setState(() {}); // Refresh the UI with the new count
    } catch (e) {
      debugprint("Error fetching star count: $e");
    }
  }

  // Likes UI and everything
  void togglelikepost() async {
    try {
      await databaseProvider.togglelike(widget.postid);
      _fetchStarCount(); // Update the star count after toggling the like
    } catch (e) {
      print(e);
    }
  }

  postdelete(BuildContext context) async {
    if (widget.postid.isEmpty) {
      debugprint("Post ID is empty, cannot delete.");
      return;
    }

    if (currentUserId != widget.uid && !isAdmin) { // Compare current user ID with post owner ID
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You cannot delete this post')),
      );
      return; // Prevent deletion if not the owner
    }

    try {
      debugprint("Delete button pressed for post ID: ${widget.postid}");
      await databaseProvider.deletepost(widget.postid);
      debugprint("Post deletion attempted for post ID: ${widget.postid}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complaint deleted')),
      );
    } catch (e) {
      debugprint("Error deleting post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting complaint')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final listeningProvider = Provider.of<DatabaseProvider>(context);
    bool likedbycurrentuser = listeningProvider.ispostlikedbycurrentuser(widget.postid);

    // Parse timestamp to DateTime object and format
    DateTime timestamp = widget.timestamp.toDate();
    String formattedTimestamp = "${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: widget.status == 'Completed' ? Color(0xFF388E3C) : Color(0xFFD32F2F),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Hostel Name: ${widget.hostelname}\nComplaint Type: ${widget.complainttype}\nRegister Number: RA${widget.registernumber}',
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                // Like button with count below it
                GestureDetector(
                  onTap: togglelikepost,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      likedbycurrentuser
                          ? Icon(MdiIcons.star, color: Colors.yellowAccent)
                          : Icon(Icons.star_border, color: Colors.white),
                      const SizedBox(height: 4), // Space between the icon and the text
                      Text(
                        '$starCount', // Display the star count
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    MdiIcons.trashCanOutline,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    postdelete(context); // Call the function directly
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Complaint Text with Strikethrough if Completed
            Text(
              widget.status == 'Completed' ? widget.complaint : widget.complaint,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                decoration: widget.status == 'Completed'
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            // Display the timestamp
            Text(
              "Posted on: $formattedTimestamp",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            // Status and Edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.status,
                  style: TextStyle(
                    color: widget.status == 'Completed' ? Colors.white : Colors.white,
                  ),
                ),
                if (isAdmin) // Only show edit button if user is an admin
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: widget.status == 'Pending' ? Colors.white : Colors.white,
                    ),
                    onPressed: () {
                      widget.onToggleStatus?.call();
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
