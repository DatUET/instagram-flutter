import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/call_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/pickup_screen.dart';
import 'package:instagram_v2/services/call_service.dart';
import 'package:provider/provider.dart';

class PickupLayout extends StatelessWidget {
  final Widget scaffold;

  PickupLayout({@required this.scaffold});

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserData>(context);
    return (userData != null && userData.currentUserId != null)
    ? StreamBuilder<DocumentSnapshot>(
      stream: CallService.callStream(userData.currentUserId),
        builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data.data != null) {
          Call call = Call.fromMap(snapshot.data.data);
          if (!call.hasDialled) {
            return PickUpScreen(call: call,);
          }
          return scaffold;
        }
        return scaffold;
        }
    )
    : scaffold;
  }
}
