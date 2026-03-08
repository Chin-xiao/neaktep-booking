import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import '../utils/app_spacing.dart';

class AppElevatedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const AppElevatedButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: AppSpacing.paddingMd,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusLg),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.titleMedium.copyWith(color: Colors.white),
      ),
    );
  }
}
