import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram_v2/animations/bouncy_page_route.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/comments_screen.dart';
import 'package:instagram_v2/screens/profile_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/services/photo_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class PostView extends StatefulWidget {
  final String currentUserId;
  final Post post;
  final User author;
  final bool isCommentScreen;

  PostView({this.currentUserId, this.post, this.author, this.isCommentScreen});

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView>
    with AutomaticKeepAliveClientMixin<PostView> {
  int _likeCount = 0;
  bool _isLiked = false;
  bool _heartAnim = false;
  var themeStyle;
  PermissionStatus _status;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    PermissionHandler().checkPermissionStatus(PermissionGroup.storage).then(_updateStatus);
    _initPostLiked();
  }

  @override
  void didUpdateWidget(PostView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.likeCount != widget.post.likeCount) {
      _likeCount = widget.post.likeCount;
    }
  }

  _updateStatus(PermissionStatus status) {
    setState(() {
      _status = status;
    });
  }

  _askPermission() {
    PermissionHandler().requestPermissions([PermissionGroup.storage]).then((statuses) {
      final status = statuses[PermissionGroup.storage];
      if (status != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: 'Please allow permission!', toastLength: Toast.LENGTH_LONG);
      } else {
        PhotoService.downloadImage(
            widget.post.imageUrl, false);
        _updateStatus(status);
      }
    });
  }

  _initPostLiked() async {
    bool isLiked = await DatabaseService.didLikePost(
      currentUserId: widget.currentUserId,
      post: widget.post,
    );
    if (mounted) {
      setState(() {
        _isLiked = isLiked;
      });
    }
  }

  _likePost() {
    if (_isLiked) {
      // Unlike Post
      DatabaseService.unlikePost(
          currentUserId: widget.currentUserId, post: widget.post);
      setState(() {
        _isLiked = false;
        _likeCount = _likeCount - 1;
      });
    } else {
      // Like Post
      DatabaseService.likePost(
          currentUserId: widget.currentUserId, post: widget.post);
      setState(() {
        _heartAnim = true;
        _isLiked = true;
        _likeCount = _likeCount + 1;
      });
      Timer(Duration(milliseconds: 350), () {
        setState(() {
          _heartAnim = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(
                  currentUserId: widget.currentUserId,
                  userId: widget.post.authorId,
                ),
              ),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        border: Border.all(
                            width: 1.5,
                            color: widget.author.isActive
                                ? mainColor
                                : Colors.grey),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey[600],
                              blurRadius: 5.0,
                              offset: Offset(3, 3))
                        ],
                        image: DecorationImage(
                            image: widget.author.profileImageUrl.isEmpty
                                ? AssetImage(
                                    'assets/images/user_placeholder.jpg')
                                : CachedNetworkImageProvider(
                                    widget.author.profileImageUrl,
                                  ),
                            fit: BoxFit.cover)),
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    children: <Widget>[
                      Text(
                        widget.author.name,
                        style: TextStyle(
                          color: themeStyle.primaryTextColor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      widget.post.location.isEmpty
                          ? Container()
                          : Text(
                              widget.post.location,
                              style: TextStyle(
                                color: themeStyle.primaryTextColor,
                                fontSize: 13.0,
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onDoubleTap: _likePost,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(5.0),
                  height: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(widget.post.imageUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[800],
                            blurRadius: 20.0,
                            offset: Offset(0, 5))
                      ]),
                ),
                _heartAnim
                    ? Animator(
                        duration: Duration(milliseconds: 300),
                        tween: Tween(begin: 0.5, end: 1.4),
                        curve: Curves.elasticOut,
                        builder: (anim) => Transform.scale(
                          scale: anim.value,
                          child: Icon(
                            Icons.favorite,
                            size: 100.0,
                            color: Colors.red[400],
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: _isLiked
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : Icon(
                              Icons.favorite_border,
                              color: themeStyle.primaryIconColor,
                            ),
                      iconSize: 30.0,
                      onPressed: _likePost,
                    ),
                    widget.isCommentScreen ? Container() : IconButton(
                      icon: Icon(
                        Icons.comment,
                        color: themeStyle.primaryIconColor,
                      ),
                      iconSize: 30.0,
                      onPressed: () => Navigator.push(
                        context,
                        BouncyPageRoute(
                          widget: CommentsScreen(
                            post: widget.post,

                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.file_download,
                          color: themeStyle.primaryIconColor,
                        ),
                        iconSize: 30.0,
                        onPressed: () {
                          if (_status == PermissionStatus.granted) {
                            PhotoService.downloadImage(
                                widget.post.imageUrl, false);
                          } else {
                            _askPermission();
                          }
                        })
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    '${_likeCount.toString()} likes',
                    style: TextStyle(
                      color: themeStyle.primaryTextColor,
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 4.0),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                        left: 12.0,
                        right: 6.0,
                      ),
                      child: Text(
                        widget.author.name,
                        style: TextStyle(
                          color: themeStyle.primaryTextColor,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.post.caption,
                        style: TextStyle(
                          color: themeStyle.primaryTextColor,
                          fontSize: 16.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
