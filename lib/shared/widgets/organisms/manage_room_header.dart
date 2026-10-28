import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class ManageRoomHeader extends StatelessWidget {
  const ManageRoomHeader({
    super.key,
    required this.onBack,
    required this.onAdd,
  });

  final VoidCallback onBack;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: onBack,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          icon: const LocalAssetImage(
            directory: manageRoomAssetDir,
            name: 'BackButton.svg',
            width: 34,
            height: 30,
            semanticLabel: 'Back',
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manage Room',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Add, edit, and organize smart classroom',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Room'),
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
