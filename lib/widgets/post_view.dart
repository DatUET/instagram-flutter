import 'dart:async';

import 'package:animator/animator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram_v2/animations/bouncy_page_route.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/report_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/comments_screen.dart';
import 'package:instagram_v2/screens/profile_screen.dart';
import 'package:instagram_v2/screens/update_post_screen.dart';
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
  final Function updateAfterDelete;

  PostView(
      {this.currentUserId,
      this.post,
      this.author,
      this.isCommentScreen,
      this.updateAfterDelete});

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView>
    with AutomaticKeepAliveClientMixin<PostView> {
  bool _isLiked = false;
  bool _heartAnim = false;
  bool _isReported = false;
  var themeStyle;
  PermissionStatus _status;
  String _contentReport;
  final _formKeyReport = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    //_likeCount = widget.post.likeCount;
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then(_updateStatus);
    _initPostLiked();
    _initCheckReported();
  }

  _initCheckReported() async {
    bool isReported = await DatabaseService.didReportedPost(
        widget.currentUserId, widget.post.id);
    setState(() {
      _isReported = isReported;
    });
  }

  _sendReportPost(BuildContext context) async {
    if (_formKeyReport.currentState.validate()) {
      _formKeyReport.currentState.save();
      Report report = Report(
        userId: widget.currentUserId,
        contentReport: _contentReport,
      );
      bool isReported =
          await DatabaseService.sendReportPost(widget.post.id, report);
      setState(() {
        _isReported = isReported;
        if (isReported) {
          Navigator.pop(context);
          key.currentState.showSnackBar(SnackBar(
            content: Text('Your report has been submitted.'),
            action: SnackBarAction(label: 'Ok', onPressed: () {}),
          ));
        }
      });
    }
  }

  _updateStatus(PermissionStatus status) {
    setState(() {
      _status = status;
    });
  }

  _askPermission() {
    PermissionHandler()
        .requestPermissions([PermissionGroup.storage]).then((statuses) {
      final status = statuses[PermissionGroup.storage];
      if (status != PermissionStatus.granted) {
        Fluttertoast.showToast(
            msg: 'Please allow permission!', toastLength: Toast.LENGTH_LONG);
      } else {
        PhotoService.downloadImage(widget.post.imageUrl, false);
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
        //_likeCount = _likeCount - 1;
      });
    } else {
      // Like Post
      DatabaseService.likePost(
          currentUserId: widget.currentUserId, post: widget.post);
      setState(() {
        _heartAnim = true;
        _isLiked = true;
        //_likeCount = _likeCount + 1;
      });
      Timer(Duration(milliseconds: 350), () {
        setState(() {
          _heartAnim = false;
        });
      });
    }
  }

  _showOptionPost() {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: key.currentContext,
        builder: (context) {
          return widget.post.authorId == widget.currentUserId
              ? _buildDeletePost()
              : _buildReportPost(context);
        });
  }

  _buildDeletePost() {
    return AnimatedPadding(
        duration: const Duration(milliseconds: 100),
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
              color: themeStyle.primaryBackgroundColor,
              borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16))),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  //Navigator.pop(context);
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => UpdatePostScreen(
                                post: widget.post,
                              )));
                },
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                      color: themeStyle.primaryBackgroundColor,
                      borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16))),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Icon(
                        Icons.update,
                        color: themeStyle.primaryIconColor,
                        size: 32.0,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Text('Update Post',
                          style: TextStyle(
                              color: themeStyle.primaryTextColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  DatabaseService.deletePost(widget.post);
                  widget.updateAfterDelete();
                },
                child: Container(
                  color: themeStyle.primaryBackgroundColor,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Icon(
                        OMIcons.cancel,
                        color: Colors.redAccent,
                        size: 32.0,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Text('DELETE POST',
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w700))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _buildReportPost(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 100),
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        height: _isReported ? 120 : 300,
        decoration: BoxDecoration(
            color: themeStyle.primaryBackgroundColor,
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20))),
        child: _isReported
            ? Center(
                child: Text(
                  'You have already reported this post',
                  style: TextStyle(
                      color: themeStyle.primaryTextColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700),
                ),
              )
            : Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                              colors: [mainColor, mainColor.withOpacity(.6)])
                          .createShader(bounds),
                      child: Text(
                        'Report Post',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, left: 16.0, top: 32.0),
                    child: Text('Enter the reason you want to report',
                        style: TextStyle(
                            color: themeStyle.primaryTextColor, fontSize: 18)),
                  ),
                  Form(
                    key: _formKeyReport,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        cursorColor: mainColor,
                        keyboardType: TextInputType.text,
                        style: TextStyle(color: themeStyle.primaryTextColor),
                        decoration: InputDecoration(
                            labelText: 'Reason',
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: mainColor)),
                            labelStyle:
                                TextStyle(color: themeStyle.primaryTextColor)),
                        validator: (input) =>
                            input.isEmpty ? 'Please enter a reason' : null,
                        onSaved: (input) => _contentReport = input,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 60),
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                            colors: [mainColor, mainColor.withOpacity(.6)]),
                        boxShadow: [
                          BoxShadow(
                              color: mainColor.withOpacity(.4),
                              blurRadius: 20,
                              offset: Offset(0, 10))
                        ]),
                    child: FlatButton(
                      onPressed: () => _sendReportPost(context),
                      child: Center(
                        child: Text(
                          'Send Report',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
            onLongPress: () =>
                widget.isCommentScreen ? () {} : _showOptionPost(),
            onDoubleTap: !widget.isCommentScreen ? _likePost : () {},
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
                    widget.isCommentScreen
                        ? Container()
                        : IconButton(
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
                    widget.isCommentScreen
                        ? Container()
                        : IconButton(
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
                    widget.post.enableDownload
                        ? IconButton(
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
                        : Container(),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: StreamBuilder(
                      stream: postsRef
                          .document(widget.post.authorId)
                          .collection('userPosts')
                          .document(widget.post.id)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Container();
                        Post post = Post.fromDoc(snapshot.data);
                        return Text(
                          '${post.likeCount.toString()} likes',
                          style: TextStyle(
                            color: themeStyle.primaryTextColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
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
