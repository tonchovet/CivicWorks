import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../models/social_post.dart';
import '../models/budget_proposal.dart';

class ApiService extends ChangeNotifier {
  User? _currentUser;
  List<Project> _projects = [];
  List<Project> get projects => _projects;

  static String get baseUrl => kIsWeb ? 'http://localhost:8080/api/works' : 'http://10.0.2.2:8080/api/works';

  void updateAuth(User? user) {
    _currentUser = user;
    if(_currentUser != null) fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _projects = data.map((json) => Project.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) { print(e); }
  }
  
  Future<List<Project>> fetchCompanyProjects(int companyId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/my-proposals?userId=$companyId'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Project.fromJson(json)).toList();
      }
    } catch (e) { print(e); }
    return [];
  }

  Future<String> voteBudgetProposal(int proposalId) async {
    if (_currentUser == null) return "Login requerido";
    try {
      final res = await http.post(Uri.parse('$baseUrl/vote-proposal?userId=${_currentUser!.id}&proposalId=$proposalId'));
      if(res.statusCode==200) fetchProjects();
      return res.body; 
    } catch (e) { return "Error: $e"; }
  }

  Future<List<SocialPost>> getPosts(int projectId, String channel) async {
    final res = await http.get(Uri.parse('$baseUrl/$projectId/posts?channel=$channel'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => SocialPost.fromJson(e)).toList();
    }
    return [];
  }
  
  Future<BudgetProposal?> getProposalDetails(int proposalId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/proposal/$proposalId'));
      if (res.statusCode == 200) return BudgetProposal.fromJson(jsonDecode(res.body));
    } catch(e) { print(e); }
    return null;
  }
  
  Future<String> finishWork(int projectId) async {
     try {
       final res = await http.post(Uri.parse('$baseUrl/$projectId/finish?companyId=${_currentUser!.id}'));
       fetchProjects();
       return res.body;
     } catch(e) { return "Error: $e"; }
  }
  
  Future<String> validateWork(int projectId, bool positive) async {
     try {
       final res = await http.post(Uri.parse('$baseUrl/$projectId/validate?userId=${_currentUser!.id}&positive=$positive'));
       fetchProjects();
       return res.body;
     } catch(e) { return "Error: $e"; }
  }

  // Updated to support rich media post structure
  Future<void> sendPost(int projectId, String content, String channel, {
    String? budgetAmount,
    String? documentUrl,
    String? audioUrl,
    String? mediaType
  }) async {
    if (_currentUser == null) return;
    final body = {
        'projectId': projectId,
        'authorId': _currentUser!.id,
        'authorName': _currentUser!.fullName,
        'content': content,
        'channel': channel,
    };
    if(budgetAmount != null) body['budgetAmount'] = budgetAmount;
    if(documentUrl != null) body['documentUrl'] = documentUrl;
    if(audioUrl != null) body['audioUrl'] = audioUrl;
    if(mediaType != null) body['mediaType'] = mediaType;
    
    await http.post(
      Uri.parse('$baseUrl/$projectId/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body)
    );
  }
  
  Future<void> proposeProject(Map<String, dynamic> data) async {
    if (_currentUser != null) {
      data['proposerId'] = _currentUser!.id;
    }
    await http.post(
      Uri.parse('$baseUrl/propose'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data)
    );
    fetchProjects();
  }
}
