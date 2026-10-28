import 'package:flutter/material.dart';

import '../../app_colors.dart';

class RoomStatusFilter extends StatelessWidget {
  const RoomStatusFilter({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.resultCount,
  });

  final String selected;
  final ValueChanged<String> onSelected;
  final int resultCount;

  static const options = ['All', 'Enabled', 'Disabled'];

  @override
  Widget build(BuildContext context) {
    final label = resultCount == 1
        ? '1 Room'
        : '$resultCount Rooms';
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in options) ...[
                  _FilterChip(
                    label: option,
                    selected: option == selected,
                    onTap: () => onSelected(option),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
          ? AppColors.primary
          : const Color(0xFF2A2C2E),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected
              ? AppColors.primary
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
