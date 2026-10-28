import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class StatSummaryCard extends StatelessWidget {
  const StatSummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.iconName,
  });

  final String label;
  final String value;
  final String unit;
  final String? iconName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A4FF), Color(0xFF0B4261)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                  ),
                ),
              ),
              if (iconName != null)
                LocalAssetImage(
                  directory: berandaAssetDir,
                  name: iconName!,
                  height: 22,
                  semanticLabel: label,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
