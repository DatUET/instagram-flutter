import 'package:flutter/material.dart';
import 'package:instagram_v2/animations/fadeanimationdown.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/signup_screen.dart';
import 'package:instagram_v2/services/auth_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static final String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyForgotPass = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _email, _password, _emailForgot;
  bool _isLoading = false, _isValid = false;
  String _strLogin;
  var themeStyle;
  bool isSentPasswordReset = false;
  bool _hidePassword = true;

  _submit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Logging in the user w/ Firebase
      setState(() {
        _isValid = true;
        _isLoading = true;
      });
      String strLogin = await AuthService.login(_email, _password, context);
      setState(() {
        _isLoading = false;
        _strLogin = strLogin;
      });
    }
  }

  _sendEmailForgotPass(BuildContext context) async {
    if (_formKeyForgotPass.currentState.validate()) {
      _formKeyForgotPass.currentState.save();
      bool isSent = await AuthService.sendEmailResetPassword(_emailForgot);
      if (isSent) {
        setState(() {
          Navigator.pop(context);
          _scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text('Please check email $_emailForgot.'),
            action: SnackBarAction(label: 'Ok', onPressed: () {}),
          ));
        });
      }
    }
  }

  _okError() {
    setState(() {
      _isValid = false;
    });
  }

  _showForgotPass(BuildContext context) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 100),
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                  color: themeStyle.primaryBackgroundColor,
                  borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20))),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 32.0),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            Color.fromRGBO(143, 148, 251, 1),
                            Color.fromRGBO(143, 148, 251, .6),
                          ]).createShader(bounds),
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, left: 16.0, top: 32.0),
                    child: Text('Enter your registered email address',
                        style: TextStyle(
                            color: themeStyle.primaryTextColor, fontSize: 18)),
                  ),
                  Form(
                    key: _formKeyForgotPass,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 30.0,
                        vertical: 10.0,
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: themeStyle.primaryTextColor),
                        decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle:
                                TextStyle(color: themeStyle.primaryTextColor)),
                        validator: (input) => !input.contains('@')
                            ? 'Please enter a valid email'
                            : null,
                        onSaved: (input) => _emailForgot = input,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  isSentPasswordReset
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Text(
                              'We sent email to reset password. Please check email $_emailForgot'),
                        )
                      : Container(),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 60),
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(colors: [
                          Color.fromRGBO(143, 148, 251, 1),
                          Color.fromRGBO(143, 148, 251, .6),
                        ]),
                        boxShadow: [
                          BoxShadow(
                              color: Color.fromRGBO(143, 148, 251, .4),
                              blurRadius: 20,
                              offset: Offset(0, 10))
                        ]),
                    child: FlatButton(
                      onPressed: () => _sendEmailForgotPass(context),
                      child: Center(
                        child: Text(
                          'Send email',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: themeStyle.primaryBackgroundColor,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 330,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/background.png'),
                            fit: BoxFit.fill)),
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 30,
                          width: 80,
                          height: 200,
                          child: FadeAnimation(
                            1,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-1.png'))),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 140,
                          width: 80,
                          height: 150,
                          child: FadeAnimation(
                            1.3,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/light-2.png'))),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 40,
                          top: 40,
                          width: 80,
                          height: 200,
                          child: FadeAnimation(
                            1.5,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/clock.png'))),
                            ),
                          ),
                        ),
                        Positioned(
                            child: FadeAnimation(
                          1.6,
                          Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 30, right: 30, bottom: 30, top: 0),
                    child: Column(
                      children: <Widget>[
                        FadeAnimation(
                          1.8,
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: themeStyle.typeMessageBoxColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                      color: mainColor.withOpacity(.2),
                                      blurRadius: 20,
                                      offset: Offset(0, 10))
                                ]),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(8),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 15.0,
                                              vertical: 10.0,
                                            ),
                                            child: TextFormField(
                                              cursorColor: mainColor,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              style: TextStyle(
                                                  color: themeStyle
                                                      .primaryTextColor),
                                              decoration: InputDecoration(
                                                labelText: 'Email',
                                                labelStyle: TextStyle(
                                                    color: themeStyle
                                                        .primaryTextColor),
                                                focusedBorder:
                                                    UnderlineInputBorder(
                                                        borderSide: BorderSide(
                                                            color: mainColor)),
                                              ),
                                              validator: (input) => !input
                                                      .contains('@')
                                                  ? 'Please enter a valid email'
                                                  : null,
                                              onSaved: (input) =>
                                                  _email = input,
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 15.0,
                                              vertical: 10.0,
                                            ),
                                            child: TextFormField(
                                              cursorColor: mainColor,
                                              keyboardType:
                                                  TextInputType.visiblePassword,
                                              style: TextStyle(
                                                  color: themeStyle
                                                      .primaryTextColor),
                                              decoration: InputDecoration(
                                                  labelText: 'Password',
                                                  labelStyle: TextStyle(
                                                      color: themeStyle
                                                          .primaryTextColor),
                                                  focusedBorder:
                                                      UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                              color:
                                                                  mainColor)),
                                                  suffixIcon: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _hidePassword =
                                                            !_hidePassword;
                                                      });
                                                    },
                                                    child: Icon(
                                                      _hidePassword
                                                          ? OMIcons.visibility
                                                          : OMIcons
                                                              .visibilityOff,
                                                      color: themeStyle
                                                          .primaryIconColor,
                                                    ),
                                                  )),
                                              validator: (input) => input
                                                          .length <
                                                      6
                                                  ? 'Must be at least 6 characters'
                                                  : null,
                                              onSaved: (input) =>
                                                  _password = input,
                                              obscureText: _hidePassword,
                                            ),
                                          ),
                                        ]),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FadeAnimation(
                            2,
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => _showForgotPass(context),
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                      color: mainColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        FadeAnimation(
                          2.2,
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 60),
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  mainColor.withOpacity(1),
                                  mainColor.withOpacity(.6)
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
                                  'Login',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        FadeAnimation(
                          2.4,
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 60),
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
                              onPressed: () => Navigator.pushReplacementNamed(
                                  context, SignupScreen.id),
                              child: Center(
                                child: Text(
                                  'Go to Sign up',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FadeAnimation(
                          2.6,
                          Text(
                            'Or',
                            style:
                                TextStyle(color: themeStyle.primaryTextColor),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        FadeAnimation(
                          2.8,
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 60),
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey)),
                            child: FlatButton(
                              onPressed: () => AuthService.loginGoogle(context),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/google.png'))),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      'Sign In Google',
                                      style: TextStyle(
                                          color: themeStyle.primaryTextColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          _isValid
              ? Container(
                  child: _isLoading
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
                                  color: themeStyle.primaryBackgroundColor),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20, bottom: 15, top: 15),
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
                                      'Log in!\n Please wait...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: themeStyle.primaryTextColor),
                                    ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.5),
                          ),
                          child: Center(
                            child: _strLogin == 'done'
                                ? Container()
                                : Container(
                                    height: 180,
                                    width: 180,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color:
                                            themeStyle.primaryBackgroundColor),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 20.0,
                                          right: 20,
                                          bottom: 15,
                                          top: 15),
                                      child: Column(
                                        children: <Widget>[
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Center(
                                              child: Text(
                                            _strLogin,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 17),
                                          )),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Center(
                                            child: Container(
                                              height: 30,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  gradient:
                                                      LinearGradient(colors: [
                                                    mainColor,
                                                    mainColor.withOpacity(.6),
                                                  ]),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: mainColor
                                                            .withOpacity(.4),
                                                        blurRadius: 20,
                                                        offset: Offset(0, 10))
                                                  ]),
                                              child: FlatButton(
                                                onPressed: () => _okError(),
                                                child: Center(
                                                  child: Text(
                                                    'OK',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                )
              : Container(),
        ],
      ),
    );
  }
}
