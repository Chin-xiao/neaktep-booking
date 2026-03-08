import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class AppSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool showFilterIcon;
  final VoidCallback? onFilterTap;

  const AppSearchField({
    Key? key,
    this.hint = '',
    required this.controller,
    this.onChanged,
    this.showFilterIcon = false,
    this.onFilterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
        suffixIcon: showFilterIcon
            ? IconButton(
                icon: const Icon(Icons.tune, color: AppColors.primary),
                onPressed: onFilterTap,
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
