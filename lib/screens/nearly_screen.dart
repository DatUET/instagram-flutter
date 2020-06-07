import 'package:flutter/material.dart';
import 'package:instagram_v2/models/distance_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/nearly_user_view.dart';
import 'package:provider/provider.dart';

class NearlyScreen extends StatefulWidget {
  final String currentUserId;

  NearlyScreen({this.currentUserId});

  @override
  _NearlyScreenState createState() => _NearlyScreenState();
}

class _NearlyScreenState extends State<NearlyScreen> {
  var themeStyle;
  List<NearlyUserView> _nearlyList = [];
  int radius = 10;
  List<Distance> _nearlyUserList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scanNearlyUser();
  }

  _scanNearlyUser() async {
    List<Distance> nearlyUserList = await DatabaseService.getUsersNearly(
        currentUserId: widget.currentUserId, radius: radius);
    setState(() {
      print(nearlyUserList.length);
      _isLoading = false;
      _nearlyUserList = nearlyUserList;
      _nearlyList.clear();
      _nearlyUserList.forEach((distance) {
        _nearlyList.add(NearlyUserView(
          distance: distance,
          currentUserId: widget.currentUserId,
        ));
      });
    });
  }

  _buildFilterScan() {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            children: <Widget>[
              Text(
                'Scanning Radius: $radius km',
                style: TextStyle(
                    color: themeStyle.primaryTextColor, fontSize: 18.0),
              ),
              Spacer(),
              Container(
                width: 100.0,
                child: FlatButton(
                  color: mainColor,
                  textColor: Colors.white,
                  child: Text('Scan'),
                  onPressed: () {
                    setState(() {
                      _isLoading = true;
                    });
                    _scanNearlyUser();
                  },
                ),
              )
            ],
          ),
        ),
        Slider(
          value: radius.toDouble(),
          min: 0,
          max: 50,
          activeColor: mainColor,
          inactiveColor: Color(0xFFFBBDA9),
          onChanged: (newRadius) {
            setState(() {
              radius = newRadius.toInt();
            });
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(mainColor),
            ),
          )
        : Container(
            child: ListView(
              children: <Widget>[
                _buildFilterScan(),
                _nearlyUserList.isEmpty
                    ? Container(
                        child: Center(
                          child: Text(
                            'Data is empty',
                            style: TextStyle(
                                fontSize: 30,
                                color: themeStyle.primaryTextColor),
                          ),
                        ),
                      )
                    : SizedBox.fromSize(
                  size: Size.fromHeight(550.0),
                      child: PageView.builder(
                      itemCount: _nearlyList.length,
                      controller: PageController(viewportFraction: 0.8),
                      itemBuilder: (context, index) {
                  return _nearlyList[index];
                }),
                    )
//                Column(
//                        children: _nearlyList,
//                      )
              ],
            ),
          );
  }
}
