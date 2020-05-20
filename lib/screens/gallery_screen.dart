import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/preview_photo.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class GalleyScreen extends StatefulWidget {
  @override
  _GalleyScreenState createState() => _GalleyScreenState();
}

class _GalleyScreenState extends State<GalleyScreen>
    with AutomaticKeepAliveClientMixin {
  List<Media> _allUri = [];
  Directory _dir;
  var themeStyle;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<void> _getImagePath() async {
    _allUri.clear();
    _refreshController.loadComplete();
    Directory dir = await getTemporaryDirectory();
    final List<MediaCollection> collections =
        await MediaGallery.listMediaCollections(
      mediaTypes: [MediaType.image],
    );
    final MediaPage imagePage = await collections[0].getMedias(
      mediaType: MediaType.image,
    );
    setState(() {
      _allUri = imagePage.items;
      _dir = dir;
      _refreshController.refreshCompleted();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PermissionHandler()
        .checkPermissionStatus(PermissionGroup.storage)
        .then(_updateStatus);
  }

  @override
  void dispose() {
    _clearCache();
    super.dispose();
  }

  _clearCache() async {
    await _dir.delete();
  }

  _updateStatus(PermissionStatus status) {
    if (status == PermissionStatus.granted) {
      if (themeStyle.gridTileImage.length == 0) _getImagePath();
    } else {
      _askPermission();
    }
  }

  _askPermission() {
    PermissionHandler()
        .requestPermissions([PermissionGroup.storage]).then((statuses) {
      final status = statuses[PermissionGroup.storage];
      if (status != PermissionStatus.granted) {
        Fluttertoast.showToast(
            msg: 'Please allow permission!', toastLength: Toast.LENGTH_LONG);
      } else {
        _updateStatus(status);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: themeStyle.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeStyle.primaryBackgroundColor,
        iconTheme: IconThemeData(color: themeStyle.primaryIconColor),
        title: Text(
          'Photogram',
          style: TextStyle(
            color: themeStyle.primaryTextColor,
            fontFamily: 'Billabong',
            fontSize: 35.0,
          ),
        ),
      ),
      body: SmartRefresher(
          controller: _refreshController,
          header: WaterDropMaterialHeader(
            backgroundColor: mainColor,
          ),
          child: _buildGridTile(),
          onRefresh: () => _getImagePath()),
    );
  }

  _buildGridTile() {
    List<GridTile> tiles = [];
    for (int i = 0; i < _allUri.length; i++) {
      if (i < 100) {
        var tile = _buildTilePost(i);
        tiles.add(tile);
      }
    }
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

  _buildTilePost(int i) {
    final targetPath = _dir.absolute.path + "/temp$i.jpg";
    return GridTile(
      child: FutureBuilder(
          future: _compressAndGetFile(targetPath, i),
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
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PreviewPhotoScreen(
                                  fileImage: snapshot.data,
                                  tag: "image$i",
                                ))),
                  )
                : Container();
          }),
    );
  }

  Future<File> _compressAndGetFile(String targetPath, int i) async {
    File file = await _allUri[i].getFile();
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: file.lengthSync() > 1000000
          ? (1000000 / file.lengthSync() * 100).toInt()
          : file.lengthSync() > 300000
              ? (300000 / file.lengthSync() * 100).toInt()
              : 20,
      rotate: 0,
    );
    return result;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
