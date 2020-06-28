import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/login_screen.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:provider/provider.dart';

class SuccessScreen extends StatelessWidget {
  final int type;
  final String email;

  SuccessScreen({this.type, this.email});

  @override
  Widget build(BuildContext context) {
    final themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: themeStyle.primaryBackgroundColor,
      body: Stack(
        children: <Widget>[
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: FlareActor(
                'assets/flares/success.flr',
                alignment: Alignment.center,
                animation: 'start',
              ),
            ),
          ),
          Positioned(
              bottom: 160,
              left: 60,
              right: 60,
              child: type == 0
                  ? Text(
                      'You have successfully registered. Please check your email $email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: themeStyle.primaryTextColor,
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                          fontWeight: FontWeight.w600),
                    )
                  : Container()),
          Positioned(
            bottom: 80,
            left: 100,
            right: 100,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(colors: [
                    mainColor.withOpacity(.6),
                    mainColor.withOpacity(1),
                  ]),
                  boxShadow: [
                    BoxShadow(
                        color: mainColor.withOpacity(.4),
                        blurRadius: 20,
                        offset: Offset(0, 10))
                  ]),
              child: FlatButton(
                onPressed: () {
                  type == 0
                      ? Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => LoginScreen()))
                      : Navigator.pop(context);
                },
                child: Center(
                  child: Text(
                    type == 0 ? 'Go to Log in' : 'Back to Setting',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
