import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/distance_model.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/chat_screen.dart';
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

class _NearlyUserViewState extends State<NearlyUserView> with AutomaticKeepAliveClientMixin<NearlyUserView> {
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
    List<Post> posts = await DatabaseService.getThreePost(widget.distance.id);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(
                  width: 1.5,
                  color: widget.distance.isActive ? mainColor : Colors.grey),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[600],
                    blurRadius: 5.0,
                    offset: Offset(3, 3))
              ],
              image: DecorationImage(
                  image: widget.distance.profileImageUrl.isEmpty
                      ? AssetImage('assets/images/user_placeholder.jpg')
                      : CachedNetworkImageProvider(
                          widget.distance.profileImageUrl,
                        ),
                  fit: BoxFit.cover)),
        ),
        SizedBox(
          width: 8.0,
        ),
        Flexible(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.start,
            text: TextSpan(
              text: widget.distance.name,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: themeStyle.primaryTextColor,
              ),
            ),
          ),
        ),
        Spacer(),
        Text(
          '${widget.distance.distance} km',
          style: TextStyle(
            color: mainColor,
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
          ),
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

  _buildListImagePost() {
    List<Widget> listImageBuilt = [];
    for (int i = 0; i < _posts.length; i++) {
      listImageBuilt.add(_buildImagePost(_posts[i].imageUrl));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
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
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: themeStyle.primaryBackgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        boxShadow: [
          BoxShadow(
              color: Colors.grey[600], blurRadius: 5.0, offset: Offset(3, 3))
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
          Row(
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
            height: 8.0,
          ),
          Row(
            children: <Widget>[
              Text(
                '${_postCount.toString()} ',
                style: TextStyle(
                    color: themeStyle.primaryTextColor,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Posts',
                style: TextStyle(color: themeStyle.primaryTextColor),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: <Widget>[
              Text(
                '${_followingCount.toString()} ',
                style: TextStyle(
                    color: themeStyle.primaryTextColor,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Followings',
                style: TextStyle(color: themeStyle.primaryTextColor),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: <Widget>[
              Text(
                '${_followerCount.toString()} ',
                style: TextStyle(
                    color: themeStyle.primaryTextColor,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'Followers',
                style: TextStyle(color: themeStyle.primaryTextColor),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          _postCount == 0 ? Container() : _buildListImagePost()
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
