import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firestore = Firestore.instance;
final storageRef = FirebaseStorage.instance.ref();
final usersRef = _firestore.collection('users');
final postsRef = _firestore.collection('posts');
final followersRef = _firestore.collection('followers');
final followingRef = _firestore.collection('following');
final feedsRef = _firestore.collection('feeds');
final likesRef = _firestore.collection('likes');
final commentsRef = _firestore.collection('comments');
final activitiesRef = _firestore.collection('activities');
final messageRef = _firestore.collection('message');
final recentChatRef = _firestore.collection('recentChat');
final tokenRef = _firestore.collection('tokens');
final callRef = _firestore.collection('call');
final trendingLikeRef = _firestore.collection('trendingLike');
final blockMessageRef = _firestore.collection('blockMessage');
final locationRef = _firestore.collection('location');
final distanceRef = _firestore.collection('distance');
final reportRef = _firestore.collection('report');

final Color mainColor = Color(0xFFFE8057);
const String APP_ID_AGORA = 'c508bbcd84b44fdeabd52a9cb8acf00a';

final key = new GlobalKey<ScaffoldState>();

final per_page = 15;
