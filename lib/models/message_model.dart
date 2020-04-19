import 'package:cloud_firestore/cloud_firestore.dart';

class Message {

  String id;
  String senderUid;
  String receiverUid;
  String groupId;
  String type;
  String message;
  Timestamp timestamp;
  bool isSeen;
  String photoUrl;

  Message({this.id, this.senderUid, this.receiverUid,
      this.groupId, this.type, this.message, this.timestamp,
      this.isSeen, this.photoUrl});

  Map toMap() {
    var map = Map<String, dynamic>();
    map['id'] = this.id;
    map['senderUid'] = this.senderUid;
    map['receiverUid'] = this.receiverUid;
    map['groupId'] = this.groupId;
    map['type'] = this.type;
    map['message'] = this.message;
    map['timestamp'] = this.timestamp;
    map['isSeen'] = this.isSeen;
    map['photoUrl'] = this.photoUrl;
    return map;
  }

  factory Message.fromMap(DocumentSnapshot map) {
    Message _message = Message();
    _message.id = map['id'];
    _message.senderUid = map['senderUid'];
    _message.receiverUid = map['receiverUid'];
    _message.type = map['type'];
    _message.message = map['message'];
    _message.timestamp = map['timestamp'];
    _message.isSeen = map['isSeen'];
    _message.photoUrl = map['photoUrl'];
    return _message;
  }



}