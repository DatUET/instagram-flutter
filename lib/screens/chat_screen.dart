import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_v2/models/message_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/services/photo_service.dart';
import 'package:instagram_v2/services/storage_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final User chatWithUser;

  ChatScreen({this.currentUserId, this.chatWithUser});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _messageList = [];
  var themeStyle;
  TextEditingController _textEditingController = TextEditingController();
  ScrollController _listController = ScrollController();
  File _image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_setUpChat();
  }

  _buildTextMessage(Message message, bool isMe) {
    final Align msg = Align(
        alignment: isMe ? Alignment.topRight : Alignment.topLeft,
        child: Padding(
          padding: isMe
              ? EdgeInsets.only(left: 120.0)
              : EdgeInsets.only(right: 120.0),
          child: Container(
            margin: EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
            ),
            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
            //width: MediaQuery.of(context).size.width * 0.75,
            decoration: BoxDecoration(
              color: isMe
                  ? themeStyle.primaryMessageBoxColor
                  : themeStyle.typeMessageBoxColor,
              borderRadius: isMe
                  ? BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      bottomLeft: Radius.circular(15.0),
                    )
                  : BorderRadius.only(
                      topRight: Radius.circular(15.0),
                      bottomRight: Radius.circular(15.0),
                    ),
            ),
            child: InkWell(
              onLongPress: () => _androidShowOptionMessage(message),
              child: Text(
                message.message,
                style: TextStyle(
                  color: themeStyle.primaryTextColorDark,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ));
    if (isMe) {
      return msg;
    }
    return msg;
  }

  _buildImageMessage(Message message, bool isMe) {
    final Align msg = Align(
        alignment: isMe ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
          ),
          width: MediaQuery.of(context).size.width * 0.5,
          //height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: isMe
                ? themeStyle.primaryMessageBoxColor
                : themeStyle.typeMessageBoxColor,
            borderRadius: isMe
                ? BorderRadius.all(
                    Radius.circular(15.0),
                  )
                : BorderRadius.all(
                    Radius.circular(15.0),
                  ),
          ),
          child: InkWell(
            onLongPress: () => _androidShowOptionMessage(message),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              child: CachedNetworkImage(
                imageUrl: message.photoUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ));
    if (isMe) {
      return msg;
    }
    return msg;
  }

  _buildDeleteMessage(Message message, bool isMe) {
    final Align msg = Align(
        alignment: isMe ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: 8.0,
            bottom: 8.0,
          ),
          padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
          //width: MediaQuery.of(context).size.width * 0.75,
          decoration: BoxDecoration(
            color: themeStyle.primaryBackgroundColor,
            border: Border.all(color: themeStyle.primaryTextColorLight),
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                  )
                : BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
          ),
          child: Text(
            message.message,
            style: TextStyle(
              color: themeStyle.primaryTextColorDark,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ));
    if (isMe) {
      return msg;
    }
    return msg;
  }

  _buildMessageComposer() {
    return Container(
      color: themeStyle.primaryBackgroundColor,
      child: Row(
        children: <Widget>[
          Flexible(
            child: Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 15.0),
              decoration: BoxDecoration(
                  color: themeStyle.secondaryMessageBoxColor,
                  borderRadius: BorderRadius.all(Radius.circular(24.0))),
              child: Row(
                children: <Widget>[
                  IconButton(
                      icon: Icon(
                        Icons.add_circle,
                        color: themeStyle.primaryIconColor,
                      ),
                      onPressed: _androidDialog),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(right: 5.0),
                      child: TextField(
                        controller: _textEditingController,
                        style:
                            TextStyle(color: themeStyle.primaryTextColorDark),
                        decoration: InputDecoration.collapsed(
                            hintText: 'Type message...',
                            hintStyle: TextStyle(
                                color: themeStyle.primaryTextColorLight)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.send,
                color: themeStyle.primaryIconColor,
              ),
              onPressed: _sendMessageText),
        ],
      ),
      width: double.infinity,
    );
  }

  _androidShowOptionMessage(Message message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: themeStyle.primaryBackgroundColor,
          title: Text(
            'Option',
            style: TextStyle(color: themeStyle.primaryTextColor),
          ),
          children: <Widget>[
            message.type == 'photo'
                ? SimpleDialogOption(
                    child: Text(
                      'Download Photo',
                      style: TextStyle(color: themeStyle.primaryTextColor),
                    ),
                    onPressed: () => PhotoService.downloadImage(
                        message.photoUrl, true,
                        context: context),
                  )
                : Container(),
            SimpleDialogOption(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.redAccent),
              ),
              onPressed: () {
                Navigator.pop(context);
                if (message.senderUid == widget.currentUserId) {
                  DatabaseService.deleteMessage(
                      message.id, widget.currentUserId, widget.chatWithUser.id);
                } else {
                  Fluttertoast.showToast(
                      msg: 'You can not delete this message',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM);
                }
              },
            ),
          ],
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
      setState(() {
        _image = imageFile;
      });
      await _sendMessageImage();
    }
  }

  Future<void> _sendMessageImage() async {
    if (_image != null) {
      String imageUrl = await StorageService.uploadPost(_image);
      Message message = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderUid: widget.currentUserId,
          receiverUid: widget.chatWithUser.id,
          type: 'photo',
          message: 'Image 📷',
          timestamp: Timestamp.fromDate(DateTime.now()),
          isSeen: false,
          photoUrl: imageUrl);
      bool isSent = await DatabaseService.sendMessage(message);
      if (isSent) {
        setState(() {
          _messageList.add(message);
          _image = null;
        });
      }
    }
  }

  Future<void> _sendMessageText() async {
    if (_textEditingController.text.trim().isNotEmpty) {
      String message = _textEditingController.text;
      _textEditingController.clear();
      Message _messageText = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          senderUid: widget.currentUserId,
          receiverUid: widget.chatWithUser.id,
          type: 'text',
          message: message,
          timestamp: Timestamp.fromDate(DateTime.now()),
          isSeen: false,
          photoUrl: '');
      bool isSent = await DatabaseService.sendMessage(_messageText);
      if (isSent) {
        setState(() {
          _messageList.add(_messageText);
        });
      }
      _listController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: themeStyle.primaryBackgroundColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: themeStyle.primaryIconColor),
        backgroundColor: themeStyle.primaryBackgroundColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12.0)),
                  border: Border.all(
                      width: 1.5,
                      color: widget.chatWithUser.isActive
                          ? mainColor
                          : Colors.grey),
                  image: DecorationImage(
                    image: widget.chatWithUser.profileImageUrl.isEmpty
                        ? AssetImage('assets/images/user_placeholder.jpg')
                        : CachedNetworkImageProvider(
                            widget.chatWithUser.profileImageUrl),
                    fit: BoxFit.cover
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.chatWithUser.name,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  color: themeStyle.primaryTextColor,
                ),
              ),
            ),
          ],
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_horiz),
            iconSize: 30.0,
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder(
                  stream: DatabaseService.getAllMessage(
                      widget.currentUserId, widget.chatWithUser.id),
                  builder: (context, snapshot) {
                    _messageList = snapshot.data;
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (_messageList.length > 0) {
                      if (_messageList[0].receiverUid == widget.currentUserId) {
                        DatabaseService.updateIsSeen(
                            widget.currentUserId, widget.chatWithUser.id);
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: themeStyle.primaryBackgroundColor,
                        ),
                        child: ListView.builder(
                          controller: _listController,
                          reverse: true,
                          padding: EdgeInsets.only(top: 15.0),
                          itemCount: _messageList.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Message message = _messageList[index];
                            final bool isMe =
                                message.senderUid == widget.currentUserId;
                            return message.type == 'text'
                                ? _buildTextMessage(message, isMe)
                                : message.type == 'photo'
                                    ? _buildImageMessage(message, isMe)
                                    : _buildDeleteMessage(message, isMe);
                          },
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          'No Message',
                          style: TextStyle(
                              fontSize: 30, color: themeStyle.primaryTextColor),
                        ),
                      );
                    }
                  }),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }
}
