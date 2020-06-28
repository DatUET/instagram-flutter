import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/activity_model.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/comments_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ActivityView extends StatefulWidget {
  final Activity activity;

  ActivityView({@required this.activity});

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView>
    with AutomaticKeepAliveClientMixin<ActivityView> {
  @override
  Widget build(BuildContext context) {
    final themeStyle = Provider.of<UserData>(context);
    return FutureBuilder(
      future: DatabaseService.getUserWithId(widget.activity.fromUserId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }
        User user = snapshot.data;
        return Container(
          color: themeStyle.primaryBackgroundColor,
          child: ListTile(
            leading: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: user.isActive ? mainColor : Colors.grey, width: 1.5),
                image: DecorationImage(
                    image: user.profileImageUrl.isEmpty
                        ? AssetImage('assets/images/user_placeholder.jpg')
                        : CachedNetworkImageProvider(user.profileImageUrl),
                    fit: BoxFit.cover),
              ),
            ),
            title: widget.activity.comment != null
                ? Text('${user.name} commented: "${widget.activity.comment}"',
                    style: TextStyle(
                      color: themeStyle.primaryTextColor,
                    ))
                : Text('${user.name} liked your post',
                    style: TextStyle(
                      color: themeStyle.primaryTextColor,
                    )),
            subtitle: Text(
                DateFormat.yMd().add_jm().format(
                      widget.activity.timestamp.toDate(),
                    ),
                style: TextStyle(
                  color: themeStyle.primaryTextColor,
                )),
            trailing: CachedNetworkImage(
              imageUrl: widget.activity.postImageUrl,
              height: 40.0,
              width: 40.0,
              fit: BoxFit.cover,
            ),
            onTap: () async {
              String currentUserId =
                  Provider.of<UserData>(context).currentUserId;
              Post post = await DatabaseService.getUserPost(
                currentUserId,
                widget.activity.postId,
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CommentsScreen(
                    post: post,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
