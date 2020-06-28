import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:instagram_v2/models/call_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/call_screen.dart';
import 'package:instagram_v2/services/call_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/utilities/permisstions.dart';
import 'package:provider/provider.dart';

class PickUpScreen extends StatelessWidget {
  final Call call;

  PickUpScreen({this.call});

  @override
  Widget build(BuildContext context) {
    FlutterRingtonePlayer.playRingtone();
    final themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: themeStyle.primaryBackgroundColor,
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Incoming...',
                style:
                    TextStyle(fontSize: 30, color: themeStyle.primaryTextColor),
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    border: Border.all(color: mainColor, width: 2.5),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: call.callerPic == ''
                          ? AssetImage('assets/images/user_placeholder.jpg')
                          : CachedNetworkImageProvider(
                              call.callerPic,
                            ),
                    )),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                call.callerName,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: themeStyle.primaryTextColor),
              ),
              SizedBox(
                height: 75,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipOval(
                      child: Material(
                    color: Colors.redAccent,
                    child: InkWell(
                      splashColor: Colors.white.withOpacity(.2),
                      child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Icon(
                            Icons.call_end,
                            color: Colors.white,
                          )),
                      onTap: () async {
                        await FlutterRingtonePlayer.stop();
                        await CallService.endCall(call);
                      },
                    ),
                  )),
                  SizedBox(
                    width: 50,
                  ),
                  ClipOval(
                      child: Material(
                    color: Colors.green,
                    child: InkWell(
                      splashColor: Colors.white.withOpacity(.2),
                      child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Icon(
                            Icons.call,
                            color: Colors.white,
                          )),
                      onTap: () async {
                        await FlutterRingtonePlayer.stop();
                        await Permissions
                                .cameraAndMicrophonePermissionsGranted()
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => CallScreen(call: call)))
                            : {};
                      },
                    ),
                  )),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
