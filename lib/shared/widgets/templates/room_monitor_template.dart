import 'package:flutter/material.dart';

import '../../../models/room.dart';
import '../../app_colors.dart';
import '../molecules/room_monitor_filter.dart';
import '../molecules/room_search_field.dart';
import '../organisms/room_monitor_card.dart';
import '../organisms/room_monitor_header.dart';
import '../organisms/room_monitor_summary.dart';
import '../organisms/smart_bottom_nav.dart';

class RoomMonitorView {
  const RoomMonitorView({
    required this.room,
    required this.deviceLabel,
    required this.scheduleTime,
    required this.scheduleCaption,
  });

  final Room room;
  final String deviceLabel;
  final String scheduleTime;
  final String scheduleCaption;
}

class RoomMonitorTemplate extends StatelessWidget {
  const RoomMonitorTemplate({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.filter,
    required this.onFilterSelected,
    required this.totalRooms,
    required this.activeRooms,
    required this.inactiveRooms,
    required this.rooms,
    required this.loading,
    required this.errorMessage,
    required this.hasActiveQuery,
    required this.onManageRoom,
    required this.onRetry,
    required this.onClearQuery,
    required this.onNavSelected,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String filter;
  final ValueChanged<String> onFilterSelected;
  final int totalRooms;
  final int activeRooms;
  final int inactiveRooms;
  final List<RoomMonitorView> rooms;
  final bool loading;
  final String? errorMessage;
  final bool hasActiveQuery;
  final VoidCallback onManageRoom;
  final VoidCallback onRetry;
  final VoidCallback onClearQuery;
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
                  stops: [0, 0.28],
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
                      RoomMonitorHeader(
                        onManageRoom: onManageRoom,
                      ),
                      const SizedBox(height: 16),
                      RoomSearchField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        onClear: onClearSearch,
                      ),
                      const SizedBox(height: 12),
                      RoomMonitorFilter(
                        selected: filter,
                        onSelected: onFilterSelected,
                      ),
                      const SizedBox(height: 12),
                      RoomMonitorSummary(
                        total: totalRooms,
                        active: activeRooms,
                        inactive: inactiveRooms,
                      ),
                      const SizedBox(height: 12),
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
      return _Message(
        message: errorMessage!,
        actionLabel: 'Coba lagi',
        onPressed: onRetry,
      );
    }
    if (rooms.isEmpty) {
      return _Message(
        message: hasActiveQuery
            ? 'No rooms found'
            : 'Belum ada ruangan.',
        actionLabel: hasActiveQuery
            ? 'Clear search and filter'
            : 'Coba lagi',
        onPressed: hasActiveQuery ? onClearQuery : onRetry,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: rooms.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = rooms[index];
        final room = item.room;
        final enabled = room.isEnabled;
        return RoomMonitorCard(
          name: room.roomName,
          modeLabel: room.operationMode == 'MANUAL'
              ? 'MANUAL'
              : room.operationMode == 'AUTO'
              ? 'AUTO MODE'
              : room.operationMode,
          statusLabel: enabled
              ? 'Active'
              : room.systemStatus == 'DISABLED'
              ? 'Inactive'
              : room.systemStatus,
          active: enabled,
          deviceLabel: item.deviceLabel,
          scheduleTime: item.scheduleTime,
          scheduleCaption: item.scheduleCaption,
          pictureUrl: room.picture,
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
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
