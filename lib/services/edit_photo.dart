import 'dart:io';

import 'package:flutter/services.dart';

class EditPhoto {
  static Future<File> getImageEdited(String imagePath) async {
    File imageFileEdited;
    MethodChannel platform = MethodChannel('photogram');
    try {
      String temp = await platform.invokeMethod('edit photo', {'arg': imagePath});
      print("uri: $temp");
      imageFileEdited = File(temp);
    } catch (e) {
      print(e);
    }
    return imageFileEdited;
  }
}