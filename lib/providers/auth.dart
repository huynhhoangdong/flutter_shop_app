import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/models/http_exception.dart';

class Auth extends ChangeNotifier {
  late String _token = '';
  late DateTime _expireDate = DateTime.now();
  late String _userId = '';
  late Timer? _authTimer = Timer(Duration(seconds: 0), () {});

  static const ENTPOINT = "https://identitytoolkit.googleapis.com/v1";
  static const KEY = "AIzaSyCY52zKouvGFPIwg2u3McNG39TyQK6wZFU";

  bool get isAuth {
    return _token != '';
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return "";
  }

  Future<void> _authentication(
      String email, String password, String urlSegment) async {
    final url = Uri.parse("$ENTPOINT/accounts:$urlSegment?key=$KEY");
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      print(json.decode(response.body));
      print(response.body);

      final responseDate = json.decode(response.body);
      if (responseDate['error'] != null) {
        throw HttpException(responseDate['error']['message']);
      }

      _token = responseDate["idToken"];
      _userId = responseDate["localId"];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseDate["expiresIn"])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryData': _expireDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (e) {
      print(e.toString());
      throw e;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authentication(email, password, "signUp");
  }

  Future<void> login(String email, String password) async {
    return _authentication(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;
    final extractedUserData =
        json.decode(prefs.getString('userData')!) as Map<String, dynamic>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isAfter(DateTime.now())) return false;
    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expireDate = expiryDate;
    notifyListeners();
    _autoLogout();

    return true;
  }

  void logout() async {
    _token = '';
    _userId = '';
    _expireDate = DateTime.now();
    if (_authTimer != null) {
      _authTimer!.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("userData");
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeToLogout = _expireDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToLogout), logout);
  }
}
