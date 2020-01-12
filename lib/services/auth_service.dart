import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/home_screen.dart';
import 'package:instagram_v2/screens/login_screen.dart';
import 'package:instagram_v2/screens/splash_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:provider/provider.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = Firestore.instance;

  static Future<bool> signUpUser(
      BuildContext context, String name, String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseUser signedInUser = authResult.user;
      if (signedInUser != null) {
        _firestore.collection('/users').document(signedInUser.uid).setData({
          'name': name,
          'email': email,
          'profileImageUrl': '',
        });
        Provider.of<UserData>(context).currentUserId = signedInUser.uid;
        DatabaseService.followUser(currentUserId: signedInUser.uid, userId: signedInUser.uid);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => SplashScreen()));
        return true;
      }
      return false;
    } catch (e) {
      print(e);
    }
    return false;
  }

  static void logout() {
    _auth.signOut();
  }

  static Future<bool> login(String email, String password, BuildContext context) async {
    try {
      AuthResult authResult = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = authResult.user;
      if(user != null){
        Provider.of<UserData>(context).currentUserId = user.uid;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
        return true;
      }
      return false;
    } catch (e) {
      print(e);
    }
    return false;
  }
}
