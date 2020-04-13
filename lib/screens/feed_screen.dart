import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
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
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  var themeStyle;

  @override
  void initState() {
    super.initState();
    _setupFeed();
  }

  _setupFeed() async {
    _refreshController.loadComplete();
    List<Post> posts = await DatabaseService.getFeedPosts(widget.currentUserId);
    setState(() {
      _posts = posts;
      _isLoading = false;
      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () => _setupFeed(),
      child: _isLoading
          ? Center(child: CircularProgressIndicator())
          : (_posts.isEmpty
              ? Center(
                  child: Text(
                    'Data is empty',
                    style: TextStyle(fontSize: 30, color: themeStyle.primaryTextColor),
                  ),
                )
              : ListView.builder(
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
                        );
                      },
                    );
                  },
                )),
    );
  }
}
