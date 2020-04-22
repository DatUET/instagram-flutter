import 'package:flutter/material.dart';
import 'package:instagram_v2/animations/fadeanimationdown.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/login_screen.dart';
import 'package:instagram_v2/screens/splash_screen.dart';
import 'package:instagram_v2/services/auth_service.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  static final String id = 'signup_screen';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name, _email, _password;
  bool _isLoading = false, _isSccuess = true;
  var themeStyle;

  _submit() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      _formKey.currentState.save();
      // Logging in the user w/ Firebase
      bool isSccuess =
          await AuthService.signUpUser(context, _name, _email, _password);
      if (!isSccuess) {
        setState(() {
          _isSccuess = isSccuess;
        });
      }
    }
  }

  _okError() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: themeStyle.primaryBackgroundColor,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: 300,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                          top: -40,
                          height: 300,
                          width: _width,
                          child: FadeAnimation(
                            1,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/background-1.png'),
                                      fit: BoxFit.fill)),
                            ),
                          )),
                      Positioned(
                          height: 300,
                          width: _width + 20,
                          child: FadeAnimation(
                            1.3,
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/background-2.png'),
                                      fit: BoxFit.fill)),
                            ),
                          ))
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: <Widget>[
                      FadeAnimation(
                          1.5,
                          Text(
                            'Sign Up',
                            style: TextStyle(
                                color: Color.fromRGBO(195, 129, 239, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 30),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                          1.8,
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: themeStyle.typeMessageBoxColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(196, 135, 198, .2),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  )
                                ]),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Form(
                                      key: _formKey,
                                      child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 30.0,
                                                vertical: 10.0,
                                              ),
                                              child: TextFormField(
                                                style: TextStyle(
                                                    color: themeStyle
                                                        .primaryTextColor),
                                                decoration: InputDecoration(
                                                    labelText: 'Name',
                                                    labelStyle: TextStyle(
                                                        color: themeStyle
                                                            .primaryTextColor)),
                                                validator: (input) => input
                                                        .trim()
                                                        .isEmpty
                                                    ? 'Please enter a valid name'
                                                    : null,
                                                onSaved: (input) =>
                                                    _name = input,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 30.0,
                                                vertical: 10.0,
                                              ),
                                              child: TextFormField(
                                                style: TextStyle(
                                                    color: themeStyle
                                                        .primaryTextColor),
                                                decoration: InputDecoration(
                                                    labelText: 'Email',
                                                    labelStyle: TextStyle(
                                                        color: themeStyle
                                                            .primaryTextColor)),
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
                                                horizontal: 30.0,
                                                vertical: 10.0,
                                              ),
                                              child: TextFormField(
                                                style: TextStyle(
                                                    color: themeStyle
                                                        .primaryTextColor),
                                                decoration: InputDecoration(
                                                    labelText: 'Password',
                                                    labelStyle: TextStyle(
                                                        color: themeStyle
                                                            .primaryTextColor)),
                                                validator: (input) => input
                                                            .length <
                                                        6
                                                    ? 'Must be at least 6 characters'
                                                    : null,
                                                onSaved: (input) =>
                                                    _password = input,
                                                obscureText: true,
                                              ),
                                            ),
                                          ])),
                                ),
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                        2,
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 60),
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [
                                Color.fromRGBO(195, 129, 239, .8),
                                Color.fromRGBO(195, 129, 239, .4),
                              ]),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(49, 39, 79, .4),
                                    blurRadius: 20,
                                    offset: Offset(0, 10))
                              ]),
                          child: FlatButton(
                            onPressed: () => _submit(),
                            child: Center(
                              child: Text(
                                'Sign Up',
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
                        2.2,
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 60),
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(colors: [
                                Color.fromRGBO(195, 129, 239, .4),
                                Color.fromRGBO(195, 129, 239, .8),
                              ]),
                              boxShadow: [
                                BoxShadow(
                                    color: Color.fromRGBO(49, 39, 79, .4),
                                    blurRadius: 20,
                                    offset: Offset(0, 10))
                              ]),
                          child: FlatButton(
                            onPressed: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => LoginScreen())),
                            child: Center(
                              child: Text(
                                'Back To Login',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          _isLoading
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
                        child: _isSccuess
                            ? Column(
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
                                    'Registing!\n Please wait...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20, color: themeStyle.primaryTextColor),
                                  ))
                                ],
                              )
                            : Column(
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
                                    'Sorry!\nAn error occurred',
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
                                          gradient: LinearGradient(colors: [
                                            Color.fromRGBO(143, 148, 251, 1),
                                            Color.fromRGBO(143, 148, 251, .6),
                                          ]),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Color.fromRGBO(
                                                    143, 148, 251, .4),
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
                )
              : Container(),
        ],
      ),
    );
  }
}
