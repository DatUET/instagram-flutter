import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String id;
  final String userId;
  final Timestamp timestamp;
  final String contentReport;

  Report({
    this.id,
    this.userId,
    this.timestamp,
    this.contentReport
});

//  factory Report.fromDoc(DocumentSnapshot doc) {
//    return Report(
//      id: doc.documentID,
//      userId: doc['userId'],
//      name: doc['name'],
//      profileImageUrl: doc['profileImageUrl'],
//      email: doc['email'],
//      timestamp: doc['timestamp'],
//      contentReport: doc['contentReport'],
//    );
//  }

  Map toMap() {
    var map = Map<String, dynamic>();
    map['userId'] = this.userId;
    map['timestamp'] = Timestamp.fromDate(DateTime.now());
    map['contentReport'] = this.contentReport;
    return map;
  }
}