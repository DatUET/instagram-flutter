import 'package:flutter/material.dart';
import 'package:instagram_v2/animations/fadeanimationdown.dart';
import 'package:instagram_v2/models/user_data.dart';
import 'package:instagram_v2/screens/login_screen.dart';
import 'package:instagram_v2/screens/splash_screen.dart';
import 'package:instagram_v2/screens/success_screen.dart';
import 'package:instagram_v2/services/auth_service.dart';
import 'package:instagram_v2/utilities/constants.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  static final String id = 'signup_screen';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKeyName = GlobalKey<FormState>();
  final _formKeyEmail = GlobalKey<FormState>();
  final _formKeyPass = GlobalKey<FormState>();
  String _name, _email, _password;
  bool _isLoading = false,
      _isSccuess = true,
      _isValid = false,
      _isExistEmail = false;
  var themeStyle;
  FocusNode _focusEmailInput = FocusNode();
  TextEditingController _emailInputController = TextEditingController();
  bool _hidePassword = true;

  _submit() async {
    if (_formKeyName.currentState.validate() &&
        _formKeyEmail.currentState.validate() &&
        _formKeyPass.currentState.validate()) {
      setState(() {
        _isLoading = true;
        _isValid = true;
      });
      _formKeyName.currentState.save();
      _formKeyEmail.currentState.save();
      _formKeyPass.currentState.save();
      // Logging in the user w/ Firebase
      bool isSccuess =
          await AuthService.signUpUser(context, _name, _email, _password);
      setState(() {
        _isLoading = false;
        _isSccuess = isSccuess;
      });
      if (isSccuess) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => SuccessScreen(
                      type: 0,
                      email: _email,
                    )));
      }
    }
  }

  _okError() {
    setState(() {
      _isValid = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusEmailInput.addListener(_onFocusChange);
  }

  void _onFocusChange() async {
    if (!_focusEmailInput.hasFocus) {
      _isExistEmail =
          await AuthService.checkExistEmail(_emailInputController.text);
      _formKeyEmail.currentState.validate();
    }
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
                                color: mainColor,
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
                                borderRadius: BorderRadius.circular(12),
                                color: themeStyle.typeMessageBoxColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: mainColor.withOpacity(.13),
                                    blurRadius: 15,
                                    offset: Offset(0, 10),
                                  )
                                ]),
                            child: Form(
                              key: _formKeyName,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 15.0,
                                  right: 15,
                                  bottom: 3.0,
                                ),
                                child: TextFormField(
                                  cursorColor: mainColor,
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(
                                      color: themeStyle.primaryTextColor),
                                  decoration: InputDecoration(
                                    labelText: 'Name',
                                    labelStyle: TextStyle(
                                        color: themeStyle.primaryTextColor),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: mainColor)),
                                  ),
                                  validator: (input) => input.trim().isEmpty
                                      ? 'Please enter a valid name'
                                      : null,
                                  onSaved: (input) => _name = input,
                                ),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                          1.8,
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: themeStyle.typeMessageBoxColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: mainColor.withOpacity(.13),
                                    blurRadius: 15,
                                    offset: Offset(0, 10),
                                  )
                                ]),
                            child: Form(
                              key: _formKeyEmail,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 15.0,
                                  right: 15,
                                  bottom: 3.0,
                                ),
                                child: TextFormField(
                                  cursorColor: mainColor,
                                  controller: _emailInputController,
                                  focusNode: _focusEmailInput,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(
                                      color: themeStyle.primaryTextColor),
                                  decoration: InputDecoration(
                                    labelText: 'Email',
                                    labelStyle: TextStyle(
                                        color: themeStyle.primaryTextColor),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: mainColor)),
                                  ),
                                  validator: (input) => !input.contains('@')
                                      ? 'Please enter a valid email'
                                      : _isExistEmail
                                          ? 'This email is being used'
                                          : null,
                                  onSaved: (input) => _email = input,
                                ),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      FadeAnimation(
                          1.8,
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: themeStyle.typeMessageBoxColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: mainColor.withOpacity(.13),
                                    blurRadius: 15,
                                    offset: Offset(0, 10),
                                  )
                                ]),
                            child: Form(
                              key: _formKeyPass,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 15.0,
                                  right: 15,
                                  bottom: 3.0,
                                ),
                                child: TextFormField(
                                  cursorColor: mainColor,
                                  style: TextStyle(
                                      color: themeStyle.primaryTextColor),
                                  decoration: InputDecoration(
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                          color: themeStyle.primaryTextColor),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: mainColor)),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _hidePassword = !_hidePassword;
                                          });
                                        },
                                        child: Icon(
                                          _hidePassword
                                              ? OMIcons.visibility
                                              : OMIcons.visibilityOff,
                                          color: themeStyle.primaryIconColor,
                                        ),
                                      )),
                                  validator: (input) => input.length < 6
                                      ? 'Must be at least 6 characters'
                                      : null,
                                  onSaved: (input) => _password = input,
                                  obscureText: _hidePassword,
                                ),
                              ),
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
                                mainColor.withOpacity(.8),
                                mainColor.withOpacity(.4),
                              ]),
                              boxShadow: [
                                BoxShadow(
                                    color: mainColor.withOpacity(.4),
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
                                mainColor.withOpacity(.4),
                                mainColor.withOpacity(.8),
                              ]),
                              boxShadow: [
                                BoxShadow(
                                    color: mainColor.withOpacity(.4),
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
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          mainColor),
                                    ),
                                    SizedBox(
                                      height: 35,
                                    ),
                                    Center(
                                        child: Text(
                                      'Registing!\n Please wait...',
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
                                    ? Container()
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
                                                  gradient:
                                                      LinearGradient(colors: [
                                                    Color.fromRGBO(
                                                        143, 148, 251, 1),
                                                    Color.fromRGBO(
                                                        143, 148, 251, .6),
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
                        ),
                )
              : Container(),
        ],
      ),
    );
  }
}
