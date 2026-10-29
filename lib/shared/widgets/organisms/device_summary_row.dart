import 'package:flutter/material.dart';

import '../../app_colors.dart';

class DeviceSummaryRow extends StatelessWidget {
  const DeviceSummaryRow({
    super.key,
    required this.total,
    required this.enabledCount,
    required this.disabledCount,
    required this.lampCount,
    required this.acCount,
    required this.projectorCount,
  });

  final int total;
  final int enabledCount;
  final int disabledCount;
  final int lampCount;
  final int acCount;
  final int projectorCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _Card(
                label: 'Total Devices',
                value: '$total',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Card(
                label: 'Enabled',
                value: '$enabledCount',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Card(
                label: 'Disabled',
                value: '$disabledCount',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _Card(
                label: 'Lamp',
                value: '$lampCount',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Card(label: 'AC', value: '$acCount'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Card(
                label: 'Projector',
                value: '$projectorCount',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3D42)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
