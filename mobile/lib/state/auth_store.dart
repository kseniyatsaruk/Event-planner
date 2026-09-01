import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_info.dart';

/// Holds the current session. The JWT is kept in secure storage so it
/// survives app restarts without living in plain SharedPreferences.
class AuthStore extends ChangeNotifier {
  AuthStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  static const _tokenKey = 'eventplanner_auth_token';

  String? token;
  UserInfo? user;

  Future<void> init() async {
    token = await _storage.read(key: _tokenKey);
  }

  void setUser(UserInfo value) {
    user = value;
    notifyListeners();
  }

  Future<void> setSession(String token, UserInfo user) async {
    this.token = token;
    this.user = user;
    await _storage.write(key: _tokenKey, value: token);
    notifyListeners();
  }

  Future<void> logout() async {
    token = null;
    user = null;
    await _storage.delete(key: _tokenKey);
    notifyListeners();
  }
}
