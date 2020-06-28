import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/camera_screen.dart';
import 'package:instagram_v2/screens/chat_screen.dart';
import 'package:instagram_v2/screens/comments_screen.dart';
import 'package:instagram_v2/screens/create_post_screen.dart';
import 'package:instagram_v2/screens/feed_screen.dart';
import 'package:instagram_v2/screens/search_screen.dart';
import 'package:instagram_v2/screens/splash_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/pickup_layout.dart';
import 'package:location/location.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:permission_handler/permission_handler.dart' as permission;
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

  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _setUpLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) async {
      await DatabaseService.updateLocation(
          currentUserId: widget.currentUserId,
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude);
    });
  }

  _setUpFCM() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure(
      onLaunch: (message) async {
        _navigateToChatOrComment(message);
        return;
      },
      onMessage: (message) async {
        await showNotification(message);
        return;
      },
      onResume: (message) async {
        _navigateToChatOrComment(message);
        return;
      },
    );

    _firebaseMessaging.getToken().then((token) async {
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
    permission.PermissionHandler()
        .checkPermissionStatus(permission.PermissionGroup.storage)
        .then(_updateStatus);
  }

  _updateStatus(permission.PermissionStatus status) {
    if (status != permission.PermissionStatus.granted) {
      _askPermission();
    } else {
      _setUpLocation();
    }
  }

  _askPermission() {
    permission.PermissionHandler().requestPermissions(
        [permission.PermissionGroup.storage]).then((statuses) {
      final status = statuses[permission.PermissionGroup.storage];
      if (status != permission.PermissionStatus.granted) {
        Fluttertoast.showToast(
            msg: 'Please allow permission!', toastLength: Toast.LENGTH_LONG);
      } else {
        _updateStatus(status);
      }
      _setUpLocation();
    });
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
        payload: 'default_sound');
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
        key: key,
        body: PageView(
          controller: _pageController,
          children: <Widget>[
            FeedScreen(
              currentUserId: themeStyle.currentUserId,
            ),
            SearchScreen(),
            CreatePostScreen(),
            CameraScreen()
          ],
          onPageChanged: (int index) {
            setState(() {
              _currentTab = index;
            });
          },
        ),
        bottomNavigationBar: BottomNavyBar(
          backgroundColor: themeStyle.primaryBackgroundColor,
          selectedIndex: _currentTab,
          onItemSelected: (int index) {
            setState(() {
              _currentTab = index;
            });
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
            );
          },
          items: [
            BottomNavyBarItem(
                title: Text("Home"),
                icon: Icon(Icons.home),
                activeColor: mainColor),
            BottomNavyBarItem(
                title: Text("Search"),
                icon: Icon(Icons.search),
                activeColor: Colors.redAccent),
            BottomNavyBarItem(
                title: Text("Create Post"),
                icon: Icon(OMIcons.addBox),
                activeColor: Colors.green),
            BottomNavyBarItem(
                title: Text("Camera"),
                icon: Icon(Icons.camera),
                activeColor: Colors.deepPurpleAccent),
          ],
        ),
      ),
    );
  }
}
