import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;

  const RoundIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = AppColors.surface,
    this.iconColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 22,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}
