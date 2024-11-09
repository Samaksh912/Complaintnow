import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final int likecount;
  final List<String> likedby;
  final String id;
  final String uid;
  final String hostelname;
  final String complainttype;
  final String registernumber;
  final Timestamp timestamp;
  final String Complaint;
  final String status;

  Post( {
    required this.id,
    required this.uid,
    required this.timestamp,
    required this.complainttype,
    required this.hostelname,
    required this.registernumber,
    required this.Complaint,
    required this.likedby,
    required this.likecount,
    required this.status,

  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      id: doc.id,
      uid: doc['uid'],
      timestamp: doc['timestamp'],
      complainttype: doc['complainttype'],
      hostelname: doc['hostelname'],
      registernumber: doc['registernumber'],
      Complaint: doc['complaint'],
      likecount: doc['likecount'],
      likedby: List<String>.from(doc['likedby'] ?? []),
      status: doc['status'] ?? 'Pending', // Default to 'Pending' if not set
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'timestamp': timestamp,
      'complainttype': complainttype,
      'hostelname': hostelname,
      'registernumber': registernumber,
      'complaint': Complaint,
      'likecount': likecount,
      'likedby': likedby,
      'status': status,
    };
  }
}
