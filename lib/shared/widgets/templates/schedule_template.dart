import 'package:flutter/material.dart';

import '../../../screens/schedule/schedule_status.dart';
import '../../app_colors.dart';
import '../molecules/schedule_search_field.dart';
import '../organisms/schedule_card.dart';
import '../organisms/schedule_filter_bar.dart';
import '../organisms/schedule_header.dart';
import '../organisms/schedule_stat_grid.dart';

class ScheduleCardData {
  const ScheduleCardData({
    required this.id,
    required this.roomName,
    required this.modeLabel,
    required this.phase,
    required this.subject,
    required this.timeLabel,
    required this.dateLabel,
    required this.lecturerName,
    required this.pictureUrl,
  });

  final int id;
  final String roomName;
  final String modeLabel;
  final SchedulePhase phase;
  final String subject;
  final String timeLabel;
  final String dateLabel;
  final String? lecturerName;
  final String? pictureUrl;
}

class ScheduleTemplate extends StatelessWidget {
  const ScheduleTemplate({
    super.key,
    required this.loading,
    required this.errorMessage,
    required this.unauthorized,
    required this.canManage,
    required this.searchController,
    required this.filter,
    required this.todayCount,
    required this.activeCount,
    required this.upcomingCount,
    required this.finishedCount,
    required this.items,
    required this.busyId,
    required this.onBack,
    required this.onAdd,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.onFilter,
    required this.onRetry,
    required this.onLogin,
    required this.onEdit,
    required this.onDelete,
  });

  final bool loading;
  final String? errorMessage;
  final bool unauthorized;
  final bool canManage;
  final TextEditingController searchController;
  final String filter;
  final int todayCount;
  final int activeCount;
  final int upcomingCount;
  final int finishedCount;
  final List<ScheduleCardData> items;
  final int? busyId;
  final VoidCallback onBack;
  final VoidCallback? onAdd;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ValueChanged<String> onFilter;
  final VoidCallback onRetry;
  final VoidCallback onLogin;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.navy, AppColors.background],
          stops: [0, 0.28],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            ScheduleHeader(
              onBack: onBack,
              onAdd: onAdd,
              canAdd: canManage,
            ),
            const SizedBox(height: 16),
            ScheduleSearchField(
              controller: searchController,
              onChanged: onSearchChanged,
              onClear: onSearchClear,
            ),
            const SizedBox(height: 12),
            ScheduleFilterBar(
              selected: filter,
              onSelected: onFilter,
            ),
            const SizedBox(height: 16),
            if (loading)
              const Padding(
                padding: EdgeInsets.only(top: 48),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              )
            else if (errorMessage != null)
              _Status(
                message: errorMessage!,
                actionLabel: unauthorized
                    ? 'Ke halaman login'
                    : 'Coba lagi',
                onPressed: unauthorized ? onLogin : onRetry,
              )
            else ...[
              ScheduleStatGrid(
                todayCount: todayCount,
                activeCount: activeCount,
                upcomingCount: upcomingCount,
                finishedCount: finishedCount,
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Text(
                  'Tidak ada jadwal.',
                  style: TextStyle(color: AppColors.muted),
                )
              else
                for (final item in items)
                  ScheduleCard(
                    roomName: item.roomName,
                    modeLabel: item.modeLabel,
                    phase: item.phase,
                    subject: item.subject,
                    timeLabel: item.timeLabel,
                    dateLabel: item.dateLabel,
                    lecturerName: item.lecturerName,
                    pictureUrl: item.pictureUrl,
                    canManage: canManage,
                    busy: busyId != null,
                    onEdit: () => onEdit(item.id),
                    onDelete: () => onDelete(item.id),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  const _Status({
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.text),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onPressed,
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
