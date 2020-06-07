import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/distance_model.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/chat_screen.dart';
import 'package:instagram_v2/screens/profile_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:provider/provider.dart';

class NearlyUserView extends StatefulWidget {
  final Distance distance;
  final String currentUserId;

  NearlyUserView({@required this.distance, this.currentUserId});

  @override
  _NearlyUserViewState createState() => _NearlyUserViewState();
}

class _NearlyUserViewState extends State<NearlyUserView> {
  bool _isFollowing = false;
  int _followerCount = 0;
  int _followingCount = 0;
  int _postCount = 0;
  List<Post> _posts = [];

  var themeStyle;

  @override
  void initState() {
    super.initState();
    _setupIsFollowing();
    _setupFollowers();
    _setupFollowing();
    _setupPostsCount();
    _setupPosts();
  }

  _setupIsFollowing() async {
    bool isFollowingUser = await DatabaseService.isFollowingUser(
      currentUserId: widget.currentUserId,
      userId: widget.distance.id,
    );
    setState(() {
      _isFollowing = isFollowingUser;
    });
  }

  _setupFollowers() async {
    int userFollowerCount =
        await DatabaseService.numFollowers(widget.distance.id);
    setState(() {
      _followerCount = userFollowerCount - 1;
    });
  }

  _setupFollowing() async {
    int userFollowingCount =
        await DatabaseService.numFollowing(widget.distance.id);
    setState(() {
      _followingCount = userFollowingCount - 1;
    });
  }

  _setupPostsCount() async {
    await DatabaseService.getUserPosts(widget.distance.id).then((value) {
      setState(() {
        _postCount = value.length;
      });
    });
  }

  _setupPosts() async {
    List<Post> posts = await DatabaseService.getSixPost(widget.distance.id);
    setState(() {
      _posts = posts;
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
      userId: widget.distance.id,
    );
    setState(() {
      _isFollowing = false;
      _followerCount--;
    });
  }

  _followUser() {
    DatabaseService.followUser(
      currentUserId: widget.currentUserId,
      userId: widget.distance.id,
    );
    setState(() {
      _isFollowing = true;
      _followerCount++;
    });
  }

  _moveToChatScreen() {
    User user = User(
      id: widget.distance.id,
      name: widget.distance.name,
      bio: widget.distance.bio,
      email: widget.distance.email,
      isActive: widget.distance.isActive,
      profileImageUrl: widget.distance.profileImageUrl,
      type: widget.distance.type,
    );
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ChatScreen(
                  currentUserId: widget.currentUserId,
                  chatWithUser: user,
                )));
  }

  _buildHeader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
            child: Text(
          widget.distance.name,
          style: TextStyle(
              color: themeStyle.primaryTextColor,
              fontSize: 22.0,
              fontWeight: FontWeight.bold),
        )),
        SizedBox(
          height: 8.0,
        ),
        Text(
          widget.distance.bio,
          style: TextStyle(color: themeStyle.primaryTextColor),
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  _buildIconFollowAndChat() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
            icon: !_isFollowing
                ? Icon(
                    Icons.person_add,
                    color: mainColor,
                    size: 32.0,
                  )
                : Icon(
                    Icons.person,
                    color: themeStyle.primaryIconColor,
                    size: 32.0,
                  ),
            onPressed: _followOrUnfollow),
        SizedBox(
          width: 48.0,
        ),
        IconButton(
            icon: Icon(
              Icons.message,
              color: mainColor,
              size: 32.0,
            ),
            onPressed: _moveToChatScreen),
      ],
    );
  }

  _buildInfoUser() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
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
        ],
      ),
    );
  }

  _buildListImagePost() {
    List<Widget> listImageBuilt = [];
    for (Post post in _posts) {
      listImageBuilt.add(_buildImagePost(post.imageUrl));
    }
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      shrinkWrap: true,
      children: listImageBuilt,
    );
  }

  _buildImagePost(String imagePost) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(15)),
          image: DecorationImage(
              image: CachedNetworkImageProvider(
                imagePost,
              ),
              fit: BoxFit.cover)),
    );
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProfileScreen(
                    currentUserId: widget.currentUserId,
                    userId: widget.distance.id,
                  ))),
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: 100,
              bottom: 0.0,
              left: 16.0,
              right: 16.0,
            ),
            margin: EdgeInsets.only(
                top: 30.0, left: 12.0, right: 12.0, bottom: 12.0),
            decoration: BoxDecoration(
              color: themeStyle.primaryBackgroundColor,
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[600],
                    blurRadius: 5.0,
                    offset: Offset(3, 3))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(),
                _buildIconFollowAndChat(),
                SizedBox(
                  height: 8.0,
                ),
                _buildInfoUser(),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Contact: ',
                      style: TextStyle(color: themeStyle.primaryTextColor),
                    ),
                    Text(
                      '${widget.distance.email}',
                      style: TextStyle(
                          color: themeStyle.primaryTextColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                _postCount == 0
                    ? Container(
                        padding: EdgeInsets.only(top: 16.0),
                        child: Center(
                          child: Text(
                            'The List Post Is Empty',
                            style: TextStyle(
                                fontSize: 24,
                                color: themeStyle.primaryTextColor),
                          ),
                        ),
                      )
                    : _buildListImagePost()
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 10.0),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  border: Border.all(
                      width: 1.5,
                      color:
                          widget.distance.isActive ? mainColor : Colors.grey),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey[600],
                        blurRadius: 10.0,
                        offset: Offset(0, 5))
                  ],
                  image: DecorationImage(
                      image: widget.distance.profileImageUrl.isEmpty
                          ? AssetImage('assets/images/user_placeholder.jpg')
                          : CachedNetworkImageProvider(
                              widget.distance.profileImageUrl,
                            ),
                      fit: BoxFit.cover)),
            ),
          ),
          Positioned(
            top: 40.0,
            right: 20.0,
            child: Text(
              '${widget.distance.distance} km',
              style: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
