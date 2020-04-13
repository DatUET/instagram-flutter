import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery/image_gallery.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/preview_photo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class GalleyScreen extends StatefulWidget {
  @override
  _GalleyScreenState createState() => _GalleyScreenState();
}

class _GalleyScreenState extends State<GalleyScreen> with AutomaticKeepAliveClientMixin {
  List _allUri = [];
  var _dir;
  var themeStyle;

  Future<void> _getImagePath() async {
    var dir = await getTemporaryDirectory();
    Map<dynamic, dynamic> allImage = await FlutterGallaryPlugin.getAllImages;
    print(allImage[0]);
    setState(() {
      _allUri = allImage["URIList"] as List;
      _allUri = _allUri.reversed.toList();
      _dir = dir;

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getImagePath();
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: themeStyle.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeStyle.primaryBackgroundColor,
        title: Text(
          'Instagram',
          style: TextStyle(
            color: themeStyle.primaryTextColor,
            fontFamily: 'Billabong',
            fontSize: 35.0,
          ),
        ),
      ),
      body: RefreshIndicator(child: _buildGridTile(), onRefresh: () => _getImagePath()),
    );
  }

  Future<void> _buildGridTileList() async {

  }

  _buildGridTile() {
    if (themeStyle.gridTileImage.length > 0) {
      return GridView.count(
        addAutomaticKeepAlives: true,
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        shrinkWrap: true,
        children: themeStyle.gridTileImage,
      );
    } else {
      List<GridTile> tiles = [];
      for (int i = 0; i < _allUri.length - 1; i++) {
        File file = File.fromUri(Uri.parse(_allUri[i]));
        var tile = _buildTilePost(file, i);
        tiles.add(tile);
      }
      setState(() {
        themeStyle.gridTileImage = tiles;
      });
      return GridView.count(
        addAutomaticKeepAlives: true,
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 5.0,
        crossAxisSpacing: 5.0,
        shrinkWrap: true,
        children: tiles,
      );
    }
  }

  _buildTilePost(File file, int i) {
    final targetPath = _dir.absolute.path + "/temp$i.jpg";
    return GridTile(
      child: FutureBuilder(
          future: _compressAndGetFile(file, targetPath),
          builder: (context, snapshot) {
            return snapshot.hasData
                ? InkWell(
                  child: Hero(
                    tag: "image$i",
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        child: Image.file(
                          snapshot.data,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewPhotoScreen(fileImage: snapshot.data, tag: "image$i",))),
                )
                : Container();
          }),
    );
  }

  Future<File> _compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 20,
      rotate: 0,
    );
    return result;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
