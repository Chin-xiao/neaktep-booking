import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'https://veteran-abroad-bay-montgomery.trycloudflare.com/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // --- 1. FETCH USER PROFILE (FIXED FOR NAME) ---
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle Laravel wrapping
        if (data is Map) {
          if (data.containsKey('user')) return data['user'];
          if (data.containsKey('data')) return data['data'];
        }
        return data; 
      }
      return null;
    } catch (e) {
      print("Profile Fetch Error: $e");
      return null;
    }
  }

  // --- 2. LOGIN FUNCTION ---
  Future<bool> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String? token = data['access_token'] ?? data['token'];

        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          return true; 
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- 3. REGISTER FUNCTION ---
  Future<bool> registerUser(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password, 
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        String? token = data['access_token'] ?? data['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- 4. LOGOUT FUNCTION ---
  Future<bool> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    if (token != null) {
      await http.post(Uri.parse('$baseUrl/logout'), headers: {'Authorization': 'Bearer $token'});
    }
    await prefs.remove('auth_token');
    return true;
  }
}