import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class RoomMonitorSummary extends StatelessWidget {
  const RoomMonitorSummary({
    super.key,
    required this.total,
    required this.active,
    required this.inactive,
  });

  final int total;
  final int active;
  final int inactive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2E32),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              icon: const LocalAssetImage(
                directory: roomPageAssetDir,
                name: 'Rooms.svg',
                width: 26,
                height: 24,
                semanticLabel: 'Rooms',
              ),
              value: '$total',
              label: 'Rooms',
              valueColor: AppColors.text,
            ),
          ),
          Expanded(
            child: _Stat(
              icon: const _Dot(color: AppColors.active),
              value: '$active',
              label: 'Active',
              valueColor: AppColors.active,
            ),
          ),
          Expanded(
            child: _Stat(
              icon: const _Dot(color: Color(0xFFFF5A5A)),
              value: '$inactive',
              label: 'Inactive',
              valueColor: const Color(0xFFFF5A5A),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final Widget icon;
  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon,
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
