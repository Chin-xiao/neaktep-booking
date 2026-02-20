import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

// Ensure these paths match your project structure
import '../utils/models.dart';

class HotelService {
  // ✅ Base URL for your Laravel API
  static const String baseUrl = "https://veteran-abroad-bay-montgomery.trycloudflare.com/api";

  /// Helper to generate headers with the current Auth Token from SharedPreferences
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- 1. USER & PROFILE ---

  /// Fetches the authenticated user's profile info
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // Consistently handle Laravel's 'data' wrapper
        return (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
      }
      return null;
    } catch (e) {
      debugPrint("❌ fetchUserProfile Error: $e");
      return null;
    }
  }

  /// ✅ FIXED & COMPLETE: Combined update for Name, Email, and Avatar
  /// Uses POST + Method Spoofing to bypass Laravel PUT limitations with files
  Future<bool> updateUserProfile({
    required String name,
    required String email,
    required String currentPassword,
    File? imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');

      // 1. Must use POST for Multipart file uploads in Laravel even for updates
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/user/update'));

      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
        // Do NOT set Content-Type manually here; MultipartRequest sets it automatically
      });

      // 2. Method Spoofing: Tells Laravel to treat this POST as a PUT request
      request.fields['_method'] = 'PUT';
      
      // 3. Add text fields
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['current_password'] = currentPassword;

      // 4. Add avatar image file if selected
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'avatar', // Matches the $request->file('avatar') in your Laravel Controller
          imageFile.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        debugPrint("✅ Update Success");
        return true;
      } else {
        // Detailed log to help fix errors (e.g., validation or password mismatch)
        debugPrint("❌ Laravel Error Body: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Flutter Exception: $e");
      return false;
    }
  }

  // --- 2. SEARCH & DISCOVERY ---

  /// Robust search with price, rating, and location filters
  Future<List<Hotel>> searchHotels({
    String? query,
    double? minPrice,
    double? maxPrice,
    int? rating,
    List<String>? facilities,
    String? location,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (query != null && query.isNotEmpty) queryParams['search'] = query;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (rating != null) queryParams['rating'] = rating.toString();
      if (location != null && location.isNotEmpty) queryParams['location'] = location;
      if (facilities != null && facilities.isNotEmpty) queryParams['facilities'] = facilities;

      final Uri uri = Uri.parse('$baseUrl/hotels/search').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List list = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : (decoded is List ? decoded : []);
        return list.map((j) => Hotel.fromJson(j)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("❌ searchHotels Error: $e");
      return [];
    }
  }

  /// Metadata for filter UI (locations, facilities)
  Future<SearchPageData?> fetchSearchPageData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search-page'), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
        return SearchPageData.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("❌ fetchSearchPageData Error: $e");
      return null;
    }
  }

  /// Specific facility groups for filter lists
  Future<List<FacilityGroup>> fetchFacilityGroups() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/search-page'), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
        final List? groupsJson = data['facility_groups'] ?? data['facilities'];
        return groupsJson?.map((json) => FacilityGroup.fromJson(json)).toList() ?? [];
      }
      return [];
    } catch (e) {
      debugPrint("❌ fetchFacilityGroups Error: $e");
      return [];
    }
  }

  // --- 3. REVIEWS & RATINGS ---

  Future<List<Review>> fetchReviews({String? hotelId}) async {
    try {
      final url = hotelId != null ? '$baseUrl/hotels/$hotelId/reviews' : '$baseUrl/reviews';
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List? list = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
        return list?.map((j) => Review.fromJson(j)).toList() ?? [];
      }
      return [];
    } catch (e) {
      debugPrint("❌ fetchReviews Error: $e");
      return [];
    }
  }

  Future<RatingSummary?> fetchRatingSummary({String? hotelId}) async {
    try {
      final url = hotelId != null ? '$baseUrl/hotels/$hotelId/rating-summary' : '$baseUrl/rating-summary';
      final response = await http.get(Uri.parse(url), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : decoded;
        return RatingSummary.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("❌ fetchRatingSummary Error: $e");
      return null;
    }
  }

  // --- 4. BOOKINGS ---

  Future<List<Booking>> fetchMyBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookings'), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List? list = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : (decoded is List ? decoded : null);
        return list?.map((json) => Booking.fromJson(json)).toList() ?? [];
      }
      return [];
    } catch (e) {
      debugPrint("❌ fetchMyBookings Error: $e");
      return [];
    }
  }

  Future<int?> createBooking({
    required int hotelId,
    required double totalPrice,
    required String checkIn,
    required String checkOut,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'hotel_id': hotelId,
          'total_price': totalPrice,
          'check_in': checkIn,
          'check_out': checkOut,
          'status': 'pending', 
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // Safely extract ID from data wrapper or root
        return (decoded is Map && decoded.containsKey('data')) ? decoded['data']['id'] : decoded['id'];
      }
      return null;
    } catch (e) {
      debugPrint("❌ createBooking Error: $e");
      return null;
    }
  }

  Future<bool> uploadPaymentReceipt(int bookingId, File imageFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('auth_token');
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/bookings/$bookingId/upload-receipt'));
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      request.files.add(await http.MultipartFile.fromPath('receipt', imageFile.path));
      var response = await http.Response.fromStream(await request.send());
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("❌ uploadPaymentReceipt Error: $e");
      return false;
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/bookings/$bookingId/cancel'), headers: await _getHeaders());
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("❌ cancelBooking Error: $e");
      return false;
    }
  }

  // --- 5. NOTIFICATIONS ---

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/notifications'), headers: await _getHeaders());
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List? list = (decoded is Map && decoded.containsKey('data')) ? decoded['data'] : (decoded is List ? decoded : null);
        return list?.map((n) => Map<String, dynamic>.from(n)).toList() ?? [];
      }
      return [];
    } catch (e) {
      debugPrint("❌ fetchNotifications Error: $e");
      return [];
    }
  }
}