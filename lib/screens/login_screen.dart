import 'package:flutter/material.dart';
import 'package:instagram_v2/animations/fadeanimationdown.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/signup_screen.dart';
import 'package:instagram_v2/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static final String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email, _password;
  bool _isLoading = false, _isSccuess = true;
  var themeStyle;

  _submit(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      // Logging in the user w/ Firebase
      setState(() {
        _isLoading = true;
      });
      bool isSccuess = await AuthService.login(_email, _password, context);
      if(!isSccuess){
        setState(() {
          _isSccuess = isSccuess;
        });
      }
    }
  }

  _okError(){
    setState(() {
      _isLoading = false;
      _isSccuess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    themeStyle = Provider.of<UserData>(context);
    return Scaffold(
      backgroundColor: themeStyle.primaryBackgroundColor,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    height: 350,
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
                        left: 30, right: 30, bottom: 30, top: 10),
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
                                      color: Color.fromRGBO(143, 148, 251, .2),
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
                                              horizontal: 30.0,
                                              vertical: 10.0,
                                            ),
                                            child: TextFormField(
                                              style: TextStyle(color: themeStyle.primaryTextColor),
                                              decoration: InputDecoration(
                                                  labelText: 'Email',
                                              labelStyle: TextStyle(color: themeStyle.primaryTextColor)),
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
                                              style: TextStyle(color: themeStyle.primaryTextColor),
                                              decoration: InputDecoration(
                                                  labelText: 'Password',
                                                  labelStyle: TextStyle(color: themeStyle.primaryTextColor),
                                            ),
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
                                        ]),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        FadeAnimation(
                          2,
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
                          2.2,
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 60),
                            height: 50,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(colors: [
                                  Color.fromRGBO(143, 148, 251, .6),
                                  Color.fromRGBO(143, 148, 251, 1),
                                ]),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromRGBO(143, 148, 251, .4),
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
                          height: 40,
                        ),
                        FadeAnimation(
                            1.5,
                            Text(
                              'Forgot Password?',
                              style: TextStyle(
                                  color: Color.fromRGBO(143, 148, 251, 1),
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  )
                ],
              ),
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
                        padding: const EdgeInsets.only(left: 20.0, right: 20, bottom: 15, top: 15),
                        child: _isSccuess ? Column(
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
                              'Logging in!\n Please wait....',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: themeStyle.primaryTextColor, fontSize: 20),
                            ))
                          ],
                        ) :
                        Column(
                          children: <Widget>[
                            Icon(Icons.error_outline, color: Colors.red, size: 40,),
                            SizedBox(
                              height: 10,
                            ),
                            Center(
                                child: Text(
                                  'Email or Password is not match',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: themeStyle.primaryTextColor, fontSize: 17),
                                )),
                            SizedBox(height: 10,),
                            Center(
                              child: Container(
                                height: 30,
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
                                  onPressed: () => _okError(),
                                  child: Center(
                                    child: Text(
                                      'OK',
                                      style: TextStyle(
                                          color: Colors.white,),
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
