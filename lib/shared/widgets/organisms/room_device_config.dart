import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../molecules/room_info_row.dart';

class RoomDeviceConfig extends StatelessWidget {
  const RoomDeviceConfig({
    super.key,
    required this.lampCount,
    required this.acCount,
    required this.projectorCount,
  });

  final int? lampCount;
  final int? acCount;
  final int? projectorCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Device Configuration',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Set the number of devices in this room',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          RoomInfoRow(
            iconName: 'LampZonesImg.svg',
            label: 'Lamp Zones',
            iconWidth: 20,
            iconHeight: 16,
            child: _CountBox(value: lampCount),
          ),
          RoomInfoRow(
            iconName: 'ACUnitsImg.svg',
            label: 'AC Units',
            iconWidth: 18,
            iconHeight: 18,
            child: _CountBox(value: acCount),
          ),
          RoomInfoRow(
            iconName: 'ProjectorUnitsImg.svg',
            label: 'Projector Units',
            iconWidth: 16,
            iconHeight: 20,
            child: _CountBox(value: projectorCount),
          ),
        ],
      ),
    );
  }
}

class _CountBox extends StatelessWidget {
  const _CountBox({required this.value});

  final int? value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D21),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF5C636A)),
      ),
      child: Text(
        value == null ? '-' : '$value',
        style: const TextStyle(color: AppColors.text),
      ),
    );
  }
}
