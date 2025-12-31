import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _userKey = 'logged_in_user';
  static const String _userIdKey = 'user_id';

  
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user));
    await prefs.setInt(_userIdKey, user['id'] as int);
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return json.decode(userJson) as Map<String, dynamic>;
    }
    return null;
  }

  
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }


  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_userIdKey);
  }
}

