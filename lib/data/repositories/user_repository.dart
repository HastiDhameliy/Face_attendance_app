import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:face_attendance_app/domain/models/user_model.dart';

class UserRepository {
  static const String _usersKey = 'users';

  Future<List<UserModel>> getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getStringList(_usersKey) ?? [];
    return usersJson.map((json) => UserModel.fromJson(jsonDecode(json))).toList();
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    
    // Check if user with same ID already exists
    final existingUserIndex = users.indexWhere((u) => u.id == user.id);
    if (existingUserIndex != -1) {
      users[existingUserIndex] = user;
    } else {
      users.add(user);
    }

    final usersJson = users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList(_usersKey, usersJson);
  }

  Future<void> deleteUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final users = await getUsers();
    users.removeWhere((user) => user.id == userId);
    
    final usersJson = users.map((user) => jsonEncode(user.toJson())).toList();
    await prefs.setStringList(_usersKey, usersJson);
  }

  Future<UserModel?> getUserById(String userId) async {
    final users = await getUsers();
    try {
      return users.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }
} 