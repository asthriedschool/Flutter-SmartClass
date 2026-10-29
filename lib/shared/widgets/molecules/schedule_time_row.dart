import 'package:flutter/material.dart';

import '../atoms/asset_image.dart';
import '../atoms/schedule_field.dart';

class ScheduleTimeRow extends StatelessWidget {
  const ScheduleTimeRow({
    super.key,
    required this.startLabel,
    required this.endLabel,
    required this.enabled,
    required this.onStart,
    required this.onEnd,
  });

  final String? startLabel;
  final String? endLabel;
  final bool enabled;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScheduleFieldLabel('Start Time'),
              const SizedBox(height: 6),
              SchedulePickerField(
                value: startLabel,
                hint: 'Start Time',
                icon: const LocalAssetImage(
                  directory: scheduleAssetDir,
                  name: 'Clock.svg',
                  width: 16,
                  height: 16,
                  semanticLabel: 'Start Time',
                ),
                onPressed: enabled ? onStart : null,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScheduleFieldLabel('End Time'),
              const SizedBox(height: 6),
              SchedulePickerField(
                value: endLabel,
                hint: 'End Time',
                icon: const LocalAssetImage(
                  directory: scheduleAssetDir,
                  name: 'Clock.svg',
                  width: 16,
                  height: 16,
                  semanticLabel: 'End Time',
                ),
                onPressed: enabled ? onEnd : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
