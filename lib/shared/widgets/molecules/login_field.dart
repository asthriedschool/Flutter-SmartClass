import 'package:flutter/material.dart';

import '../../login_colors.dart';
import '../atoms/asset_image.dart';

class LoginField extends StatelessWidget {
  const LoginField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.onChanged,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffix,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String icon;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: LoginColors.input,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
          child: Row(
            children: [
              LocalAssetImage(name: icon, height: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: LoginColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextField(
                      controller: controller,
                      enabled: enabled,
                      obscureText: obscureText,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      autocorrect: false,
                      enableSuggestions: !obscureText,
                      style: const TextStyle(
                        color: LoginColors.text,
                        fontSize: 14,
                      ),
                      cursorColor: LoginColors.primary,
                      decoration: InputDecoration(
                        isDense: true,
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: hint,
                        hintStyle: const TextStyle(
                          color: LoginColors.muted,
                          fontSize: 13,
                        ),
                      ),
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                    ),
                  ],
                ),
              ),
              ?suffix,
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 8),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: LoginColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
