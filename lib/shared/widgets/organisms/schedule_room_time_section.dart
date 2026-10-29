import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';
import '../atoms/schedule_field.dart';
import '../molecules/schedule_repeat_choice.dart';
import '../molecules/schedule_time_row.dart';
import 'schedule_form_section.dart';

class ScheduleRoomTimeSection extends StatelessWidget {
  const ScheduleRoomTimeSection({
    super.key,
    required this.whenLabel,
    required this.startLabel,
    required this.endLabel,
    required this.type,
    required this.cancelled,
    required this.enabled,
    required this.onWhen,
    required this.onStart,
    required this.onEnd,
    required this.onType,
    required this.onCancelled,
  });

  final String whenLabel;
  final String? startLabel;
  final String? endLabel;
  final String type;
  final bool cancelled;
  final bool enabled;
  final VoidCallback onWhen;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final ValueChanged<String> onType;
  final ValueChanged<bool> onCancelled;

  @override
  Widget build(BuildContext context) {
    final hasWhen = whenLabel != 'Day / Date';
    return ScheduleFormSection(
      title: 'Room Information',
      subtitle: 'Set the schedule date & time',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Day / Date',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 6),
          SchedulePickerField(
            value: hasWhen ? whenLabel : null,
            hint: 'Day / Date',
            icon: const LocalAssetImage(
              directory: scheduleAssetDir,
              name: 'Calendar 1.svg',
              width: 16,
              height: 16,
              semanticLabel: 'Day / Date',
            ),
            onPressed: enabled ? onWhen : null,
          ),
          const SizedBox(height: 10),
          ScheduleTimeRow(
            startLabel: startLabel,
            endLabel: endLabel,
            enabled: enabled,
            onStart: onStart,
            onEnd: onEnd,
          ),
          const SizedBox(height: 12),
          ScheduleRepeatChoice(
            type: type,
            enabled: enabled,
            onChanged: onType,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Inactive',
              style: TextStyle(
                color: AppColors.text,
                fontSize: 14,
              ),
            ),
            subtitle: const Text(
              'Jadwal dibatalkan',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 12,
              ),
            ),
            value: cancelled,
            onChanged: enabled ? onCancelled : null,
          ),
        ],
      ),
    );
  }
}
