import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/create_post_screen.dart';
import 'package:instagram_v2/services/photo_service.dart';
import 'package:instagram_v2/widgets/pickup_layout.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

class PreviewPhotoScreen extends StatefulWidget {
  final String titlePhoto;
  final File fileImage;
  final String tag;

  PreviewPhotoScreen({this.titlePhoto, @required this.fileImage, this.tag});
  @override
  _PreviewPhotoScreenState createState() => _PreviewPhotoScreenState();
}

class _PreviewPhotoScreenState extends State<PreviewPhotoScreen> {
  _cropImage(File imageFile) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    return croppedImage;
  }

  @override
  Widget build(BuildContext context) {
    final themeStyle = Provider.of<UserData>(context);
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: themeStyle.primaryBackgroundColor,
        appBar: AppBar(
          iconTheme: IconThemeData(color: themeStyle.primaryIconColor),
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.photo_filter,
                  color: themeStyle.primaryIconColor,
                ),
                onPressed: () async {
                  File imageFile =
                      await PhotoService.getImageEdited(widget.fileImage.path);
                  if (imageFile != null) {
                    imageFile = await _cropImage(imageFile);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => CreatePostScreen(
                                  imagePost: imageFile,
                                )));
                  }
                })
          ],
          backgroundColor: themeStyle.primaryBackgroundColor,
        ),
        body: PhotoView(
          imageProvider: FileImage(widget.fileImage),
          minScale: PhotoViewComputedScale.contained,
          heroAttributes: PhotoViewHeroAttributes(tag: "${widget.tag}"),
        ),
      ),
    );
  }
}
