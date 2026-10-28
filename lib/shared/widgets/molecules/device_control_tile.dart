import 'package:flutter/material.dart';

import '../../../models/device.dart';
import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class DeviceControlTile extends StatelessWidget {
  const DeviceControlTile({
    super.key,
    required this.device,
    required this.iconName,
    required this.busy,
    required this.onPressed,
    this.expanded = false,
  });

  final Device device;
  final String iconName;
  final bool busy;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final on = device.isOn;
    final disabled = device.isEnabled == false;
    final statusLabel = disabled
        ? 'Disabled'
        : device.status == 'UNKNOWN'
        ? 'Unknown'
        : on
        ? 'ON'
        : 'OFF';
    final tile = Material(
      color: on && !disabled
          ? const Color(0xFF1E6FEA)
          : const Color(0xFF3A3E44),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: busy ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (busy)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.text,
                  ),
                )
              else
                LocalAssetImage(
                  directory: manageRoomAssetDir,
                  name: iconName,
                  width: 18,
                  height: 18,
                  semanticLabel: device.deviceName,
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${device.deviceName}  $statusLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (expanded) {
      return SizedBox(width: double.infinity, child: tile);
    }
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132),
      child: tile,
    );
  }
}
