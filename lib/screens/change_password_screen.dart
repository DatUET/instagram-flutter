import 'package:flutter/material.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/models/user_model.dart';
import 'package:instagram_v2/screens/success_screen.dart';
import 'package:instagram_v2/services/auth_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:instagram_v2/widgets/pickup_layout.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class ChangePassScreen extends StatefulWidget {
  final User user;

  ChangePassScreen({this.user});

  @override
  _ChangePassScreenState createState() => _ChangePassScreenState();
}

class _ChangePassScreenState extends State<ChangePassScreen> {
  var themeStyle;
  final _formKeyCurrentPass = GlobalKey<FormState>();
  final _formKeyNewPass = GlobalKey<FormState>();
  final _formKeyConfirmPass = GlobalKey<FormState>();
  bool _hideCurrentPass = true,
      _hideNewPassword = true,
      _hideConfirmNewPassword = true,
      _correctCurrentPass = true;
  FocusNode _focusNodeCurrentPass = FocusNode();
  FocusNode _focusNodeNewPass = FocusNode();
  FocusNode _focusNodeConfirmPass = FocusNode();
  String _newPassword;
  TextEditingController _currentPassController = TextEditingController();
  TextEditingController _newPassController = TextEditingController();
  TextEditingController _confirmPassController = TextEditingController();

  _submit(BuildContext context) async {
    if (_formKeyCurrentPass.currentState.validate() &&
        _formKeyNewPass.currentState.validate() &&
        _formKeyConfirmPass.currentState.validate()) {
      bool isSuccess = await AuthService.updatePassword(_newPassword);
      if (isSuccess) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => SuccessScreen(
                      type: 1,
                    )));
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNodeCurrentPass.addListener(_onFocusCurrentPass);
    _focusNodeNewPass.addListener(_onFocusNewPass);
    _focusNodeConfirmPass.addListener(_onFocusConfirmPass);
  }

  void _onFocusCurrentPass() async {
    if (!_focusNodeCurrentPass.hasFocus) {
      _correctCurrentPass = await AuthService.checkLogin(
          widget.user.email, _currentPassController.text);
      _formKeyCurrentPass.currentState.validate();
      print(_correctCurrentPass);
    }
  }

  void _onFocusNewPass() {
    if (!_focusNodeNewPass.hasFocus) {
      _formKeyNewPass.currentState.validate();
      if (_newPassController.text.length >= 6) {
        _newPassword = _newPassController.text.trim();
      }
    }
  }

  void _onFocusConfirmPass() {
    if (!_focusNodeConfirmPass.hasFocus) {
      _formKeyConfirmPass.currentState.validate();
    }
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: themeStyle.primaryBackgroundColor,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: themeStyle.primaryBackgroundColor,
            iconTheme: IconThemeData(color: themeStyle.primaryIconColor)),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Reset Password',
                  style: TextStyle(
                      color: themeStyle.primaryTextColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 64.0,
                ),
                Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Form(
                    key: _formKeyCurrentPass,
                    child: TextFormField(
                      focusNode: _focusNodeCurrentPass,
                      controller: _currentPassController,
                      cursorColor: mainColor,
                      keyboardType: TextInputType.visiblePassword,
                      style: TextStyle(
                          fontSize: 18, color: themeStyle.primaryTextColor),
                      decoration: InputDecoration(
                          labelText: 'Curent Password',
                          labelStyle:
                              TextStyle(color: themeStyle.primaryTextColor),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: mainColor)),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _hideCurrentPass = !_hideCurrentPass;
                              });
                            },
                            child: Icon(
                              _hideCurrentPass
                                  ? OMIcons.visibility
                                  : OMIcons.visibilityOff,
                              color: themeStyle.primaryIconColor,
                            ),
                          )),
                      validator: (input) =>
                          (input.isNotEmpty && _correctCurrentPass)
                              ? null
                              : 'Invalid password',
                      obscureText: _hideCurrentPass,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Form(
                    key: _formKeyNewPass,
                    child: TextFormField(
                      controller: _newPassController,
                      focusNode: _focusNodeNewPass,
                      cursorColor: mainColor,
                      keyboardType: TextInputType.visiblePassword,
                      style: TextStyle(
                          fontSize: 18, color: themeStyle.primaryTextColor),
                      decoration: InputDecoration(
                          labelText: 'New Password',
                          labelStyle:
                              TextStyle(color: themeStyle.primaryTextColor),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: mainColor)),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _hideNewPassword = !_hideNewPassword;
                              });
                            },
                            child: Icon(
                              _hideNewPassword
                                  ? OMIcons.visibility
                                  : OMIcons.visibilityOff,
                              color: themeStyle.primaryIconColor,
                            ),
                          )),
                      validator: (input) => input.length < 6
                          ? 'Must be at least 6 characters'
                          : null,
                      onSaved: (input) => _newPassword = input,
                      obscureText: _hideNewPassword,
                    ),
                  ),
                  SizedBox(
                    height: 16.0,
                  ),
                  Form(
                    key: _formKeyConfirmPass,
                    child: TextFormField(
                      controller: _confirmPassController,
                      focusNode: _focusNodeConfirmPass,
                      cursorColor: mainColor,
                      keyboardType: TextInputType.visiblePassword,
                      style: TextStyle(
                          fontSize: 18, color: themeStyle.primaryTextColor),
                      decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          labelStyle:
                              TextStyle(color: themeStyle.primaryTextColor),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: mainColor)),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _hideConfirmNewPassword =
                                    !_hideConfirmNewPassword;
                              });
                            },
                            child: Icon(
                              _hideConfirmNewPassword
                                  ? OMIcons.visibility
                                  : OMIcons.visibilityOff,
                              color: themeStyle.primaryIconColor,
                            ),
                          )),
                      validator: (input) => input.length < 6
                          ? 'Must be at least 6 characters'
                          : input != _newPassword
                              ? 'Incorrect password confirmation'
                              : null,
                      obscureText: _hideConfirmNewPassword,
                    ),
                  ),
                ]),
                SizedBox(
                  height: 64.0,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 30),
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
                    onPressed: () => _submit(context),
                    child: Center(
                      child: Text(
                        'Update Password',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
