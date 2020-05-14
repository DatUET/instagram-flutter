import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PhotoService {
  static Future<File> getImageEdited(String imagePath) async {
    File imageFileEdited;
    MethodChannel platform = MethodChannel('photogram');
    try {
      String temp =
          await platform.invokeMethod('edit photo', {'arg': imagePath});
      print("uri: $temp");
      imageFileEdited = File(temp);
    } catch (e) {
      print(e);
    }
    return imageFileEdited;
  }

  static Future<void> downloadImage(String url, bool isDialog,
      {BuildContext context}) async {
    Dio dio = Dio();
    try {
      var timeNow = DateTime.now().millisecondsSinceEpoch;
      if (isDialog) {
        Navigator.pop(context);
      }
      await dio
          .download(url, "/storage/emulated/0/DCIM/Camera/IMG_$timeNow.jpg")
          .whenComplete(() => Fluttertoast.showToast(
                msg: 'Image Saved!',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                fontSize: 16,
              ));
    } catch (e) {
      print(e.toString());
    }
  }
}
