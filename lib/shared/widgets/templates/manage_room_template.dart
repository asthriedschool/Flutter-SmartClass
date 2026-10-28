import 'package:flutter/material.dart';

import '../../../models/room.dart';
import '../../app_colors.dart';
import '../molecules/room_search_field.dart';
import '../molecules/room_status_filter.dart';
import '../organisms/manage_room_header.dart';
import '../organisms/room_manage_card.dart';
import '../organisms/smart_bottom_nav.dart';

class ManageRoomTemplate extends StatelessWidget {
  const ManageRoomTemplate({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.filter,
    required this.onFilterSelected,
    required this.rooms,
    required this.deviceTotals,
    required this.lampCounts,
    required this.acCounts,
    required this.projectorCounts,
    required this.devicesReady,
    required this.loading,
    required this.errorMessage,
    required this.busyRoomIds,
    required this.hasActiveQuery,
    required this.onBack,
    required this.onAdd,
    required this.onRetry,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleStatus,
    required this.onNavSelected,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String filter;
  final ValueChanged<String> onFilterSelected;
  final List<Room> rooms;
  final Map<int, int> deviceTotals;
  final Map<int, int> lampCounts;
  final Map<int, int> acCounts;
  final Map<int, int> projectorCounts;
  final bool devicesReady;
  final bool loading;
  final String? errorMessage;
  final Set<int> busyRoomIds;
  final bool hasActiveQuery;
  final VoidCallback onBack;
  final VoidCallback onAdd;
  final VoidCallback onRetry;
  final ValueChanged<Room> onEdit;
  final ValueChanged<Room> onDelete;
  final ValueChanged<Room> onToggleStatus;
  final ValueChanged<int> onNavSelected;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0B4261),
                    AppColors.background,
                  ],
                  stops: [0, 0.32],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    0,
                  ),
                  child: Column(
                    children: [
                      ManageRoomHeader(
                        onBack: onBack,
                        onAdd: onAdd,
                      ),
                      const SizedBox(height: 16),
                      RoomSearchField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        onClear: onClearSearch,
                      ),
                      const SizedBox(height: 12),
                      RoomStatusFilter(
                        selected: filter,
                        onSelected: onFilterSelected,
                        resultCount: rooms.length,
                      ),
                      const SizedBox(height: 14),
                      Expanded(child: _body()),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SmartBottomNav(
            currentIndex: 1,
            items: adminBottomNavItems,
            onSelected: onNavSelected,
          ),
        ],
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
      return _MessageState(
        message: errorMessage!,
        actionLabel: 'Coba lagi',
        onPressed: onRetry,
      );
    }
    if (rooms.isEmpty) {
      return _MessageState(
        message: hasActiveQuery
            ? 'No rooms found'
            : 'Belum ada ruangan.',
        actionLabel: hasActiveQuery
            ? 'Clear search and filter'
            : 'Add Room',
        onPressed: hasActiveQuery ? onClearSearch : onAdd,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: rooms.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final room = rooms[index];
        final ready = devicesReady;
        return RoomManageCard(
          room: room,
          deviceTotal: ready
              ? deviceTotals[room.idRoom] ?? 0
              : null,
          lampCount: ready
              ? lampCounts[room.idRoom] ?? 0
              : null,
          acCount: ready
              ? acCounts[room.idRoom] ?? 0
              : null,
          projectorCount: ready
              ? projectorCounts[room.idRoom] ?? 0
              : null,
          busy: busyRoomIds.contains(room.idRoom),
          onEdit: () => onEdit(room),
          onDelete: () => onDelete(room),
          onToggleStatus: () => onToggleStatus(room),
        );
      },
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onPressed,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
