import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'authenticated_image_provider.dart';

class SafeNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool useAuth;

  const SafeNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.useAuth = true,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      debugPrint('🖼️ SafeNetworkImage: Empty URL provided');
      return Container(
        width: width,
        height: height,
        color: AppColors.divider,
        alignment: Alignment.center,
        child: const Icon(Icons.person, color: AppColors.textMuted),
      );
    }

    debugPrint('🖼️ SafeNetworkImage loading (auth=$useAuth): $url');

    final image = useAuth
        ? Image(
            image: AuthenticatedNetworkImageProvider(url),
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, error, stackTrace) {
              debugPrint('❌ SafeNetworkImage auth error loading $url: $error');
              return Container(
                width: width,
                height: height,
                color: AppColors.divider,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textMuted,
                ),
              );
            },
          )
        : Image.network(
            url,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, error, stackTrace) {
              debugPrint('❌ SafeNetworkImage error loading $url: $error');
              return Container(
                width: width,
                height: height,
                color: AppColors.divider,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textMuted,
                ),
              );
            },
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
