import 'package:flutter/material.dart';

import '../../../models/device.dart';
import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class DeviceManageCard extends StatelessWidget {
  const DeviceManageCard({
    super.key,
    required this.device,
    required this.roomLabel,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleEnabled,
  });

  final Device device;
  final String roomLabel;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleEnabled;

  @override
  Widget build(BuildContext context) {
    final enabled = device.isEnabled != false;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2C30),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E6FEA),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                child: LocalAssetImage(
                  directory: manageRoomAssetDir,
                  name: device.typeIcon,
                  width: 20,
                  height: 20,
                  semanticLabel: device.typeLabel,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.deviceName.isEmpty
                          ? 'Tanpa nama'
                          : device.deviceName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      device.typeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            roomLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(
                label: enabled ? 'Enabled' : 'Disabled',
                color: enabled
                    ? const Color(0xFF145C38)
                    : const Color(0xFF5C3030),
              ),
              _Badge(
                label: device.status.isEmpty
                    ? 'UNKNOWN'
                    : device.status,
                color: const Color(0xFF3A3C40),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: busy ? null : onToggleEnabled,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                side: const BorderSide(
                  color: Color(0xFF3E4246),
                ),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(enabled ? 'Disable' : 'Enable'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onEdit,
                  icon: const LocalAssetImage(
                    directory: scheduleAssetDir,
                    name: 'Edit Pencil.svg',
                    width: 14,
                    height: 14,
                    semanticLabel: 'Edit',
                  ),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(
                      color: Color(0xFF3E4246),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onDelete,
                  icon: const LocalAssetImage(
                    directory: scheduleAssetDir,
                    name: 'Trash.svg',
                    width: 14,
                    height: 14,
                    semanticLabel: 'Delete',
                  ),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(
                      0xFFFFB4AB,
                    ),
                    side: const BorderSide(
                      color: Color(0xFF6E2A24),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
