import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/models.dart';
import '../utils/app_colors.dart';
import 'safe_network_image.dart';
import '../services/auth_service.dart';

class ReviewTile extends StatelessWidget {
  final Review review;
  final AuthService _authService = AuthService();

  ReviewTile({super.key, required this.review});

  /// Convert relative storage paths to full URLs with cache-busting
  String _getAvatarUrl(String avatarPath) {
    if (avatarPath.isEmpty) {
      debugPrint('⚠️  Review Avatar: Empty path');
      return '';
    }

    // Already a full URL
    if (avatarPath.startsWith('http')) {
      final url = '$avatarPath?t=${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('✅ Review Avatar (full URL): $url');
      return url;
    }

    // Relative path - prepend storage base URL
    if (avatarPath.startsWith('/')) {
      final url =
          '${_authService.storageBaseUrl}$avatarPath?t=${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('✅ Review Avatar (relative /): $url');
      return url;
    }

    // Path without leading slash - add it
    final url =
        '${_authService.storageBaseUrl}/$avatarPath?t=${DateTime.now().millisecondsSinceEpoch}';
    debugPrint('✅ Review Avatar (relative): $url');
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: SafeNetworkImage(
                  url: _getAvatarUrl(review.userAvatar),
                  width: 44,
                  height: 44,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(review.createdAt),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            // Rating badge for the specific review
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    review.rating.toString(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          review.comment,
          style: TextStyle(color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }
}
