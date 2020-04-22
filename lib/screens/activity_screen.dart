import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/animations/bouncy_page_route.dart';
import 'package:instagram_v2/models/activity_model.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/comments_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ActivityScreen extends StatefulWidget {
  final String currentUserId;

  ActivityScreen({this.currentUserId});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  List<Activity> _activities = [];
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  var themeStyle;

  @override
  void initState() {
    super.initState();
    _setupActivities();
  }

  _setupActivities() async {
    _refreshController.loadComplete();
    List<Activity> activities =
        await DatabaseService.getActivities(widget.currentUserId);
    if (mounted) {
      setState(() {
        _activities = activities;
        _refreshController.refreshCompleted();
      });
    }
  }

  _buildActivity(Activity activity) {
    return FutureBuilder(
      future: DatabaseService.getUserWithId(activity.fromUserId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularProgressIndicator(),
          ));
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
                    color: user.isActive ? Color(0xFFFE8057) : Colors.grey, width: 1.5),
                image: DecorationImage(
                    image: user.profileImageUrl.isEmpty
                        ? AssetImage(
                        'assets/images/user_placeholder.jpg')
                        : CachedNetworkImageProvider(
                        user.profileImageUrl),
                    fit: BoxFit.cover),
            ),
          ),
            title: activity.comment != null
                ? Text('${user.name} commented: "${activity.comment}"',
                    style: TextStyle(
                      color: themeStyle.primaryTextColor,
                    ))
                : Text('${user.name} liked your post',
                    style: TextStyle(
                      color: themeStyle.primaryTextColor,
                    )),
            subtitle: Text(
                DateFormat.yMd().add_jm().format(
                      activity.timestamp.toDate(),
                    ),
                style: TextStyle(
                  color: themeStyle.primaryTextColor,
                )),
            trailing: CachedNetworkImage(
              imageUrl: activity.postImageUrl,
              height: 40.0,
              width: 40.0,
              fit: BoxFit.cover,
            ),
            onTap: () async {
              String currentUserId =
                  Provider.of<UserData>(context).currentUserId;
              Post post = await DatabaseService.getUserPost(
                currentUserId,
                activity.postId,
              );
              Navigator.push(
                context,
                BouncyPageRoute(widget: CommentsScreen(
                    post: post,
                    likeCount: post.likeCount,
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
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () => _setupActivities(),
      child: ListView.builder(
        itemCount: _activities.length,
        itemBuilder: (BuildContext context, int index) {
          Activity activity = _activities[index];
          return _buildActivity(activity);
        },
      ),
    );
  }
}
