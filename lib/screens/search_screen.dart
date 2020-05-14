import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram_v2/animations/bouncy_page_route.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/profile_screen.dart';
import 'package:instagram_v2/services/database_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/pickup_layout.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  Future<QuerySnapshot> _users;
  var themeStyle;

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
            ? Center(
                child: Text(
                  'Search for a user',
                  style: TextStyle(color: themeStyle.primaryTextColor),
                ),
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
