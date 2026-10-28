import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class RoomInfoRow extends StatelessWidget {
  const RoomInfoRow({
    super.key,
    required this.iconName,
    required this.label,
    required this.child,
    this.iconWidth = 18,
    this.iconHeight = 18,
  });

  final String iconName;
  final String label;
  final Widget child;
  final double iconWidth;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: LocalAssetImage(
              directory: manageRoomAssetDir,
              name: iconName,
              width: iconWidth,
              height: iconHeight,
              semanticLabel: label,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
