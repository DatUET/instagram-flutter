import 'package:firebase_auth/firebase_auth.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/home_screen.dart';
import 'package:instagram_v2/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String currentUserId;
  @override
  void initState() {
    super.initState();
    _getBackgroundColor();
    _mockCheckForSession().then((status) {
      if (status) {
        _navigateToHome();
      } else {
        _navigateToLogin();
      }
    });
  }

  Future<Color> _getBackgroundColor() async {
    Color _background;
    final prefs = await SharedPreferences.getInstance();
    int mode = prefs.getInt('mode');
    if (mode == null || mode == 0) {
      _background = Colors.grey[100];
    } else {
      _background = Colors.grey[900];
    }
    return _background;
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 3300), () {});
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      Provider.of<UserData>(context).currentUserId = user.uid.toString();
      currentUserId = user.uid.toString();
      return true;
    } else {
      return false;
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (BuildContext context) => HomeScreen(currentUserId)),
        (Route<dynamic> route) => false);
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (BuildContext context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _getBackgroundColor(),
          builder: (context, snapshot) {
            return Container(
              color: snapshot.data,
              width: double.infinity,
              height: double.infinity,
              child: FlareActor(
                'assets/flares/test_1.flr',
                alignment: Alignment.center,
                animation: 'intro',
              ),
            );
          }),
    );
  }
}
