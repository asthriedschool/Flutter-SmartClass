import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class ScheduleStatGrid extends StatelessWidget {
  const ScheduleStatGrid({
    super.key,
    required this.todayCount,
    required this.activeCount,
    required this.upcomingCount,
    required this.finishedCount,
  });

  final int todayCount;
  final int activeCount;
  final int upcomingCount;
  final int finishedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: "Today's Schedule",
                value: '$todayCount',
                iconName: 'Calendar 1.svg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Active Now',
                value: '$activeCount',
                iconName: 'Clock.svg',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Upcoming',
                value: '$upcomingCount',
                iconName: 'Schedule.svg',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                label: 'Finished',
                value: '$finishedCount',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.iconName,
  });

  final String label;
  final String value;
  final String? iconName;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF3A3D42)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (iconName != null) ...[
                  LocalAssetImage(
                    directory: scheduleAssetDir,
                    name: iconName!,
                    width: 16,
                    height: 16,
                    semanticLabel: label,
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
