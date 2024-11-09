import 'package:complaintnow/components/drawerside.dart';
import 'package:complaintnow/components/homepagetile.dart';
import 'package:complaintnow/components/postmodel.dart';
import 'package:complaintnow/services/databaseprovider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late DatabaseProvider databaseProvider;
  bool isAdmin = false; // Track if current user is admin
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

  void toggleComplaintStatus(String postId, String currentStatus) async {
    String newStatus = currentStatus == "Pending" ? "Completed" : "Pending";
    await databaseProvider.updateComplaintStatus(postId, newStatus);
    await loadallposts(); // Reload posts after status change
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    });
    databaseProvider = Provider.of<DatabaseProvider>(context, listen: false);
    loadAdminStatus(); // Check if user is admin
    loadallposts();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> loadAdminStatus() async {
    isAdmin = await databaseProvider.isCurrentUserAdmin();
    setState(() {}); // Update UI to reflect admin status
  }

  Future<void> loadallposts() async {
    try {
      await databaseProvider.loadallposts();
      print("Posts loaded: ${databaseProvider.allposts.length}");
    } catch (e) {
      print("Error loading posts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    databaseProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      drawer: drawerwidget(),
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF388E3C),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFF4F6F8),
      body: _buildPostList(databaseProvider.allposts),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddComplaintDialog,
        backgroundColor: Color(0xFF388E3C),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPostList(List<Post> posts) {
    return posts.isEmpty
        ? const Center(child: Text("No data available"))
        : ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        // Pass the toggleComplaintStatus function to Homepagetile
        return Homepagetile(
          uid: post.uid,
          postid: post.id,
          hostelname: post.hostelname,
          complainttype: post.complainttype,
          registernumber: post.registernumber,
          complaint: post.Complaint,
          status: post.status,
          onToggleStatus: isAdmin // Only allow admins to toggle status
              ? () => toggleComplaintStatus(post.id, post.status)
              : null, // Disable for non-admins
        );
      },
    );
  }

  void _showAddComplaintDialog() {
    final TextEditingController _registernumbercontroller = TextEditingController();
    final TextEditingController _complainttypecontroller = TextEditingController();
    final TextEditingController _hostelnamecontroller = TextEditingController();
    final TextEditingController _complaintController = TextEditingController();
    bool _isFocused = false;
    bool _isregisternumberempty = false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFFFFFFFF),
          title: const Text(
            "Add Complaint Details",
            style: TextStyle(color: Color(0xFF212121)),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _registernumbercontroller,
                    onTap: () {
                      setState(() => _isFocused = true);
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                    decoration: InputDecoration(
                      prefixText: _isFocused ? 'RA' : null,
                      hintText: _isFocused ? null : 'Enter Register Number',
                      errorText: _isregisternumberempty ? 'Register Number cannot be empty' : null,
                    ),
                  ),
                  TextField(

                    decoration: const InputDecoration(hintText: "Enter Complaint Type"),
                  ),
                  TextField(
                    controller: _hostelnamecontroller,
                    decoration: const InputDecoration(hintText: "Enter Hostel Name"),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: Color(0xFFB0BEC5)),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isregisternumberempty = _registernumbercontroller.text.isEmpty;
                });

                if (_isregisternumberempty) {
                  // Do not proceed if register number is empty
                  return;
                }
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text(
                        "Add Complaint",
                        style: TextStyle(color: Color(0xFF212121)),
                      ),
                      content: TextField(
                        controller: _complaintController,
                        decoration: const InputDecoration(
                          hintText: "Enter Complaint Details",
                        ),
                        maxLines: 3,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Color(0xFFB0BEC5)),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (_complaintController.text.isNotEmpty) {
                              try {
                                await databaseProvider.postcomplaint(
                                  _complaintController.text,
                                  _complainttypecontroller.text,
                                  _hostelnamecontroller.text,
                                  _registernumbercontroller.text,
                                );

                                _complaintController.clear();
                                _registernumbercontroller.clear();
                                _hostelnamecontroller.clear();
                                _complainttypecontroller.clear();

                                await loadallposts();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Failed to add complaint: $e")),
                                );
                              }
                            }
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Add",
                            style: TextStyle(color: Color(0xFF388E3C)),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text(
                "Next",
                style: TextStyle(color: Color(0xFF388E3C)),
              ),
            ),
          ],
        );
      },
    );
  }}