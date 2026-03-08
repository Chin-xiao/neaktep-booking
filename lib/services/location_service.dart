import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const String _lastLocationKey = 'last_location';
  static const String _lastAddressKey = 'last_address';

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Request location permissions
  Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // User denied permission
        return permission;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // User permanently denied permission
      // You can open app settings here
      await openAppSettings();
      return permission;
    }

    return permission;
  }

  /// Get current position with high accuracy
  Future<Position?> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check permissions
      LocationPermission permission = await requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      // Save to cache
      await _saveLastLocation(position);

      debugPrint(
        'Current position: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e) {
      debugPrint('Error getting current position: $e');
      return null;
    }
  }

  /// Get last known position (faster, less accurate)
  Future<Position?> getLastKnownPosition() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        debugPrint(
          'Last known position: ${position.latitude}, ${position.longitude}',
        );
      }
      return position;
    } catch (e) {
      debugPrint('Error getting last known position: $e');
      return null;
    }
  }

  /// Convert coordinates to address (Reverse Geocoding)
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = _formatAddress(place);

        // Save to cache
        await _saveLastAddress(address);

        debugPrint('Address from coordinates: $address');
        return address;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address from coordinates: $e');
      return null;
    }
  }

  /// Convert address to coordinates (Forward Geocoding)
  Future<List<Location>?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      debugPrint(
        'Coordinates from address "$address": ${locations.length} results',
      );
      return locations;
    } catch (e) {
      debugPrint('Error getting coordinates from address: $e');
      return null;
    }
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng) /
        1000;
  }

  /// Get current location with address
  Future<Map<String, dynamic>?> getCurrentLocationWithAddress() async {
    try {
      Position? position = await getCurrentPosition();
      if (position == null) return null;

      String? address = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'altitude': position.altitude,
        'speed': position.speed,
        'address': address ?? 'Unknown location',
        'timestamp': position.timestamp,
      };
    } catch (e) {
      debugPrint('Error getting current location with address: $e');
      return null;
    }
  }

  /// Get cached location data
  Future<Map<String, dynamic>?> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? locationData = prefs.getString(_lastLocationKey);
      String? addressData = prefs.getString(_lastAddressKey);

      if (locationData != null) {
        Map<String, dynamic> location = {
          'cached': true,
          'address': addressData ?? 'Unknown location',
        };

        // Parse stored location data
        List<String> parts = locationData.split(',');
        if (parts.length >= 2) {
          location['latitude'] = double.tryParse(parts[0]);
          location['longitude'] = double.tryParse(parts[1]);
        }

        return location;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting cached location: $e');
      return null;
    }
  }

  /// Format address from Placemark
  String _formatAddress(Placemark place) {
    List<String> addressParts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }

    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }

    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }

    if (place.country != null && place.country!.isNotEmpty) {
      addressParts.add(place.country!);
    }

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Unknown location';
  }

  /// Save last location to cache
  Future<void> _saveLastLocation(Position position) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String locationData = '${position.latitude},${position.longitude}';
      await prefs.setString(_lastLocationKey, locationData);
    } catch (e) {
      debugPrint('Error saving last location: $e');
    }
  }

  /// Save last address to cache
  Future<void> _saveLastAddress(String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastAddressKey, address);
    } catch (e) {
      debugPrint('Error saving last address: $e');
    }
  }

  /// Clear cached location data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastLocationKey);
      await prefs.remove(_lastAddressKey);
    } catch (e) {
      debugPrint('Error clearing location cache: $e');
    }
  }
}
