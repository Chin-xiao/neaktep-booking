import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthService {
  final String baseUrl =
      'https://viewed-printers-fax-before.trycloudflare.com/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // --- FCM TOKEN SYNC ---
  Future<void> updateFCMToken() async {
    try {
      final token = await getToken();
      if (token == null) return;

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;

      debugPrint("📱 FCM Token: $fcmToken");

      final response = await http.post(
        Uri.parse('$baseUrl/user/fcm-token'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'fcm_token': fcmToken}),
      );

      debugPrint("✅ FCM Token Update Response: ${response.statusCode}");
    } catch (e) {
      debugPrint("❌ FCM Token Update Error: $e");
    }
  }

  // --- 1. FETCH USER PROFILE (FIXED FOR NAME) ---
  // Expose storage base so UI can resolve relative image paths correctly
  String get storageBaseUrl {
    // replace '/api' with '/storage' to match typical Laravel structure
    if (baseUrl.endsWith('/api')) {
      return baseUrl.replaceFirst('/api', '/storage');
    }
    return baseUrl + '/storage';
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/user?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('📥 getUserProfile Response: $data');

        // Handle Laravel wrapping
        if (data is Map) {
          if (data.containsKey('user')) {
            debugPrint('📤 Returning user data: ${data['user']}');
            return data['user'];
          }
          if (data.containsKey('data')) {
            debugPrint('📤 Returning wrapped data: ${data['data']}');
            return data['data'];
          }
        }
        debugPrint('📤 Returning raw data: $data');
        return data;
      }
      debugPrint('❌ getUserProfile failed: Status ${response.statusCode}');
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
          await updateFCMToken();
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
          await updateFCMToken();
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
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (e) {
        // Even if logout fails, clear local token
      }
    }
    await prefs.remove('auth_token');
    return true;
  }

  // --- 5. FORGOT PASSWORD FUNCTION ---
  Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        body: {'email': email},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
