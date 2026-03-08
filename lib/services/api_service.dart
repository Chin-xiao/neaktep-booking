import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/models.dart';

class ApiService {
  // --- ENDPOINTS ---
  // Ensure these match the active tunnels in your terminal
  final String hotelUrl =
      "https://participant-cubic-pierre-judy.trycloudflare.com/api/hotels";
  final String bookingUrl =
      "https://participant-cubic-pierre-judy.trycloudflare.com/api/bookings";

  // --- HELPER: GET AUTH HEADERS ---
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // --- 1. FETCH HOTELS ---
  Future<List<Hotel>> fetchHotels() async {
    try {
      final response = await http
          .get(Uri.parse(hotelUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        List<dynamic> jsonList;
        if (decodedData is Map && decodedData.containsKey('data')) {
          jsonList = decodedData['data'];
        } else if (decodedData is List) {
          jsonList = decodedData;
        } else {
          return [];
        }

        return jsonList
            .map((item) {
              try {
                return Hotel.fromJson(item);
              } catch (e) {
                debugPrint("Error parsing hotel item: $e");
                return null;
              }
            })
            .whereType<Hotel>()
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint("Connection Error (Hotels): $e");
      return [];
    }
  }

  // --- 1.1 FETCH SINGLE HOTEL BY ID ---
  Future<Hotel?> fetchHotelById(String id) async {
    try {
      final response = await http
          .get(Uri.parse("$hotelUrl/$id"))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        if (decodedData is Map && decodedData.containsKey('data')) {
          return Hotel.fromJson(decodedData['data']);
        } else {
          return Hotel.fromJson(decodedData);
        }
      }
      return null;
    } catch (e) {
      debugPrint("Connection Error (Hotel by ID): $e");
      return null;
    }
  }

  // --- 2. FETCH MY BOOKINGS ---
  Future<List<dynamic>> fetchMyBookings() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse(bookingUrl), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);

        if (decodedData is Map && decodedData.containsKey('data')) {
          return decodedData['data'] as List<dynamic>;
        } else if (decodedData is List) {
          return decodedData;
        }
      }
      return [];
    } catch (e) {
      debugPrint("Fetch Bookings Error: $e");
      return [];
    }
  }

  // --- 3. CREATE NEW BOOKING ---
  Future<bool> createBooking({
    required dynamic hotelId,
    required String checkIn,
    required String checkOut,
    required double totalPrice,
  }) async {
    try {
      final headers = await _getHeaders();
      final int parsedId = int.parse(hotelId.toString());

      final response = await http
          .post(
            Uri.parse(bookingUrl),
            headers: headers,
            body: json.encode({
              'hotel_id': parsedId,
              'check_in': checkIn,
              'check_out': checkOut,
              'total_price': totalPrice,
              'status': 'pending', // Default status
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint("Booking Store Error: $e");
      return false;
    }
  }

  // --- 4. UPDATE BOOKING STATUS (Confirm Now) ---
  // This is the new method you need for your "Confirm Now" button
  Future<bool> updateBookingStatus(dynamic bookingId, String newStatus) async {
    try {
      final headers = await _getHeaders();
      final String id = bookingId.toString();

      // We use PUT or POST depending on your Laravel route
      // Here we assume a route like /api/bookings/{id}/status
      final response = await http
          .put(
            Uri.parse("$bookingUrl/$id"),
            headers: headers,
            body: json.encode({
              'status': newStatus, // e.g., 'booked'
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint("Update Status: ${response.statusCode}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Update Status Error: $e");
      return false;
    }
  }

  // --- 5. CANCEL BOOKING ---
  Future<bool> cancelBooking(dynamic bookingId) async {
    try {
      final headers = await _getHeaders();
      final String id = bookingId.toString();

      final response = await http
          .delete(Uri.parse("$bookingUrl/$id"), headers: headers)
          .timeout(const Duration(seconds: 10));

      debugPrint("Cancel Status: ${response.statusCode}");

      // Returns true if successful
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint("Cancel Booking Error: $e");
      return false;
    }
  }
}
