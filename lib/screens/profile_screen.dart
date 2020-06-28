import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_v2/animations/bouncy_page_route.dart';
import 'package:instagram_v2/animations/fadeanimationup.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/chat_screen.dart';
import 'package:instagram_v2/screens/edit_profile_screen.dart';
import 'package:instagram_v2/screens/login_screen.dart';
import 'package:instagram_v2/services/auth_service.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/pickup_layout.dart';
import 'package:instagram_v2/widgets/post_view.dart';
import 'package:provider/provider.dart';

import 'comments_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String currentUserId;
  final String userId;

  ProfileScreen({this.currentUserId, this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  int _followerCount = 0;
  int _followingCount = 0;
  List<Post> _posts = [];
  int _displayPosts = 0; // 0 - grid, 1 - column
  User _profileUser;
  var themeStyle;
  ScrollController _profileScrollController = ScrollController();
  bool _isExistUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUser();
    _setupIsFollowing();
    _setupFollowers();
    _setupFollowing();
    _setupPosts();
    _setupProfileUser();
    _profileScrollController.addListener(() {
      double maxScroll = _profileScrollController.position.maxScrollExtent;
      double current = _profileScrollController.position.pixels;
      if (maxScroll == current) {
        _getMorePost();
      }
    });
  }

  _checkUser() async {
    bool isExistUser = await DatabaseService.checkExitUser(widget.userId);
    setState(() {
      _isExistUser = isExistUser;
      _isLoading = false;
    });
  }

  _getMorePost() async {
    List<Post> morePost = await DatabaseService.getMoreUserPosts(
        widget.userId, _posts[_posts.length - 1].timestamp);
    setState(() {
      _posts.addAll(morePost);
    });
  }

  _setupIsFollowing() async {
    bool isFollowingUser = await DatabaseService.isFollowingUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async {
    int userFollowerCount = await DatabaseService.numFollowers(widget.userId);
    setState(() {
      _followerCount = userFollowerCount - 1;
    });
  }

  _setupFollowing() async {
    int userFollowingCount = await DatabaseService.numFollowing(widget.userId);
    setState(() {
      _followingCount = userFollowingCount - 1;
    });
  }

  _setupPosts() async {
    List<Post> posts = await DatabaseService.getUserPosts(widget.userId);
    setState(() {
      _posts = posts;
    });
  }

  _setupProfileUser() async {
    User profileUser = await DatabaseService.getUserWithId(widget.userId);
    setState(() {
      _profileUser = profileUser;
    });
  }

  _followOrUnfollow() {
    if (_isFollowing) {
      _unfollowUser();
    } else {
      _followUser();
    }
  }

  _unfollowUser() {
    DatabaseService.unfollowUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = false;
      _followerCount--;
    });
  }

  _followUser() {
    DatabaseService.followUser(
      currentUserId: widget.currentUserId,
      userId: widget.userId,
    );
    setState(() {
      _isFollowing = true;
      _followerCount++;
    });
  }

  _displayButton(User user) {
    return user.id == Provider.of<UserData>(context).currentUserId
        ? GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              width: 200.0,
              child: Center(
                child: Text(
                  'Setting',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfileScreen(
                  user: user,
                ),
              ),
            ),
          )
        : GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              width: 200.0,
              decoration: BoxDecoration(
                  color: _isFollowing ? Colors.grey[200] : mainColor,
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Center(
                child: Text(
                  _isFollowing ? 'Unfollow' : 'Follow',
                  style: TextStyle(
                      fontSize: 18.0,
                      color: _isFollowing ? Colors.black : Colors.white),
                ),
              ),
            ),
            onTap: _followOrUnfollow,
          );
  }

  _buildButtonChat(User user) {
    return user.id == Provider.of<UserData>(context).currentUserId
        ? Container()
        : Container(
            width: 150,
            height: 40,
            decoration: BoxDecoration(
                color: themeStyle.primaryBackgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                border: Border.all(color: Colors.grey)),
            child: FlatButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(
                            currentUserId: themeStyle.currentUserId,
                            chatWithUser: user,
                          ))),
              child: Row(
                children: <Widget>[
                  Text(
                    'Send Message',
                    style: TextStyle(
                        color: themeStyle.primaryTextColor, fontSize: 12),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.send,
                    color: themeStyle.primaryIconColor,
                    size: 20,
                  )
                ],
              ),
            ),
          );
  }

  _buildProfileInfo(User user) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FadeAnimationUp(
            0.4,
            Column(
              children: <Widget>[
                Text(
                  _posts.length.toString(),
                  style: TextStyle(
                    color: themeStyle.primaryTextColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'posts',
                  style: TextStyle(color: themeStyle.primaryTextColor),
                ),
              ],
            ),
          ),
          FadeAnimationUp(
            0.6,
            Column(
              children: <Widget>[
                Text(
                  _followerCount.toString(),
                  style: TextStyle(
                    color: themeStyle.primaryTextColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'followers',
                  style: TextStyle(color: themeStyle.primaryTextColor),
                ),
              ],
            ),
          ),
          FadeAnimationUp(
            0.8,
            Column(
              children: <Widget>[
                Text(
                  _followingCount.toString(),
                  style: TextStyle(
                    color: themeStyle.primaryTextColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'following',
                  style: TextStyle(color: themeStyle.primaryTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          iconSize: 30.0,
          color: _displayPosts == 0 ? mainColor : themeStyle.primaryIconColor,
          onPressed: () => setState(() {
            _displayPosts = 0;
          }),
        ),
        IconButton(
          icon: Icon(Icons.list),
          iconSize: 30.0,
          color: _displayPosts == 1 ? mainColor : themeStyle.primaryIconColor,
          onPressed: () => setState(() {
            _displayPosts = 1;
          }),
        ),
      ],
    );
  }

  _buildTilePost(Post post, int index) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            BoxShadow(
                color: Colors.grey[600], blurRadius: 10.0, offset: Offset(0, 5))
          ]),
      child: FadeAnimationUp(
        (index * 2) / 10.0,
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            BouncyPageRoute(
              widget: CommentsScreen(
                post: post,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: Image(
              image: CachedNetworkImageProvider(post.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  _buildDisplayPosts() {
    if (_displayPosts == 0) {
      // Grid
      return Container(
        color: themeStyle.primaryBackgroundColor,
        child: StaggeredGridView.countBuilder(
          crossAxisCount: 2,
          itemCount: _posts.length,
          mainAxisSpacing: 12.0,
          crossAxisSpacing: 12.0,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => _buildTilePost(_posts[index], index),
          staggeredTileBuilder: (index) {
            return StaggeredTile.count(1, index.isEven ? 2 : 1);
          },
        ),
      );
    } else {
      // Column
      List<PostView> postViews = [];
      for (int i = 0; i < _posts.length; i++) {
        postViews.add(
          PostView(
            currentUserId: widget.currentUserId,
            post: _posts[i],
            author: _profileUser,
            isCommentScreen: false,
            updateAfterDelete: () {
              setState(() {
                _posts.removeAt(i);
              });
            },
          ),
        );
      }
      return Container(
          color: themeStyle.primaryBackgroundColor,
          child: Column(children: postViews));
    }
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: themeStyle.primaryBackgroundColor,
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                ),
              )
            : !_isExistUser
                ? Center(
                    child: Text(
                    '404 Not Found',
                    style: TextStyle(
                        fontSize: 30, color: themeStyle.primaryTextColor),
                  ))
                : StreamBuilder(
                    stream: usersRef.document(widget.userId).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(mainColor),
                          ),
                        );
                      }
                      //print('data qr${snapshot.data}');
                      User user = User.fromDoc(snapshot.data);
//            if (user == null) {
//              return Center(child: Text('404 Not Found'),);
//            }
                      return Container(
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: double.infinity,
                            ),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: user.profileImageUrl.isEmpty
                                      ? AssetImage(
                                          'assets/images/user_placeholder.jpg')
                                      : CachedNetworkImageProvider(
                                          user.profileImageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              height: double.infinity,
                            ),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                    Colors.white.withOpacity(.3),
                                    Colors.white.withOpacity(.5),
                                    Colors.white.withOpacity(.8)
                                  ])),
                            ),
                            SingleChildScrollView(
                              controller: _profileScrollController,
                              child: Stack(
                                children: <Widget>[
                                  Positioned(
                                    top: 150,
                                    left: 0.01,
                                    right: 0.01,
                                    child: Container(
                                      height: 700,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color:
                                            themeStyle.primaryBackgroundColor,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40),
                                          topRight: Radius.circular(40),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 90.0),
                                      child: Container(
                                        height: 150,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          border: Border.all(
                                              width: 2,
                                              color: user.isActive
                                                  ? mainColor
                                                  : Colors.grey),
                                          image: DecorationImage(
                                            image: user.profileImageUrl.isEmpty
                                                ? AssetImage(
                                                    'assets/images/user_placeholder.jpg')
                                                : CachedNetworkImageProvider(
                                                    user.profileImageUrl),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 260),
                                      child: Column(children: <Widget>[
                                        Text(
                                          user.name,
                                          style: TextStyle(
                                            fontSize: 25,
                                            color: themeStyle.primaryTextColor,
                                          ),
                                        ),
                                        Text(
                                          user.bio,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: themeStyle.primaryTextColor,
                                          ),
                                        ),
                                        _displayButton(user),
                                        SizedBox(
                                          height: 8.0,
                                        ),
                                        _buildButtonChat(user),
                                        _buildProfileInfo(user),
                                        _buildToggleButtons(),
                                        Divider(),
                                        _buildDisplayPosts(),
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 50.0, left: 10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: themeStyle.primaryIconColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
