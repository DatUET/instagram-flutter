import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _setupIsFollowing();
    _setupFollowers();
    _setupFollowing();
    _setupPosts();
    _setupProfileUser();
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
        ? Container(
            width: 200.0,
            child: FlatButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(
                    user: user,
                  ),
                ),
              ),
              color: Colors.blue,
              textColor: Colors.white,
              child: Text(
                'Edit Profile',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          )
        : Container(
            width: 200.0,
            child: FlatButton(
              onPressed: _followOrUnfollow,
              color: _isFollowing ? Colors.grey[200] : Colors.blue,
              textColor: _isFollowing ? Colors.black : Colors.white,
              child: Text(
                _isFollowing ? 'Unfollow' : 'Follow',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
  }

  _buildButtonChat(User user) {
    return user.id == Provider.of<UserData>(context).currentUserId
        ? Container()
        : Container(
      width: 145,
      height: 40,
      decoration: BoxDecoration(
          color: themeStyle.primaryBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(color: Colors.grey)
      ),
      child: FlatButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(currentUserId: themeStyle.currentUserId, chatWithUser: user,))),
        child: Row(
          children: <Widget>[
            Text('Send Message', style: TextStyle(color: themeStyle.primaryTextColor, fontSize: 12),),
            SizedBox(width: 10,),
            Icon(Icons.send, color: themeStyle.primaryIconColor, size: 20,)
          ],
        ),
      ),
    );
  }

  _buildProfileInfo(User user) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
          child: Row(
            children: <Widget>[
              FadeAnimationUp(
                0.2,
                CircleAvatar(
                  radius: 50.0,
                  backgroundColor: Colors.grey,
                  backgroundImage: user.profileImageUrl.isEmpty
                      ? AssetImage('assets/images/user_placeholder.jpg')
                      : CachedNetworkImageProvider(user.profileImageUrl),
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Row(
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
                                style: TextStyle(
                                    color: themeStyle.primaryTextColor),
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
                                style: TextStyle(
                                    color: themeStyle.primaryTextColor),
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
                                style: TextStyle(
                                    color: themeStyle.primaryTextColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    FadeAnimationUp(1, _displayButton(user)),
                  ],
                ),
              )
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FadeAnimationUp(
                1.2,
                Text(
                  user.name,
                  style: TextStyle(
                    color: themeStyle.primaryTextColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 5.0),
              Container(
                height: 30.0,
                child: FadeAnimationUp(
                  1.4,
                  Text(
                    user.bio,
                    style: TextStyle(
                        color: themeStyle.primaryTextColor, fontSize: 15.0),
                  ),
                ),
              ),
              FadeAnimationUp(1.6, _buildButtonChat(user)),
              Divider(
                color: themeStyle.primaryTextColorLight,
              ),
            ],
          ),
        ),
      ],
    );
  }

  _buildToggleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          iconSize: 30.0,
          color: _displayPosts == 0
              ? Theme.of(context).primaryColor
              : themeStyle.primaryIconColor,
          onPressed: () => setState(() {
            _displayPosts = 0;
          }),
        ),
        IconButton(
          icon: Icon(Icons.list),
          iconSize: 30.0,
          color: _displayPosts == 1
              ? Theme.of(context).primaryColor
              : themeStyle.primaryIconColor,
          onPressed: () => setState(() {
            _displayPosts = 1;
          }),
        ),
      ],
    );
  }

  _buildTilePost(Post post, int index) {
    return GridTile(
      child: FadeAnimationUp(
        (index * 2) / 10.0,
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CommentsScreen(
                post: post,
                likeCount: post.likeCount,
              ),
            ),
          ),
          child: Image(
            image: CachedNetworkImageProvider(post.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  _buildDisplayPosts() {
    if (_displayPosts == 0) {
      // Grid
      List<GridTile> tiles = [];
      for (int i = 0; i < _posts.length; i++) {
        Post post = _posts[i];
        tiles.add(_buildTilePost(post, i));
      }
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2.0,
        crossAxisSpacing: 2.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: tiles,
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
          ),
        );
      }
      return Column(children: postViews);
    }
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: themeStyle.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeStyle.primaryBackgroundColor,
        title: Text(
          'Photogram',
          style: TextStyle(
            color: themeStyle.primaryTextColor,
            fontFamily: 'Billabong',
            fontSize: 35.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              color: themeStyle.primaryIconColor,
            ),
            onPressed: () {
              AuthService.logout();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginScreen()));
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: usersRef.document(widget.userId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          User user = User.fromDoc(snapshot.data);
          return ListView(
            children: <Widget>[
              _buildProfileInfo(user),
              _buildToggleButtons(),
              Divider(),
              _buildDisplayPosts(),
            ],
          );
        },
      ),
    );
  }
}
