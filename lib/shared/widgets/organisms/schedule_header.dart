import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({
    super.key,
    required this.onBack,
    required this.onAdd,
    required this.canAdd,
  });

  final VoidCallback onBack;
  final VoidCallback? onAdd;
  final bool canAdd;

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
                'Schedule',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Manage Classroom Schedules',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (canAdd) ...[
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const LocalAssetImage(
              directory: scheduleAssetDir,
              name: 'Schedule.svg',
              width: 16,
              height: 16,
              semanticLabel: 'Add Schedule',
            ),
            label: const Text('Add Schedule'),
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
      ],
    );
  }
}
