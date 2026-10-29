import 'package:flutter/material.dart';

import '../../app_colors.dart';

class ScheduleFormSection extends StatelessWidget {
  const ScheduleFormSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF3C3E42),
            padding: const EdgeInsets.fromLTRB(
              14,
              12,
              14,
              10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: const Color(0xFF2A2C30),
            padding: const EdgeInsets.fromLTRB(
              14,
              12,
              14,
              14,
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
