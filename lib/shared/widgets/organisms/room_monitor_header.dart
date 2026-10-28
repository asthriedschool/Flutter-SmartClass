import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class RoomMonitorHeader extends StatelessWidget {
  const RoomMonitorHeader({
    super.key,
    required this.onManageRoom,
  });

  final VoidCallback onManageRoom;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Room',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Monitor all smart classroom',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: onManageRoom,
          icon: const LocalAssetImage(
            directory: roomPageAssetDir,
            name: 'ManageRoomIcon.svg',
            width: 14,
            height: 16,
            semanticLabel: 'Manage Room',
          ),
          label: const Text('Manage Room'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF3DB7FF),
            side: const BorderSide(
              color: Color(0xFF3DB7FF),
            ),
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            shape: const StadiumBorder(),
          ),
        ),
      ],
    );
  }
}
