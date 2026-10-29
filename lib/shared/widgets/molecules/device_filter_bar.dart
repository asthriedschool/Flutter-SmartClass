import 'package:flutter/material.dart';

import '../../../models/device.dart';
import '../../app_colors.dart';

class DeviceFilterBar extends StatelessWidget {
  const DeviceFilterBar({
    super.key,
    required this.type,
    required this.status,
    required this.onType,
    required this.onStatus,
  });

  final String type;
  final String status;
  final ValueChanged<String> onType;
  final ValueChanged<String> onStatus;

  static const types = ['All', ...deviceTypes];
  static const statuses = ['Enabled', 'Disabled'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ChipRow(
          options: types,
          selected: type,
          labelOf: _typeLabel,
          onSelected: onType,
        ),
        const SizedBox(height: 8),
        _ChipRow(
          options: statuses,
          selected: status,
          labelOf: (value) => value,
          onSelected: (value) {
            onStatus(value == status ? '' : value);
          },
        ),
      ],
    );
  }
}

String _typeLabel(String value) {
  return switch (value) {
    'LAMP' => 'Lamp',
    'AC' => 'AC',
    'PROJECTOR' => 'Projector',
    _ => value,
  };
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final String Function(String) labelOf;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options) ...[
            Material(
              color: option == selected
                  ? AppColors.primary
                  : const Color(0xFF2A2C2E),
              shape: StadiumBorder(
                side: BorderSide(
                  color: option == selected
                      ? AppColors.primary
                      : const Color(0xFF3E4246),
                ),
              ),
              child: InkWell(
                onTap: () => onSelected(option),
                customBorder: const StadiumBorder(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Text(
                    labelOf(option),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}
