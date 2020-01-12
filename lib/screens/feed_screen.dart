import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/widgets/post_view.dart';

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

  @override
  void initState() {
    super.initState();
    _setupFeed();
  }

  _setupFeed() async {
    List<Post> posts = await DatabaseService.getFeedPosts(widget.currentUserId);
    setState(() {
      _posts = posts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'Instagram',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Billabong',
              fontSize: 35.0,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => _setupFeed(),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : ( _posts.isEmpty
                  ? Center(
                      child: Text(
                        'Data is empty',
                        style: TextStyle(fontSize: 30),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _posts.length,
                      itemBuilder: (BuildContext context, int index) {
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
                              index: index,
                            );
                          },
                        );
                      },
                    )),
        ));
  }
}
