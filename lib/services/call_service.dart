import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_v2/models/call_model.dart';
import 'package:instagram_v2/models/message_model.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';

class CallService {
  static Stream<DocumentSnapshot> callStream(String uid) => callRef.document(uid).snapshots();

  static Future<bool> makeCall(Call call) async {
    try {
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      Map<String, dynamic> hasNoDialled = call.toMap(call);

      await callRef.document(call.callerId).setData(hasDialledMap);
      await callRef.document(call.receiverId).setData(hasNoDialled);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<bool> endCall(Call call) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (call.callerId == user.uid) {
      Message message = Message(
        id: call.channelId,
        senderUid: call.callerId,
        receiverUid: call.receiverId,
        type: 'video call',
        message: 'Video Call',
        timestamp: Timestamp.fromMillisecondsSinceEpoch(
            int.parse(call.channelId)),
        isSeen: false,
        photoUrl: '',
      );
      try { //
        await DatabaseService.sendMessage(message);
        await callRef.document(call.callerId).delete();
        await callRef.document(call.receiverId).delete();
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    }
    return false;
  }
}