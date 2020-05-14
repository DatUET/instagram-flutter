import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_v2/models/post_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/services/location.dart';
import 'package:instagram_v2/services/storage_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  final File imagePost;
  final bool haveScaffold;

  CreatePostScreen({this.imagePost, this.haveScaffold});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File _image;
  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  String _caption = '';
  bool _isLoading = false;
  var themeStyle;

  Address _address;

  Map<String, double> _currentLocation = Map();

  _showSelectImageDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Add Photo'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Take Photo'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            CupertinoActionSheetAction(
              child: Text('Choose From Gallery'),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  _androidDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: themeStyle.primaryBackgroundColor,
          title: Text(
            'Add Photo',
            style: TextStyle(color: themeStyle.primaryTextColor),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                'Take Photo',
                style: TextStyle(color: themeStyle.primaryTextColor),
              ),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            SimpleDialogOption(
              child: Text(
                'Choose From Gallery',
                style: TextStyle(color: themeStyle.primaryTextColor),
              ),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
            SimpleDialogOption(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  _handleImage(ImageSource source) async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: source);
    if (imageFile != null) {
      imageFile = await _cropImage(imageFile);
      setState(() {
        _image = imageFile;
      });
    }
  }

  _cropImage(File imageFile) async {
    File croppedImage = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
    );
    return croppedImage;
  }

  _submit() async {
    if (!_isLoading && _image != null && _caption.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      // Create post
      String imageUrl = await StorageService.uploadPost(_image);
      Post post = Post(
        imageUrl: imageUrl,
        caption: _caption,
        likeCount: 0,
        authorId: Provider.of<UserData>(context).currentUserId,
        timestamp: Timestamp.fromDate(DateTime.now()),
        location: _locationController.text,
      );
      DatabaseService.createPost(post);

      // Reset data
      _captionController.clear();

      setState(() {
        _caption = '';
        _image = null;
        _isLoading = false;
      });
    }
  }

  _initPlatformState() async {
    Address first = await getUserLocation();
    setState(() {
      _address = first;
    });
  }

  buildLocationButton(String locationName) {
    if (locationName != null ?? locationName.isNotEmpty) {
      return InkWell(
        onTap: () {
          _locationController.text = locationName;
        },
        child: Center(
          child: Container(
            //width: 100.0,
            height: 30.0,
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            margin: EdgeInsets.only(right: 3.0, left: 3.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: Text(
                locationName,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _currentLocation['latitude'] = 0.0;
    _currentLocation['longitude'] = 0.0;
    _initPlatformState();
    _image = widget.imagePost;
  }

  _buildBodyScreen(double height, double width) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              color: themeStyle.primaryBackgroundColor,
              height: height,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: _showSelectImageDialog,
                    child: Container(
                      height: width,
                      width: width,
                      color: themeStyle.typeMessageBoxColor,
                      child: _image == null
                          ? Icon(
                              Icons.add_a_photo,
                              color: themeStyle.primaryIconColor,
                              size: 150.0,
                            )
                          : Image(
                              image: FileImage(_image),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.0),
                    child: TextField(
                      cursorColor: mainColor,
                      controller: _captionController,
                      style: TextStyle(
                          fontSize: 18.0, color: themeStyle.primaryTextColor),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: themeStyle.primaryBackgroundColor,
                        labelText: 'Caption',
                        labelStyle:
                            TextStyle(color: themeStyle.primaryTextColor),
                          focusedBorder:
                          UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color:
                                  mainColor))
                      ),
                      onChanged: (input) => _caption = input,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.pin_drop,
                      color: themeStyle.primaryIconColor,
                    ),
                    title: Container(
                      width: 250.0,
                      child: TextField(
                        controller: _locationController,
                        style: TextStyle(color: themeStyle.primaryTextColor),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: themeStyle.primaryBackgroundColor,
                            hintText: "Where was this photo taken?",
                            hintStyle:
                                TextStyle(color: themeStyle.primaryTextColor),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  (_address == null)
                      ? Container()
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.only(right: 5.0, left: 5.0),
                          child: Row(
                            children: <Widget>[
                              buildLocationButton(_address.featureName),
                              buildLocationButton(_address.subLocality),
                              buildLocationButton(_address.locality),
                              buildLocationButton(_address.subAdminArea),
                              buildLocationButton(_address.adminArea),
                              buildLocationButton(_address.countryName),
                            ],
                          ),
                        ),
                  (_address == null) ? Container() : Divider(),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 60),
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(colors: [
                            mainColor.withOpacity(.6),
                            mainColor.withOpacity(1),
                          ]),
                          boxShadow: [
                            BoxShadow(
                                color: mainColor.withOpacity(.4),
                                blurRadius: 20,
                                offset: Offset(0, 10))
                          ]),
                      child: FlatButton(
                        onPressed: () => _submit(),
                        child: Center(
                          child: Text(
                            'Post',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ))
                ],
              ),
            ),
          ),
          _isLoading
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.5),
                  ),
                  child: Center(
                    child: Container(
                      height: 180,
                      width: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: themeStyle.primaryBackgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, bottom: 15, top: 15),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(mainColor),
                            ),
                            SizedBox(
                              height: 35,
                            ),
                            Center(
                                child: Text(
                              'Uploading!\n Please wait....',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: themeStyle.primaryTextColor),
                            ))
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    themeStyle = Provider.of<UserData>(context);
    return widget.haveScaffold
        ? Scaffold(
            backgroundColor: themeStyle.primaryBackgroundColor,
            appBar: AppBar(
              iconTheme: IconThemeData(color: themeStyle.primaryIconColor),
              title: Text(
                'Create New Post',
                style: TextStyle(color: themeStyle.primaryTextColor),
              ),
              backgroundColor: themeStyle.primaryBackgroundColor,
            ),
            body: _buildBodyScreen(height, width),
          )
        : _buildBodyScreen(height, width);
  }
}
