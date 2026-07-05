import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'currentUser';

  static Future<bool> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/users.json');
      List<String> users = [];
      if (await file.exists()) {
        String content = await file.readAsString();
        users = List<String>.from(json.decode(content));
      }
      String normalizedEmail = email.trim().toLowerCase();
      String trimmedPassword = password.trim();
      // Check if email already exists
      for (String userJson in users) {
        Map<String, dynamic> user = json.decode(userJson);
        if (user['email'] == normalizedEmail) {
          return false; // User already exists
        }
      }
      Map<String, dynamic> newUser = {
        'name': name,
        'email': normalizedEmail,
        'password': trimmedPassword,
      };
      users.add(json.encode(newUser));
      await file.writeAsString(json.encode(users));
      return true;
    } catch (e) {
      // Fallback to shared_preferences
      try {
        final prefs = await SharedPreferences.getInstance();
        List<String> users = prefs.getStringList(_usersKey) ?? [];
        String normalizedEmail = email.trim().toLowerCase();
        String trimmedPassword = password.trim();
        // Check if email already exists
        for (String userJson in users) {
          Map<String, dynamic> user = json.decode(userJson);
          if (user['email'] == normalizedEmail) {
            return false; // User already exists
          }
        }
        Map<String, dynamic> newUser = {
          'name': name,
          'email': normalizedEmail,
          'password': trimmedPassword,
        };
        users.add(json.encode(newUser));
        await prefs.setStringList(_usersKey, users);
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  static Future<bool> loginUser(String email, String password) async {
    try {
      Directory dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/users.json');
      List<String> users = [];
      if (await file.exists()) {
        String content = await file.readAsString();
        users = List<String>.from(json.decode(content));
      }
      String normalizedEmail = email.trim().toLowerCase();
      String trimmedPassword = password.trim();
      for (String userJson in users) {
        Map<String, dynamic> user = json.decode(userJson);
        if (user['email'] == normalizedEmail &&
            user['password'] == trimmedPassword) {
          // Set current user
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_currentUserKey, userJson);
          return true;
        }
      }
      return false;
    } catch (e) {
      // Fallback to shared_preferences
      try {
        final prefs = await SharedPreferences.getInstance();
        List<String> users = prefs.getStringList(_usersKey) ?? [];
        String normalizedEmail = email.trim().toLowerCase();
        String trimmedPassword = password.trim();
        for (String userJson in users) {
          Map<String, dynamic> user = json.decode(userJson);
          if (user['email'] == normalizedEmail &&
              user['password'] == trimmedPassword) {
            // Set current user
            await prefs.setString(_currentUserKey, userJson);
            return true;
          }
        }
        return false;
      } catch (e) {
        return false;
      }
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString(_currentUserKey);
      if (userJson != null) {
        return json.decode(userJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
    } catch (e) {
      // Ignore
    }
  }
}
