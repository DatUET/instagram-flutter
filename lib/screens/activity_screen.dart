import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/animations/bouncy_page_route.dart';
import 'package:instagram_v2/models/activity_model.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/comments_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/activity_view.dart';
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
  bool _isLoading = true;
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
    setState(() {});
    List<Activity> activities =
        await DatabaseService.getActivities(widget.currentUserId);
    if (mounted) {
      setState(() {
        _activities = activities;
        _refreshController.refreshCompleted();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: () => _setupActivities(),
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _activities.isEmpty
              ? Center(
                  child: Text(
                    'Data is empty',
                    style: TextStyle(
                        fontSize: 30, color: themeStyle.primaryTextColor),
                  ),
                )
              : ListView.builder(
        addAutomaticKeepAlives: true,
                  itemCount: _activities.length,
                  itemBuilder: (BuildContext context, int index) {
                    Activity activity = _activities[index];
                    return ActivityView(activity: activity);
                  },
                ),
    );
  }
}
