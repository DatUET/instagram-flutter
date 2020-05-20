import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_v2/animations/bouncy_page_route.dart';
import 'package:instagram_v2/animations/fadeanimationup.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/comments_screen.dart';
import 'package:instagram_v2/screens/profile_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/pickup_layout.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot> _users;
  var themeStyle;
  List<Post> _trendingLike = [];

  @override
  void initState() {
    super.initState();
    _initTrending();
  }

  _initTrending() async {
    List<Post> trendingLike = await DatabaseService.getTrendingLike();
    setState(() {
      _trendingLike = trendingLike;
    });
  }

  _buildUserTile(User user) {
    return ListTile(
      contentPadding:
          EdgeInsets.only(top: 3.0, bottom: 3.0, right: 16.0, left: 16.0),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.all(Radius.circular(15)),
            border: Border.all(
                width: 1.5, color: user.isActive ? mainColor : Colors.grey),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey[600],
                  blurRadius: 5.0,
                  offset: Offset(3, 3))
            ],
            image: DecorationImage(
                image: user.profileImageUrl.isEmpty
                    ? AssetImage('assets/images/user_placeholder.jpg')
                    : CachedNetworkImageProvider(
                        user.profileImageUrl,
                      ),
                fit: BoxFit.cover)),
      ),
      title: Text(
        user.name,
        style: TextStyle(color: themeStyle.primaryTextColor),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProfileScreen(
            currentUserId: Provider.of<UserData>(context).currentUserId,
            userId: user.id,
          ),
        ),
      ),
    );
  }

  _clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      _users = null;
    });
  }

  Future<void> _scanQRCodeId() async {
    String barcodeResult = await FlutterBarcodeScanner.scanBarcode(
        '#8AFFFFFF', 'Cancel', true, ScanMode.QR);
    if (barcodeResult != '-1') {
      Navigator.push(
          context,
          BouncyPageRoute(
              widget: ProfileScreen(
            currentUserId: themeStyle.currentUserId,
            userId: barcodeResult,
          )));
    }
  }

  _buildTrending() {
    return Container(
      color: themeStyle.primaryBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: _trendingLike.length,
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) =>
            _buildTilePost(_trendingLike[index], index),
        staggeredTileBuilder: (index) {
          return StaggeredTile.count(1, index.isEven ? 2 : 1.5);
        },
      ),
    );
  }

  _buildTilePost(Post post, int index) {
    return Container(
      child: FadeAnimationUp(
        (index * 2) / 10.0,
        GestureDetector(
            onTap: () => Navigator.push(
                  context,
                  BouncyPageRoute(
                    widget: CommentsScreen(
                      post: post,
                    ),
                  ),
                ),
            child: Stack(
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: CachedNetworkImageProvider(post.imageUrl),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                      topRight: Radius.circular(20.0)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey[600],
                            blurRadius: 10.0,
                            offset: Offset(0, 5))
                      ]),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 64.0,
                    decoration: BoxDecoration(
                        color: themeStyle.primaryBackgroundColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey[600],
                              blurRadius: 10.0,
                              offset: Offset(0, -5))
                        ]),
                    child: FutureBuilder(
                        future: DatabaseService.getUserWithId(post.authorId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Container();
                          User author = snapshot.data;
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(12)),
                                      border: Border.all(
                                          width: 1.5,
                                          color: author.isActive
                                              ? mainColor
                                              : Colors.grey),
                                      image: DecorationImage(
                                          image: author.profileImageUrl.isEmpty
                                              ? AssetImage(
                                                  'assets/images/user_placeholder.jpg')
                                              : CachedNetworkImageProvider(
                                                  author.profileImageUrl,
                                                ),
                                          fit: BoxFit.cover)),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: RichText(
                                    overflow: TextOverflow.ellipsis,
                                    strutStyle:
                                        StrutStyle(fontWeight: FontWeight.w500),
                                    text: TextSpan(
                                        style: TextStyle(
                                            color: themeStyle.primaryTextColor,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w500),
                                        text: author.name),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        post.likeCount.toString(),
                                        style: TextStyle(
                                            color: themeStyle.primaryTextColor,
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 15,
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                )
              ],
            )),
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
          iconTheme: IconThemeData(color: themeStyle.primaryIconColor),
          backgroundColor: themeStyle.primaryBackgroundColor,
          title: TextField(
            cursorColor: mainColor,
            controller: _searchController,
            style: TextStyle(color: themeStyle.primaryTextColor),
            decoration: InputDecoration(
              fillColor: themeStyle.typeMessageBoxColor,
              contentPadding: EdgeInsets.symmetric(vertical: 15.0),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(25.0),
                ),
              ),
              hintText: 'Search',
              hintStyle: TextStyle(color: themeStyle.primaryTextColor),
              prefixIcon: Icon(
                Icons.search,
                size: 30.0,
                color: themeStyle.primaryIconColor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.clear,
                  color: themeStyle.primaryIconColor,
                ),
                onPressed: _clearSearch,
              ),
              filled: true,
            ),
            onSubmitted: (input) {
              if (input.isNotEmpty) {
                setState(() {
                  _users = DatabaseService.searchUsers(input);
                });
              }
            },
          ),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.border_horizontal,
                  color: themeStyle.primaryIconColor,
                ),
                onPressed: () => _scanQRCodeId())
          ],
        ),
        body: _users == null
            ? _trendingLike.isEmpty
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                    ),
                  )
                : SingleChildScrollView(
                    child: _buildTrending(),
                  )
            : FutureBuilder(
                future: _users,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                      ),
                    );
                  }
                  if (snapshot.data.documents.length == 0) {
                    return Center(
                      child: Text('No users found! Please try again.'),
                    );
                  }
                  return ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      User user = User.fromDoc(snapshot.data.documents[index]);
                      return _buildUserTile(user);
                    },
                  );
                },
              ),
      ),
    );
  }
}
