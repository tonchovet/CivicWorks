import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  static String get baseUrl => kIsWeb ? 'http://localhost:8080/api/auth' : 'http://10.0.2.2:8080/api/auth';

  Future<bool> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password})
      );
      if (res.statusCode == 200) {
        _currentUser = User.fromJson(jsonDecode(res.body));
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }

  Future<bool> register(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data)
      );
      if (res.statusCode == 200) {
        _currentUser = User.fromJson(jsonDecode(res.body));
        notifyListeners();
        return true;
      }
    } catch (e) { print(e); }
    return false;
  }
  
  Future<String> addTeamMember(String email) async {
    if(_currentUser == null) return "Error auth";
    final res = await http.post(Uri.parse('$baseUrl/${_currentUser!.id}/team?email=$email'));
    return res.body;
  }

  Future<List<User>> searchUsers(String query) async {
    if (query.length < 2) return [];
    try {
      final res = await http.get(Uri.parse('$baseUrl/search?query=$query'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => User.fromJson(e)).toList();
      }
    } catch (e) { print(e); }
    return [];
  }
  
  Future<List<User>> getTeamMembers() async {
    if(_currentUser == null) return [];
    try {
      final res = await http.get(Uri.parse('$baseUrl/${_currentUser!.id}/team-details'));
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        return data.map((e) => User.fromJson(e)).toList();
      }
    } catch (e) { print(e); }
    return [];
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
