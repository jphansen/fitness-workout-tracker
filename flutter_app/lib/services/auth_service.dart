import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl = 'https://fitness.asvig.com';
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  
  final http.Client client;
  final FlutterSecureStorage storage;
  
  String? _token;
  String? _username;
  
  AuthService({
    http.Client? client,
    FlutterSecureStorage? storage,
  }) : 
    client = client ?? http.Client(),
    storage = storage ?? const FlutterSecureStorage();
  
  Future<void> init() async {
    // Load token and username from secure storage
    _token = await storage.read(key: _tokenKey);
    _username = await storage.read(key: _usernameKey);
  }
  
  Future<Map<String, String>> getAuthHeaders() async {
    if (_token == null) {
      await init();
    }
    
    if (_token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };
    }
    
    return {'Content-Type': 'application/json'};
  }
  
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    String? email,
    String? fullName,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'email': email,
        'full_name': fullName,
      }),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Registration failed: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['access_token'];
      _username = username;
      
      // Save to secure storage
      await storage.write(key: _tokenKey, value: _token);
      await storage.write(key: _usernameKey, value: _username);
      
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Login failed: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> getCurrentUser() async {
    final headers = await getAuthHeaders();
    
    final response = await client.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to get user info: ${response.statusCode}');
    }
  }
  
  Future<Map<String, dynamic>> refreshToken() async {
    final headers = await getAuthHeaders();
    
    final response = await client.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['access_token'];
      
      // Save to secure storage
      await storage.write(key: _tokenKey, value: _token);
      
      return data;
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Token refresh failed: ${response.statusCode}');
    }
  }
  
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final headers = await getAuthHeaders();
    
    final response = await client.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: headers,
      body: json.encode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );
    
    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Password change failed: ${response.statusCode}');
    }
  }
  
  Future<void> logout() async {
    _token = null;
    _username = null;
    
    // Remove from secure storage
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _usernameKey);
  }
  
  bool get isLoggedIn => _token != null;
  String? get token => _token;
  String? get username => _username;
  
  void dispose() {
    client.close();
  }
}
