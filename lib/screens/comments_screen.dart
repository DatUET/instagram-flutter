import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/comment_model.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/pickup_layout.dart';
import 'package:instagram_v2/widgets/post_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;

  CommentsScreen({this.post});

  @override
  _CommentsScreenState createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isCommenting = false;
  var themeStyle;

  _buildComment(Comment comment) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(comment.authorId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return SizedBox.shrink();
        }
        User author = snapshot.data;
        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                border: Border.all(
                    width: 1.5,
                    color: author.isActive ? mainColor : Colors.grey),
                image: DecorationImage(
                    image: author.profileImageUrl.isEmpty
                        ? AssetImage('assets/images/user_placeholder.jpg')
                        : CachedNetworkImageProvider(
                            author.profileImageUrl,
                          ),
                    fit: BoxFit.cover)),
          ),
          title: Text(
            author.name,
            style: TextStyle(
                color: themeStyle.primaryTextColor,
                fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                comment.content,
                style: TextStyle(color: themeStyle.primaryTextColor),
              ),
              SizedBox(height: 6.0),
              Text(
                DateFormat.yMd().add_jm().format(comment.timestamp.toDate()),
                style: TextStyle(color: themeStyle.primaryTextColor),
              ),
            ],
          ),
        );
      },
    );
  }

  _buildCommentTF() {
    final currentUserId = Provider.of<UserData>(context).currentUserId;
    return IconTheme(
      data: IconThemeData(
        color: _isCommenting
            ? Theme.of(context).accentColor
            : Theme.of(context).disabledColor,
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(width: 10.0),
            Expanded(
              child: TextField(
                controller: _commentController,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: themeStyle.primaryTextColor),
                onChanged: (comment) {
                  setState(() {
                    _isCommenting = comment.length > 0;
                  });
                },
                decoration: InputDecoration.collapsed(
                    hintText: 'Write a comment...',
                    hintStyle: TextStyle(color: themeStyle.primaryTextColor)),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(
                  Icons.send,
                  color: themeStyle.primaryIconColor,
                ),
                onPressed: () {
                  if (_isCommenting) {
                    DatabaseService.commentOnPost(
                      currentUserId: currentUserId,
                      post: widget.post,
                      comment: _commentController.text,
                    );
                    _commentController.clear();
                    setState(() {
                      _isCommenting = false;
                    });
                  }
                },
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
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: themeStyle.primaryBackgroundColor,
        appBar: AppBar(
          backgroundColor: themeStyle.primaryBackgroundColor,
          iconTheme: IconThemeData(color: themeStyle.primaryIconColor),
          title: Text(
            'Comments',
            style: TextStyle(color: themeStyle.primaryTextColor),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    FutureBuilder(
                        future:
                            DatabaseService.getUserWithId(widget.post.authorId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(mainColor),
                              ),
                            );
                          }
                          return PostView(
                            currentUserId: themeStyle.currentUserId,
                            post: widget.post,
                            author: snapshot.data,
                            isCommentScreen: true,
                          );
                        }),
                    StreamBuilder(
                      stream: commentsRef
                          .document(widget.post.id)
                          .collection('postComments')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(mainColor),
                            ),
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (BuildContext context, int index) {
                            Comment comment =
                                Comment.fromDoc(snapshot.data.documents[index]);
                            return _buildComment(comment);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 1.0),
              _buildCommentTF(),
            ],
          ),
        ),
      ),
    );
  }
}
