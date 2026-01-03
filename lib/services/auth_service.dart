import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _userKey = 'logged_in_user';


  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = json.encode(user);
    await prefs.setString(_userKey, userJson);
  }

  
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);
    
    if (userJson == null) {
      return null;
    }
    
    Map<String, dynamic> user = json.decode(userJson);
    return user;
  }

 
  static Future<int?> getCurrentUserId() async {
    Map<String, dynamic>? user = await getCurrentUser();
    
    if (user == null) {
      return null;
    }
    
    int userId = user['id'];
    return userId;
  }

  
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasUser = prefs.containsKey(_userKey);
    return hasUser;
  }

 
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}

