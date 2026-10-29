import 'package:flutter/material.dart';

import '../../../models/device.dart';
import '../../app_colors.dart';
import '../molecules/device_filter_bar.dart';
import '../molecules/device_search_field.dart';
import '../organisms/device_manage_card.dart';
import '../organisms/device_summary_row.dart';
import '../organisms/manage_device_header.dart';

class ManageDeviceTemplate extends StatelessWidget {
  const ManageDeviceTemplate({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.typeFilter,
    required this.statusFilter,
    required this.onType,
    required this.onStatus,
    required this.devices,
    required this.roomLabel,
    required this.total,
    required this.enabledCount,
    required this.disabledCount,
    required this.lampCount,
    required this.acCount,
    required this.projectorCount,
    required this.loading,
    required this.errorMessage,
    required this.unauthorized,
    required this.busyIds,
    required this.hasActiveQuery,
    required this.onBack,
    required this.onAdd,
    required this.onRetry,
    required this.onLogin,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleEnabled,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String typeFilter;
  final String statusFilter;
  final ValueChanged<String> onType;
  final ValueChanged<String> onStatus;
  final List<Device> devices;
  final String Function(Device) roomLabel;
  final int total;
  final int enabledCount;
  final int disabledCount;
  final int lampCount;
  final int acCount;
  final int projectorCount;
  final bool loading;
  final String? errorMessage;
  final bool unauthorized;
  final Set<int> busyIds;
  final bool hasActiveQuery;
  final VoidCallback onBack;
  final VoidCallback onAdd;
  final VoidCallback onRetry;
  final VoidCallback onLogin;
  final ValueChanged<Device> onEdit;
  final ValueChanged<Device> onDelete;
  final ValueChanged<Device> onToggleEnabled;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B4261), AppColors.background],
          stops: [0, 0.28],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                0,
              ),
              child: ManageDeviceHeader(
                onBack: onBack,
                onAdd: onAdd,
              ),
            ),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: unauthorized ? onLogin : onRetry,
              child: Text(
                unauthorized ? 'Login' : 'Coba lagi',
              ),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        DeviceSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          onClear: onClearSearch,
        ),
        const SizedBox(height: 12),
        DeviceFilterBar(
          type: typeFilter,
          status: statusFilter,
          onType: onType,
          onStatus: onStatus,
        ),
        const SizedBox(height: 14),
        DeviceSummaryRow(
          total: total,
          enabledCount: enabledCount,
          disabledCount: disabledCount,
          lampCount: lampCount,
          acCount: acCount,
          projectorCount: projectorCount,
        ),
        const SizedBox(height: 16),
        if (devices.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(
              hasActiveQuery
                  ? 'Tidak ada perangkat yang cocok.'
                  : 'Belum ada perangkat.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
              ),
            ),
          )
        else
          for (final device in devices) ...[
            DeviceManageCard(
              device: device,
              roomLabel: roomLabel(device),
              busy: busyIds.contains(device.idDevice),
              onEdit: () => onEdit(device),
              onDelete: () => onDelete(device),
              onToggleEnabled: () =>
                  onToggleEnabled(device),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
