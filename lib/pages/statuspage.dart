import 'package:complaintnow/components/homepagetile.dart';
import 'package:complaintnow/services/authservice.dart';
import 'package:complaintnow/services/databaseprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatefulWidget {
  final String uid;

  const StatusPage({super.key, required this.uid});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  late final DatabaseProvider listeningProvider;

  @override
  void initState() {
    super.initState();
    listeningProvider = Provider.of<DatabaseProvider>(context, listen: false);
    listeningProvider.loadallposts();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Authservice().getcurrentuid();
    final allUserPosts = listeningProvider.filteruserposts(currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: Text("My Complaints",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body:

      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: ListView(
          children: [
            allUserPosts.isEmpty
                ?

            Center ( child:
            Text("No Complaints"))
                : ListView.builder(
                itemCount: allUserPosts.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final post = allUserPosts[index];
                  return Homepagetile(
                    timestamp: post.timestamp,
                    uid: post.uid,
                    postid: post.id,
                    registernumber: post.registernumber,
                    complainttype: post.complainttype,
                    hostelname: post.hostelname,
                    complaint: post.Complaint, status: '',
                  );
                }),
          ],
        ),
      ),
    );
  }
}
