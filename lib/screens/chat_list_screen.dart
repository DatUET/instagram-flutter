import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/message_model.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/chat_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;

  ChatListScreen({this.currentUserId});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Message> _recentChatList = [];
  var themeStyle;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_setUpRecentChat();
  }

  _buildRecentChat(Message message) {
    String chatWithUserId = widget.currentUserId == message.senderUid
        ? message.receiverUid
        : message.senderUid;
    return FutureBuilder(
        future: DatabaseService.getUserWithId(chatWithUserId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          User user = snapshot.data;
          return Container(
            color: themeStyle.primaryBackgroundColor,
            child: ListTile(
              leading: CircleAvatar(
                radius: 26.0,
                backgroundColor: Colors.grey,
                backgroundImage: user.profileImageUrl.isEmpty
                    ? AssetImage('assets/images/user_placeholder.jpg')
                    : CachedNetworkImageProvider(user.profileImageUrl),
              ),
              title: Text(
                '${user.name} - ${DateFormat.yMd().add_jm().format(
                      message.timestamp.toDate(),
                    )}',
                style: TextStyle(
                    color: themeStyle.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0),
              ),
              subtitle: Text('${message.message}',
                  style: TextStyle(
                      color: themeStyle.primaryTextColor,
                      fontWeight: (!message.isSeen &&
                              message.receiverUid == widget.currentUserId)
                          ? FontWeight.bold
                          : FontWeight.normal)),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(
                            currentUserId: widget.currentUserId,
                            chatWithUser: user,
                          ))),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: themeStyle.primaryBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeStyle.primaryBackgroundColor,
        title: Text(
          'Photogram',
          style: TextStyle(
            color: themeStyle.primaryTextColor,
            fontFamily: 'Billabong',
            fontSize: 35.0,
          ),
        ),
      ),
      body: StreamBuilder(
          stream: DatabaseService.getAllRecentChat(widget.currentUserId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            _recentChatList = snapshot.data;
            return Container(
              child: ListView.separated(
                itemCount: _recentChatList.length,
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Divider(color: Colors.grey,),
                  );
                },
                itemBuilder: (BuildContext context, int index) {
                  Message message = _recentChatList[index];
                  return _buildRecentChat(message);
                },
              ),
            );
          }),
    );
  }
}
