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
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File _image;
  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  String _caption = '';
  bool _isLoading = false;

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
          title: Text('Add Photo'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Take Photo'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            SimpleDialogOption(
              child: Text('Choose From Gallery'),
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
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Create Post',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _submit,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Container(
                height: height,
                child: Column(
                  children: <Widget>[
                    GestureDetector(
                      onTap: _showSelectImageDialog,
                      child: Container(
                        height: width,
                        width: width,
                        color: Colors.grey[300],
                        child: _image == null
                            ? Icon(
                                Icons.add_a_photo,
                                color: Colors.white70,
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
                        controller: _captionController,
                        style: TextStyle(fontSize: 18.0),
                        decoration: InputDecoration(
                          labelText: 'Caption',
                        ),
                        onChanged: (input) => _caption = input,
                      ),
                    ),
                    SizedBox(height: 20,),
                    ListTile(
                      leading: Icon(Icons.pin_drop),
                      title: Container(
                        width: 250.0,
                        child: TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                              hintText: "Where was this photo taken?",
                              border: InputBorder.none),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
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
                      color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 15, top: 15),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 35,
                        ),
                        Center(
                            child: Text(
                              'Uploading!\n Please wait....',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20),
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
      ),
    );
  }
}
