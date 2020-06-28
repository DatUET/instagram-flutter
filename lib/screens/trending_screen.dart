import 'package:bubble_tab_indicator/bubble_tab_indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_v2/animations/fadeanimationup.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/comments_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:provider/provider.dart';

class TrendingScreen extends StatefulWidget {
  @override
  _TrendingScreenState createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  var themeStyle;
  ScrollController _trendingScrollController = ScrollController();
  List<Post> _trendingPost = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _setUpTrendingPost();
    _trendingScrollController.addListener(() {
      double maxScroll = _trendingScrollController.position.maxScrollExtent;
      double current = _trendingScrollController.position.pixels;
      if (maxScroll == current) {
        _getMoreTrendingPost();
      }
    });
  }

  _setUpTrendingPost() async {
    List<Post> trendingPost = await DatabaseService.getTrendingLike();
    setState(() {
      _trendingPost = trendingPost;
      _isLoading = false;
    });
  }

  _getMoreTrendingPost() async {
    List<Post> morePost = await DatabaseService.getMoreTrendingLike(
        _trendingPost[_trendingPost.length - 1].id);
    setState(() {
      _trendingPost.addAll(morePost);
    });
  }

  _buildTrending(List<Post> trendingLike) {
    return Container(
      color: themeStyle.primaryBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 2,
        itemCount: trendingLike.length,
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) =>
            _buildTilePost(trendingLike[index], index),
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
                  MaterialPageRoute(
                    builder: (_) => CommentsScreen(
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
    return Container(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                ),
              )
            : SingleChildScrollView(
                controller: _trendingScrollController,
                child: _buildTrending(_trendingPost),
              ));
  }
}
