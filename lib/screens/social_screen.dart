import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/animations/bouncy_page_route.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/activity_screen.dart';
import 'package:instagram_v2/screens/chat_list_screen.dart';
import 'package:instagram_v2/screens/create_post_screen.dart';
import 'package:instagram_v2/screens/feed_screen.dart';
import 'package:instagram_v2/screens/home_screen.dart';
import 'package:instagram_v2/screens/profile_screen.dart';
import 'package:instagram_v2/screens/search_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:provider/provider.dart';

class SocialScreen extends StatefulWidget {
  final String currentUserId;
  SocialScreen({this.currentUserId});
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollViewController;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollViewController = new ScrollController(initialScrollOffset: 0.0);
    _tabController = new TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: themeStyle.primaryBackgroundColor,
      body: NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          //<-- headerSliverBuilder
          return <Widget>[
            new SliverAppBar(
              backgroundColor: themeStyle.primaryBackgroundColor,
              title: Text(
                'Photogram',
                style: TextStyle(
                  color: themeStyle.primaryTextColor,
                  fontFamily: 'Billabong',
                  fontSize: 35.0,
                ),
              ),
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.search,
                      color: themeStyle.primaryIconColor,
                    ),
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => SearchScreen()))),
                Stack(
                  children: <Widget>[
                    FutureBuilder(
                      future: DatabaseService.checkIsSeenAll(widget.currentUserId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container();
                        }
                        return snapshot.data ? Transform.translate(
                          offset: Offset(15, -3),
                          child: Container(
                            width: 10,
                            height: 10,
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(width: 2, color: Colors.white),
                                shape: BoxShape.circle,
                                color: mainColor
                            ),
                          ),
                        )
                        : Container();
                      }
                    ),
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
                FutureBuilder(
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
                              border: Border.all(
                                  color: mainColor, width: 1.5),
                              image: DecorationImage(
                                  image: user.profileImageUrl.isEmpty
                                      ? AssetImage(
                                          'assets/images/user_placeholder.jpg')
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
                              BouncyPageRoute(
                                  widget: ProfileScreen(
                                currentUserId: widget.currentUserId,
                                userId: widget.currentUserId,
                              )));
                        },
                      );
                    }),
              ],
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
              bottom: new TabBar(
                indicator: ShapeDecoration(
                  shape: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: mainColor,
                          width: 4.0,
                          style: BorderStyle.solid)),
                ),
                labelColor: mainColor,
                unselectedLabelColor: themeStyle.primaryIconColor,
                tabs: <Tab>[
                  new Tab(
                    icon: new Icon(
                      Icons.public,
                    ),
                    text: 'Feed',
                  ),
                  new Tab(
                    icon: new Icon(
                      Icons.add_circle_outline,
                    ),
                    text: 'Add Post',
                  ),
                  new Tab(
                    icon: new Icon(
                      Icons.notifications_none,
                    ),
                    text: 'Notification',
                  ),
                ],
                controller: _tabController,
              ),
            ),
          ];
        },
        body: new TabBarView(
          children: <Widget>[
            new FeedScreen(
              currentUserId: widget.currentUserId,
            ),
            new CreatePostScreen(),
            new ActivityScreen(
              currentUserId: widget.currentUserId,
            )
          ],
          controller: _tabController,
        ),
      ),
    );
  }
}
