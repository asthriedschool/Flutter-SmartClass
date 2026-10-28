import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class DeviceCategoryCard extends StatelessWidget {
  const DeviceCategoryCard({
    super.key,
    required this.iconName,
    required this.label,
  });

  final String iconName;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E6FEA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LocalAssetImage(
            directory: manageRoomAssetDir,
            name: iconName,
            width: 22,
            height: 22,
            semanticLabel: label,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
