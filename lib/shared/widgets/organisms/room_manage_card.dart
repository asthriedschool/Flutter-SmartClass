import 'package:flutter/material.dart';

import '../../../models/room.dart';
import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class RoomManageCard extends StatelessWidget {
  const RoomManageCard({
    super.key,
    required this.room,
    required this.deviceTotal,
    required this.lampCount,
    required this.acCount,
    required this.projectorCount,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
  });

  final Room room;
  final int? deviceTotal;
  final int? lampCount;
  final int? acCount;
  final int? projectorCount;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final enabled = room.isEnabled;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2E28),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  room.roomName,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(enabled: enabled),
            ],
          ),
          if (room.locationLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.muted,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    room.locationLabel,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          _DeviceSummary(
            total: deviceTotal,
            lampCount: lampCount,
            acCount: acCount,
            projectorCount: projectorCount,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Edit',
                  icon: Icons.edit_outlined,
                  background: AppColors.primary,
                  foreground: AppColors.text,
                  enabled: !busy,
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'Delete',
                  icon: Icons.delete_outline,
                  background: const Color(0xFF8E2A2A),
                  foreground: AppColors.text,
                  enabled: !busy,
                  onPressed: onDelete,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: enabled
                      ? 'Disable Room'
                      : 'Enable Room',
                  icon: enabled
                      ? Icons.power_settings_new
                      : Icons.play_arrow_rounded,
                  background: enabled
                      ? Colors.transparent
                      : const Color(0xFF6D4BD8),
                  foreground: AppColors.text,
                  borderColor: enabled
                      ? const Color(0xFF8E939A)
                      : const Color(0xFF6D4BD8),
                  enabled: !busy,
                  onPressed: onToggleStatus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final label = enabled
        ? 'System Status : Enabled'
        : 'System Status : Disabled';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: enabled
            ? const Color(0xFF1F6B32)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled
              ? const Color(0xFF3DDC84)
              : const Color(0xFF8E939A),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: enabled
              ? const Color(0xFFB6F5C8)
              : AppColors.text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DeviceSummary extends StatelessWidget {
  const _DeviceSummary({
    required this.total,
    required this.lampCount,
    required this.acCount,
    required this.projectorCount,
  });

  final int? total;
  final int? lampCount;
  final int? acCount;
  final int? projectorCount;

  @override
  Widget build(BuildContext context) {
    if (total == null) {
      return const Text(
        'Ringkasan perangkat tidak tersedia.',
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 13,
        ),
      );
    }
    final title = total == 1
        ? '1 Registered Device'
        : '$total Registered Device';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LocalAssetImage(
          directory: manageRoomAssetDir,
          name: 'DevicesImg.svg',
          width: 22,
          height: 28,
          semanticLabel: 'Devices',
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Lamp: $lampCount   AC: $acCount   Projector: $projectorCount',
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.enabled,
    required this.onPressed,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final bool enabled;
  final VoidCallback onPressed;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: TextButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 14),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          disabledForegroundColor: foreground.withValues(
            alpha: 0.4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: borderColor ?? background,
            ),
          ),
        ),
      ),
    );
  }
}
