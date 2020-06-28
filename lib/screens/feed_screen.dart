import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/activity_screen.dart';
import 'package:instagram_v2/screens/chat_list_screen.dart';
import 'package:instagram_v2/screens/profile_screen.dart';
import 'package:instagram_v2/screens/search_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/post_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FeedScreen extends StatefulWidget {
  static final String id = 'feed_screen';
  final String currentUserId;

  FeedScreen({this.currentUserId});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var themeStyle;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupFeed();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      if (maxScroll == currentScroll) {
        _getMorePost();
      }
    });
  }

  _setupFeed() async {
    _isLoading = true;
    _posts.clear();
    setState(() {});
    _refreshController.loadComplete();
    List<Post> posts = await DatabaseService.getFeedPosts(widget.currentUserId);
    setState(() {
      _posts = posts;
      _isLoading = false;
      _refreshController.refreshCompleted();
    });
  }

  _getMorePost() async {
    List<Post> morePosts = await DatabaseService.getMoreFeedPosts(
        widget.currentUserId, _posts[_posts.length - 1].timestamp);
    setState(() {
      _posts.addAll(morePosts);
    });
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
        leading: FutureBuilder(
            future: usersRef.document(widget.currentUserId).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return InkWell(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            image: AssetImage(
                                'assets/images/user_placeholder.jpg'),
                            fit: BoxFit.cover),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 5,
                              color: Colors.grey[500],
                              offset: Offset(3, 3))
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    return Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                                  currentUserId: widget.currentUserId,
                                  userId: widget.currentUserId,
                                )));
                  },
                );
              }
              User user = User.fromDoc(snapshot.data);
              return InkWell(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: mainColor, width: 1.5),
                      image: DecorationImage(
                          image: user.profileImageUrl.isEmpty
                              ? AssetImage('assets/images/user_placeholder.jpg')
                              : CachedNetworkImageProvider(
                                  user.profileImageUrl),
                          fit: BoxFit.cover),
                      boxShadow: [
                        BoxShadow(
                            blurRadius: 5,
                            color: Colors.grey[600],
                            offset: Offset(3.5, 3.5))
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  return Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(
                                currentUserId: widget.currentUserId,
                                userId: widget.currentUserId,
                              )));
                },
              );
            }),
        actions: <Widget>[
          Stack(
            children: <Widget>[
              StreamBuilder(
                  stream: DatabaseService.checkIsSeenAll(widget.currentUserId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    return snapshot.data != 0
                        ? Transform.translate(
                            offset: Offset(15, -3),
                            child: Container(
                              width: 10,
                              height: 10,
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 2, color: Colors.white),
                                  shape: BoxShape.circle,
                                  color: mainColor),
                            ),
                          )
                        : Container();
                  }),
              IconButton(
                  icon: Icon(
                    Icons.send,
                    color: themeStyle.primaryIconColor,
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ChatListScreen(
                                currentUserId: widget.currentUserId,
                              )))),
            ],
          ),
          IconButton(
              icon: Icon(
                Icons.notifications_none,
                color: themeStyle.primaryIconColor,
              ),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ActivityScreen(
                            currentUserId: widget.currentUserId,
                          )))),
        ],
      ),
      body: SmartRefresher(
          header: WaterDropMaterialHeader(
            backgroundColor: mainColor,
          ),
          controller: _refreshController,
          onRefresh: () => _setupFeed(),
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                ))
              : (_posts.isEmpty
                  ? Center(
                      child: Text(
                        'Data is empty',
                        style: TextStyle(
                            fontSize: 30, color: themeStyle.primaryTextColor),
                      ),
                    )
                  : ListView.builder(
                      addAutomaticKeepAlives: true,
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        Post post = _posts[index];
                        return FutureBuilder(
                          future: DatabaseService.getUserWithId(post.authorId),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                              return SizedBox.shrink();
                            }
                            User author = snapshot.data;
                            return PostView(
                                currentUserId: widget.currentUserId,
                                post: post,
                                author: author,
                                isCommentScreen: false,
                                updateAfterDelete: () {
                                  setState(() {
                                    _posts.removeAt(index);
                                  });
                                });
                          },
                        );
                      },
                    ))),
    );
  }
}
