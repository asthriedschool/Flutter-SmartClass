import 'package:flutter/material.dart';

import '../../app_colors.dart';

class ScheduleRepeatChoice extends StatelessWidget {
  const ScheduleRepeatChoice({
    super.key,
    required this.type,
    required this.enabled,
    required this.onChanged,
  });

  final String type;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Repeat',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 12),
        _RepeatChip(
          label: 'Once',
          selected: type == 'ONCE',
          enabled: enabled,
          onTap: () => onChanged('ONCE'),
        ),
        const SizedBox(width: 8),
        _RepeatChip(
          label: 'Weekly',
          selected: type == 'WEEKLY',
          enabled: enabled,
          onTap: () => onChanged('WEEKLY'),
        ),
      ],
    );
  }
}

class _RepeatChip extends StatelessWidget {
  const _RepeatChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary
          : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : const Color(0xFF5A5D62),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? AppColors.text
                  : AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
