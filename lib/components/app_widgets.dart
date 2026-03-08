import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_typography.dart';
import '../utils/app_spacing.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingSm,
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String label;
  final String value;
  const InfoCard({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: AppSpacing.spacingXs),
          Text(
            value,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? actionButton;
  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textMuted),
          SizedBox(height: AppSpacing.spacingMd),
          Text(title, style: AppTypography.titleMedium),
          SizedBox(height: AppSpacing.spacingSm),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          if (actionButton != null) ...[
            SizedBox(height: AppSpacing.spacingLg),
            actionButton!,
          ],
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: AppColors.primary));
  }
}
