import 'package:flutter/material.dart';

import '../../app_colors.dart';

class ScheduleFilterBar extends StatelessWidget {
  const ScheduleFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  static const options = <String>[
    'All',
    'Today',
    'Active',
    'Upcoming',
    'Inactive',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            ChoiceChip(
              label: Text(option),
              selected: selected == option,
              onSelected: (_) => onSelected(option),
              labelStyle: TextStyle(
                color: selected == option
                    ? AppColors.text
                    : AppColors.muted,
                fontSize: 12,
              ),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.card,
              side: BorderSide(
                color: selected == option
                    ? AppColors.primary
                    : const Color(0xFF3A3D42),
              ),
              shape: const StadiumBorder(),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
