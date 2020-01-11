import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/home_screen.dart';
import 'package:instagram_v2/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shimmer/shimmer.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();

    _mockCheckForSession().then(
            (status) {
          if (status) {
            _navigateToHome();
          } else {
            _navigateToLogin();
          }
        }
    );
  }


  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 3000), () {});
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if(user != null){
//      StreamBuilder<FirebaseUser>(
//      stream: FirebaseAuth.instance.onAuthStateChanged,
//      builder: (BuildContext context, snapshot)
//      {
//        if (snapshot.hasData) {
//          Provider
//              .of<UserData>(context)
//              .currentUserId = snapshot.data.uid;
//        }
//      });
      Provider.of<UserData>(context).currentUserId = user.uid.toString();
      return true;
    }
    else{
      return false;
    }
  }
  void _navigateToHome(){
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (BuildContext context) => HomeScreen()
        )
    );
  }

  void _navigateToLogin(){
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen()
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Shimmer.fromColors(
              period: Duration(milliseconds: 1000),
              baseColor: Color.fromRGBO(143, 148, 251, 1),
              highlightColor: Color.fromRGBO(143, 148, 251, .2),
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Instagram",
                  style: TextStyle(
                    color: Colors.black87,
                      fontSize: 90.0,
                      fontFamily: 'Billabong',
                      shadows: <Shadow>[
                        Shadow(
                            blurRadius: 18.0,
                            color: Color.fromRGBO(143, 148, 251, .7),
                            offset: Offset.fromDirection(120, 12)
                        )
                      ]
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


}