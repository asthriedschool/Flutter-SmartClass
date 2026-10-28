import 'package:flutter/material.dart';

import '../../../models/device.dart';
import '../../app_colors.dart';
import '../atoms/asset_image.dart';
import '../molecules/device_category_card.dart';
import '../molecules/device_control_tile.dart';

class RoomDetailHeader extends StatelessWidget {
  const RoomDetailHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: onBack,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          icon: const LocalAssetImage(
            directory: manageRoomAssetDir,
            name: 'BackButton.svg',
            width: 34,
            height: 30,
            semanticLabel: 'Back',
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Room Detail',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class RoomDetailBanner extends StatelessWidget {
  const RoomDetailBanner({
    super.key,
    required this.name,
    required this.modeLabel,
    required this.statusLabel,
    required this.active,
    required this.pictureUrl,
    required this.deviceLabel,
    required this.scheduleTime,
    required this.scheduleCaption,
  });

  final String name;
  final String modeLabel;
  final String statusLabel;
  final bool active;
  final String? pictureUrl;
  final String deviceLabel;
  final String scheduleTime;
  final String scheduleCaption;

  @override
  Widget build(BuildContext context) {
    final url = pictureUrl?.trim() ?? '';
    final network =
        url.startsWith('http://') ||
        url.startsWith('https://');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E6FEA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                modeLabel,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.active
                    : const Color(0xFFFF5A5A),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              statusLabel,
              style: const TextStyle(color: AppColors.text),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (network)
                  Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      'assets/asset_login_page/FotoKelas.png',
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Image.asset(
                    'assets/asset_login_page/FotoKelas.png',
                    fit: BoxFit.cover,
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x663A8EC4),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2F33),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: _Metric(
                  value: deviceLabel,
                  caption: 'Devices ON',
                ),
              ),
              Expanded(
                child: _Metric(
                  value: scheduleTime,
                  caption: scheduleCaption,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.caption,
  });

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class DeviceStatusSection extends StatelessWidget {
  const DeviceStatusSection({
    super.key,
    required this.devices,
    required this.switching,
    required this.onSwitchMode,
  });

  final List<Device> devices;
  final bool switching;
  final VoidCallback onSwitchMode;

  @override
  Widget build(BuildContext context) {
    final groups = _groups(devices);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Device Status',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (groups.isEmpty)
          const Text(
            'Tidak ada perangkat di ruangan ini.',
            style: TextStyle(color: AppColors.muted),
          )
        else
          Row(
            children: [
              for (final group in groups) ...[
                Expanded(
                  child: DeviceCategoryCard(
                    iconName: group.icon,
                    label: '${group.on}/${group.total} ON',
                  ),
                ),
                if (group != groups.last)
                  const SizedBox(width: 8),
              ],
            ],
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: switching ? null : onSwitchMode,
            icon: switching
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.text,
                    ),
                  )
                : const Icon(Icons.sync),
            label: const Text('Switch to Manual Mode'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class ManualControlSection extends StatelessWidget {
  const ManualControlSection({
    super.key,
    required this.devices,
    required this.busyIds,
    required this.switching,
    required this.onToggle,
    required this.onSwitchMode,
  });

  final List<Device> devices;
  final Set<int> busyIds;
  final bool switching;
  final ValueChanged<Device> onToggle;
  final VoidCallback onSwitchMode;

  @override
  Widget build(BuildContext context) {
    final lamps = _of(devices, 'LAMP');
    final acs = _of(devices, 'AC');
    final projectors = _of(devices, 'PROJECTOR');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manual Control',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        if (lamps.isEmpty &&
            acs.isEmpty &&
            projectors.isEmpty)
          const Text(
            'Tidak ada perangkat di ruangan ini.',
            style: TextStyle(color: AppColors.muted),
          ),
        if (lamps.isNotEmpty)
          _Group(
            title: 'Lamp',
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final device in lamps) ...[
                    DeviceControlTile(
                      device: device,
                      iconName: 'LampZonesImg.svg',
                      busy: busyIds.contains(
                        device.idDevice,
                      ),
                      onPressed: device.isEnabled == false
                          ? null
                          : () => onToggle(device),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
        if (acs.isNotEmpty)
          _Group(
            title: 'Air Conditioner',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final device in acs)
                  DeviceControlTile(
                    device: device,
                    iconName: 'ACUnitsImg.svg',
                    busy: busyIds.contains(device.idDevice),
                    onPressed: device.isEnabled == false
                        ? null
                        : () => onToggle(device),
                  ),
              ],
            ),
          ),
        if (projectors.isNotEmpty)
          _Group(
            title: 'Projector',
            child: Column(
              children: [
                for (final device in projectors) ...[
                  DeviceControlTile(
                    device: device,
                    iconName: 'ProjectorUnitsImg.svg',
                    busy: busyIds.contains(device.idDevice),
                    expanded: true,
                    onPressed: device.isEnabled == false
                        ? null
                        : () => onToggle(device),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton.icon(
            onPressed: switching ? null : onSwitchMode,
            icon: switching
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.text,
                    ),
                  )
                : const Icon(Icons.sync),
            label: const Text('Switch to Auto Mode'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F33),
        borderRadius: BorderRadius.circular(16),
      ),
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
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TypeGroup {
  const _TypeGroup(this.icon, this.on, this.total);

  final String icon;
  final int on;
  final int total;
}

List<_TypeGroup> _groups(List<Device> devices) {
  _TypeGroup? group(String type, String icon) {
    final items = devices
        .where((device) => device.deviceType == type)
        .toList();
    if (items.isEmpty) {
      return null;
    }
    return _TypeGroup(
      icon,
      items.where((device) => device.isOn).length,
      items.length,
    );
  }

  return [
    group('LAMP', 'LampZonesImg.svg'),
    group('AC', 'ACUnitsImg.svg'),
    group('PROJECTOR', 'ProjectorUnitsImg.svg'),
  ].whereType<_TypeGroup>().toList();
}

List<Device> _of(List<Device> devices, String type) {
  return devices
      .where((device) => device.deviceType == type)
      .toList();
}
