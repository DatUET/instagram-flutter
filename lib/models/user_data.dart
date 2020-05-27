import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserData extends ChangeNotifier {

  String currentUserId;

  int mode;

  List<GridTile> gridTileImage = [];
  bool isLoadingAllImage = false;

  UserData() {
    _getColor();
  }//0 for light and 1 for dark

  Color primaryBackgroundColor;
  Color primaryTextColorDark;
  Color primaryTextColorLight;
  Color primaryTextColor;
  Color primaryIconColor;
  Color typeMessageBoxColor;
  Color primaryMessageBoxColor;
  Color secondaryMessageBoxColor;
  Color primaryMessageTextColor;
  Color secondaryMessageTextColor;

//  Color primaryBackgroundColor = Colors.grey[900];
//  Color primaryTextColorDark = Colors.grey[100];
//  Color primaryTextColorLight = Colors.grey;
//  Color primaryTextColor = Colors.grey[300];
//  Color primaryIconColor = Colors.grey[100];
//  Color typeMessageBoxColor = Colors.grey[800];
  _getColor() async {
    final prefs = await SharedPreferences.getInstance();
    mode = prefs.getInt('mode');
    if (mode == null) {
      mode = 0;
    }
    if (mode == 0) {
      primaryBackgroundColor = Colors.grey[100];
      primaryTextColorDark = Colors.grey[900];
      primaryTextColorLight = Colors.grey;
      primaryTextColor = Colors.grey[800];
      primaryIconColor = Colors.grey[900];
      typeMessageBoxColor = Colors.grey[200];
      primaryMessageBoxColor = mainColor;
      secondaryMessageBoxColor = Colors.grey[300];
      primaryMessageTextColor = Colors.white;
      secondaryMessageTextColor = Colors.grey[800];
    } else {
      primaryBackgroundColor = Colors.grey[900];
      primaryTextColorDark = Colors.grey[100];
      primaryTextColorLight = Colors.grey;
      primaryTextColor = Colors.grey[300];
      primaryIconColor = Colors.grey[100];
      typeMessageBoxColor = Colors.grey[800];
      primaryMessageBoxColor = mainColor;
      secondaryMessageBoxColor = Colors.grey[800];
      primaryMessageTextColor = Colors.white;
      secondaryMessageTextColor = Colors.white;
    }
  }

  switchMode(){

    if(mode == 0){
      //if it is light mode currently switch to dark
      primaryBackgroundColor = Colors.grey[900];
      primaryTextColorDark = Colors.grey[100];
      primaryTextColorLight = Colors.grey;
      primaryTextColor = Colors.grey[300];
      primaryIconColor = Colors.grey[100];
      typeMessageBoxColor = Colors.grey[800];
      primaryMessageBoxColor = mainColor;
      secondaryMessageBoxColor = Colors.grey[800];
      primaryMessageTextColor = Colors.white;
      secondaryMessageTextColor = Colors.white;
      mode = 1;
      _updateMode(mode);
    }
    else{
      //if it is dark mode currently switch to light
      primaryBackgroundColor = Colors.grey[100];
      primaryTextColorDark = Colors.grey[900];
      primaryTextColorLight = Colors.grey;
      primaryTextColor = Colors.grey[800];
      primaryIconColor = Colors.grey[900];
      typeMessageBoxColor = Colors.grey[200];
      primaryMessageBoxColor = mainColor;
      secondaryMessageBoxColor = Colors.grey[300];
      primaryMessageTextColor = Colors.white;
      secondaryMessageTextColor = Colors.grey[800];
      mode = 0;
      _updateMode(mode);
    }
    notifyListeners();
  }

  Future<void> _updateMode(int mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mode', mode);
  }
}