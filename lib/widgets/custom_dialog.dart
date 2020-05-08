import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CustomDialog extends StatelessWidget {
  final String title, id, buttonText;
  final String imageUrl;

  CustomDialog({
    @required this.title,
    @required this.id,
    @required this.buttonText,
    this.imageUrl,
  });

  dialogContent(BuildContext context) {
    final themeStyle = Provider.of<UserData>(context);
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 66.0 + 16.0,
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          margin: EdgeInsets.only(top: 66.0),
          decoration: new BoxDecoration(
            color: themeStyle.primaryBackgroundColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  color: themeStyle.primaryTextColor,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              QrImage(
                data: id,
                size: 250,
                foregroundColor: themeStyle.primaryTextColor,
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(
                    buttonText,
                    style: TextStyle(color: themeStyle.primaryTextColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
            width: 120.0,
            height: 120.0,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                border: Border.all(color: mainColor, width: 2),
                image: DecorationImage(
                    image: imageUrl == ''
                        ? AssetImage('assets/images/user_placeholder.jpg')
                        : CachedNetworkImageProvider(imageUrl),
                    fit: BoxFit.cover)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}
