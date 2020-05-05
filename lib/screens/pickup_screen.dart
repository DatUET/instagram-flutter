import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/call_model.dart';
import 'package:instagram_v2/screens/call_screen.dart';
import 'package:instagram_v2/services/call_service.dart';
import 'package:instagram_v2/utilities/permisstions.dart';

class PickUpScreen extends StatelessWidget {
  final Call call;

  PickUpScreen({this.call});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Incoming...',
              style: TextStyle(fontSize: 30),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 150,
              width: 150,
              child: call.callerPic == ''
                  ? AssetImage('assets/images/user_placeholder.jpg')
                  : CachedNetworkImage(
                      imageUrl: call.callerPic,
                    ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              call.callerName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(
              height: 75,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                    icon: Icon(Icons.call_end),
                    color: Colors.redAccent,
                    onPressed: () async {
                      await CallService.endCall(call);
                    }),
                SizedBox(
                  width: 25,
                ),
                IconButton(
                    icon: Icon(Icons.call),
                    color: Colors.green,
                    onPressed: () async => await Permissions
                            .cameraAndMicrophonePermissionsGranted()
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => CallScreen(call: call)))
                        : {})
              ],
            )
          ],
        ),
      ),
    );
  }
}
