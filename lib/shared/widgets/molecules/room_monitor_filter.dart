import 'package:flutter/material.dart';

import '../../app_colors.dart';

class RoomMonitorFilter extends StatelessWidget {
  const RoomMonitorFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  static const options = [
    'All',
    'Auto',
    'Manual',
    'Active',
    'Inactive',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            _Chip(
              label: option,
              selected: option == selected,
              onTap: () => onSelected(option),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? const Color(0xFF123A5C)
          : const Color(0xFF2A2C2E),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? const Color(0xFF3DB7FF)
              : const Color(0xFF3E4246),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
