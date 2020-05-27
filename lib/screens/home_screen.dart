import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/camera_screen.dart';
import 'package:instagram_v2/screens/chat_screen.dart';
import 'package:instagram_v2/screens/comments_screen.dart';
import 'package:instagram_v2/screens/gallery_screen.dart';
import 'package:instagram_v2/screens/social_screen.dart';
import 'package:instagram_v2/screens/splash_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/pickup_layout.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen(this.currentUserId);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentTab = 0;
  PageController _pageController;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  _setUpFCM() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onLaunch: (message) async {
        print('onLauch ${message.toString()}');
        _navigateToChatOrComment(message);
        return;
      },
      onMessage: (message) async {
        print('onMessage ${message.toString()}');
        await showNotification(message);
        return;
      },
      onResume: (message) async {
        print('onResume ${message.toString()}');
        _navigateToChatOrComment(message);
        return;
      },
    );

    _firebaseMessaging.getToken().then((token) async {
      print(token);
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      DatabaseService.updateToken(user.uid, token);
    });
  }

  _navigateToChatOrComment(Map<String, dynamic> message) async {
    if (message['data']['type'] == 'chat') {
      User sender =
      await DatabaseService.getUserWithId(message['data']['senderUid']);
      navigatorKey.currentState.push(MaterialPageRoute(
          builder: (_) => ChatScreen(
            currentUserId: message['data']['receiverUid'],
            chatWithUser: sender,
          )));
    } else if (message['data']['type'] == 'post') {
      Post post = await DatabaseService.getUserPost(
          widget.currentUserId, message['data']['postId']);
      navigatorKey.currentState.push(MaterialPageRoute(
          builder: (_) => CommentsScreen(
            post: post,
          )));
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    DatabaseService.updateActive(widget.currentUserId, true);
    _pageController = PageController();
    _setUpFCM();
    configLocalNotification();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      //print('Pause');
      DatabaseService.updateActive(widget.currentUserId, false);
    } else if (state == AppLifecycleState.resumed) {
      //print('Resumed');
      DatabaseService.updateActive(widget.currentUserId, true);
    }
//    print('state = $state');
  }

  Future<void> showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'com.example.photogram', 'Photogram', 'channel for photogram',
        playSound: true,
        enableVibration: true,
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'].toString(),
        message['notification']['body'].toString(),
        platformChannelSpecifics,
        payload: 'default_sound'
    );
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  jumpToGallery() {
    _pageController.animateToPage(
      1,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle = Provider.of<UserData>(context);
    return PickupLayout(
      scaffold: Scaffold(
        body: PageView(
          controller: _pageController,
          children: <Widget>[
            SocialScreen(
              currentUserId: themeStyle.currentUserId,
            ),
            GalleyScreen(),
            CameraScreen(_pageController)
          ],
          onPageChanged: (int index) {
            setState(() {
              _currentTab = index;
            });
          },
        ),
        bottomNavigationBar: CupertinoTabBar(
          backgroundColor: themeStyle.primaryBackgroundColor,
          currentIndex: _currentTab,
          onTap: (int index) {
            setState(() {
              _currentTab = index;
            });
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
            );
          },
          activeColor: Colors.black,
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                OMIcons.home,
                size: 32.0,
                color: _currentTab == 0 ? mainColor : themeStyle.primaryIconColor,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                OMIcons.photoAlbum,
                size: 32.0,
                color: _currentTab == 1 ? mainColor : themeStyle.primaryIconColor,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                OMIcons.cameraEnhance,
                size: 32.0,
                color: _currentTab == 2 ? mainColor : themeStyle.primaryIconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
