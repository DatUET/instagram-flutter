import 'package:flutter/material.dart';
import 'package:instagram_v2/models/activity_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/activity_view.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
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
      header: WaterDropMaterialHeader(
        backgroundColor: mainColor,
      ),
      controller: _refreshController,
      onRefresh: () => _setupActivities(),
      child: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              ),
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
                    return Dismissible(
                        key: ValueKey(_activities.elementAt(index)),
                        onDismissed: (direction) {
                          setState(() {
                            _activities.removeAt(index);
                          });
                          DatabaseService.deleteActivity(
                              currentUserId: widget.currentUserId,
                              activity: activity);
                        },
                        background: Container(
                          color: Colors.red,
                          child: Icon(
                            OMIcons.delete,
                            color: Colors.white,
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          child: Icon(OMIcons.delete, color: Colors.white),
                        ),
                        child: ActivityView(activity: activity));
                  },
                ),
    );
  }
}
