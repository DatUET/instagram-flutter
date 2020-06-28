import 'dart:math';

import 'package:flutter/material.dart';
import 'package:instagram_v2/models/call_model.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/call_screen.dart';
import 'package:instagram_v2/services/call_service.dart';

class CallUtils {
  static dial({User from, User to, context, String type}) async {
    Call call = Call(
      callerId: from.id,
      callerName: from.name,
      callerPic: from.profileImageUrl,
      receiverId: to.id,
      receiverName: to.name,
      type: type,
      receiverPic: to.profileImageUrl,
      channelId: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    bool callMade = await CallService.makeCall(call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CallScreen(call: call),
          ));
    }
  }
}
