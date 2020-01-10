import 'package:flutter/material.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/widgets/post_view.dart';

class PostScreen extends StatefulWidget {
  final String currentUserId;
  final Post post;

  PostScreen({this.currentUserId, this.post});
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post', style: TextStyle(color: Colors.black),),
      ),
      body: RefreshIndicator(
        onRefresh: (){},
        child: FutureBuilder(
              future: DatabaseService.getUserWithId(widget.post.authorId),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return SizedBox.shrink();
                }
                User author = snapshot.data;
                return PostView(
                  currentUserId: widget.currentUserId,
                  post: widget.post,
                  author: author,
                );
              },
            ),
      ),
    );
  }
}
