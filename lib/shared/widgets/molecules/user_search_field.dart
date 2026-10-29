import 'package:flutter/material.dart';

import '../../app_colors.dart';

class UserSearchField extends StatelessWidget {
  const UserSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.isNotEmpty;
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.text),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search name or email',
        hintStyle: const TextStyle(color: AppColors.muted),
        prefixIcon: const Icon(
          Icons.search,
          color: AppColors.muted,
        ),
        suffixIcon: hasText
            ? IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: const Icon(
                  Icons.close,
                  color: AppColors.muted,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFF12181F),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(
            color: Color(0xFF2C6F93),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
