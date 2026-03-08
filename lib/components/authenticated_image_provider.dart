import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

/// Custom ImageProvider that sends auth headers for protected storage
class AuthenticatedNetworkImageProvider
    extends ImageProvider<AuthenticatedNetworkImageProvider> {
  final String url;
  final AuthService _authService = AuthService();

  AuthenticatedNetworkImageProvider(this.url);

  @override
  ImageStreamCompleter loadImage(
    AuthenticatedNetworkImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return OneFrameImageStreamCompleter(_loadAsync(key));
  }

  Future<ImageInfo> _loadAsync(AuthenticatedNetworkImageProvider key) async {
    try {
      debugPrint('🔐 Loading authenticated image: $url');

      // Get auth token
      final token = await _authService.getToken();

      // Build headers
      final headers = {
        'Accept': 'image/*',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      debugPrint('🔐 Auth headers: $headers');

      // Fetch image with auth headers
      final response = await http.get(Uri.parse(url), headers: headers);

      debugPrint('🔐 Image response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Image loaded successfully');
        // Decode the image using ui.instantiateImageCodec
        final codec = await ui.instantiateImageCodec(response.bodyBytes);
        final frame = await codec.getNextFrame();
        return ImageInfo(image: frame.image);
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden (403) - Storage access denied. URL: $url');
      } else {
        throw Exception(
          'Failed to load image. Status: ${response.statusCode}. URL: $url',
        );
      }
    } catch (e) {
      debugPrint('❌ Error loading authenticated image: $e');
      throw Exception('Failed to load authenticated image: $e');
    }
  }

  @override
  Future<AuthenticatedNetworkImageProvider> obtainKey(
    ImageConfiguration configuration,
  ) {
    return SynchronousFuture<AuthenticatedNetworkImageProvider>(this);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthenticatedNetworkImageProvider &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}
