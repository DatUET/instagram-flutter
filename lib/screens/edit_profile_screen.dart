import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/change_password_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/services/storage_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/custom_dialog.dart';
import 'package:instagram_v2/widgets/pickup_layout.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  EditProfileScreen({this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File _profileImage;
  String _name = '';
  String _bio = '';
  bool _isLoading = false;
  var themeStyle;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  _handleImageFromGallery() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _profileImage = imageFile;
      });
    }
  }

  _displayProfileImage() {
    // No new profile image
    if (_profileImage == null) {
      // No existing profile image
      if (widget.user.profileImageUrl.isEmpty) {
        // Display placeholder
        return AssetImage('assets/images/user_placeholder.jpg');
      } else {
        // User profile image exists
        return CachedNetworkImageProvider(widget.user.profileImageUrl);
      }
    } else {
      // New profile image
      return FileImage(_profileImage);
    }
  }

  _submit() async {
    if (_formKey.currentState.validate() && !_isLoading) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });

      // Update user in database
      String _profileImageUrl = '';

      if (_profileImage == null) {
        _profileImageUrl = widget.user.profileImageUrl;
      } else {
        _profileImageUrl = await StorageService.uploadUserProfileImage(
          widget.user.profileImageUrl,
          _profileImage,
        );
      }

      User user = User(
        id: widget.user.id,
        name: _name,
        profileImageUrl: _profileImageUrl,
        bio: _bio,
        isActive: widget.user.isActive,
      );
      // Database update
      DatabaseService.updateUser(user);

      Navigator.pop(context);
    }
  }

  _showQRDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: "Your QR Code",
        id: widget.user.id,
        buttonText: "Okay",
        imageUrl: widget.user.profileImageUrl,
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
          backgroundColor: themeStyle.primaryBackgroundColor,
          iconTheme: IconThemeData(color: themeStyle.primaryIconColor),
          title: Text(
            'Edit Profile',
            style: TextStyle(color: themeStyle.primaryTextColor),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            children: <Widget>[
              _isLoading
                  ? LinearProgressIndicator(
                      backgroundColor: Color(0xFFFBBDA9),
                      valueColor: AlwaysStoppedAnimation(mainColor),
                    )
                  : SizedBox.shrink(),
              Padding(
                padding: EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Container(
                            width: 64,
                          ),
                          Container(
                            width: 120.0,
                            height: 120.0,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                border: Border.all(color: mainColor, width: 2),
                                image: DecorationImage(
                                    image: _displayProfileImage(),
                                    fit: BoxFit.cover)),
                          ),
                          Container(
                            height: 64,
                            width: 64,
                            decoration: BoxDecoration(
                                color: Colors.grey, shape: BoxShape.circle),
                            child: IconButton(
                                icon: Icon(
                                  OMIcons.addAPhoto,
                                  size: 32,
                                ),
                                onPressed: _handleImageFromGallery),
                          ),
                        ],
                      ),
                      TextFormField(
                        initialValue: _name,
                        style: TextStyle(
                            fontSize: 18.0, color: themeStyle.primaryTextColor),
                        decoration: InputDecoration(
                            icon: Icon(
                              OMIcons.person,
                              size: 30.0,
                              color: themeStyle.primaryIconColor,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: mainColor)),
                            labelText: 'Name',
                            labelStyle:
                                TextStyle(color: themeStyle.primaryTextColor)),
                        validator: (input) => input.trim().length < 1
                            ? 'Please enter a valid name'
                            : null,
                        onSaved: (input) => _name = input,
                      ),
                      TextFormField(
                        initialValue: _bio,
                        style: TextStyle(
                            fontSize: 18.0, color: themeStyle.primaryTextColor),
                        decoration: InputDecoration(
                            icon: Icon(
                              OMIcons.bookmarkBorder,
                              size: 30.0,
                              color: themeStyle.primaryIconColor,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: mainColor)),
                            labelText: 'Bio',
                            labelStyle:
                                TextStyle(color: themeStyle.primaryTextColor)),
                        validator: (input) => input.trim().length > 150
                            ? 'Please enter a bio less than 150 characters'
                            : null,
                        onSaved: (input) => _bio = input,
                      ),
                      GestureDetector(
                        onTap: _submit,
                        child: Container(
                          margin: EdgeInsets.all(40.0),
                          height: 40.0,
                          width: 250.0,
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
                          child: Center(
                            child: Text(
                              'Save Profile',
                              style: TextStyle(
                                  color: themeStyle.primaryTextColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                color: themeStyle.primaryTextColorLight,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Change Password',
                            style: TextStyle(
                                color: themeStyle.primaryTextColor,
                                fontSize: 18.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              OMIcons.arrowForwardIos,
                              color: themeStyle.primaryIconColor,
                            ),
                          )
                        ],
                      ),
                      onTap: () =>
                          widget.user.type == 'Custom' ? Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChangePassScreen(user: widget.user,)))
                      : Fluttertoast.showToast(msg: "This is Google Account.\nYou can't change password", toastLength: Toast.LENGTH_LONG),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'QR Code',
                            style: TextStyle(
                                color: themeStyle.primaryTextColor,
                                fontSize: 18.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              OMIcons.arrowForwardIos,
                              color: themeStyle.primaryIconColor,
                            ),
                          )
                        ],
                      ),
                      onTap: () =>
                      _showQRDialog()
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Dark Theme',
                          style: TextStyle(
                              color: themeStyle.primaryTextColor, fontSize: 18.0),
                        ),
                        Switch(
                            activeColor: mainColor,
                            value: themeStyle.mode == 1,
                            onChanged: (value) {
                              themeStyle.switchMode();
                            })
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
