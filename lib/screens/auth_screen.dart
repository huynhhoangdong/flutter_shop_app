import 'dart:math';

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).canvasColor,
                          // color: Theme.of(context).accentTextTheme.title!.color,
                          fontSize: 40,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  var containerHeight = 260;
  late AnimationController _controller;
  late Animation<Size> _heightAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    // TODO: implement initState
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));

    _heightAnimation = Tween<Size>(
      begin: Size(double.infinity, 260),
      end: Size(double.infinity, 320),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _heightAnimation.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
    _controller.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('An error occured'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Okey'))
              ],
            ));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false)
            .login(_authData['email']!, _authData['password']!);
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false)
            .signup(_authData['email']!, _authData['password']!);
      }
    } on HttpException catch (e) {
      var message = 'Authentication failed';
      var error = e.toString();
      if (error.contains('EMAIL_EXISTS')) {
        message = 'This email address is already in use.';
      } else if (error.contains('INVALID_EMAIL')) {
        message = 'This is not a valid email address';
      } else if (error.contains('WEAK_PASSWORD')) {
        message = 'This password is too weak';
      } else if (error.contains('EMAIL_NOT_FOUND')) {
        message = 'Could not find a user with that email';
      } else if (error.contains('INVALID_PASSWORD')) {
        message = 'Invalid password';
      }
      _showErrorDialog(message);
    } catch (e) {
      const message = 'Could not authentication you. Please try again later!';
      _showErrorDialog(message);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        // height: _authMode == AuthMode.Signup ? 320 : 260,
        height: _heightAnimation.value.height,
        constraints: BoxConstraints(minHeight: _heightAnimation.value.height),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value!;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  FadeTransition(
                    opacity: _opacityAnimation,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                            }
                          : null,
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button!.color,
                  ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}