import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../../../screens/admin/admin_home_data.dart';
import '../molecules/quick_access_button.dart';
import '../molecules/stat_summary_card.dart';
import '../organisms/activity_tile.dart';
import '../organisms/admin_header.dart';
import '../organisms/attention_tile.dart';
import '../organisms/live_room_card.dart';

class AdminHomeTemplate extends StatelessWidget {
  const AdminHomeTemplate({
    super.key,
    required this.displayName,
    required this.loading,
    required this.errorMessage,
    required this.unauthorized,
    required this.data,
    required this.onNotification,
    required this.onRetry,
    required this.onLogin,
    required this.onQuickAccess,
  });

  final String? displayName;
  final bool loading;
  final String? errorMessage;
  final bool unauthorized;
  final AdminHomeData? data;
  final VoidCallback onNotification;
  final VoidCallback onRetry;
  final VoidCallback onLogin;
  final ValueChanged<String> onQuickAccess;

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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            AdminHeader(
              displayName: displayName,
              onNotification: onNotification,
            ),
            const SizedBox(height: 18),
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
              _StatusMessage(
                message: errorMessage!,
                actionLabel: unauthorized
                    ? 'Ke halaman login'
                    : 'Coba lagi',
                onPressed: unauthorized ? onLogin : onRetry,
              )
            else if (data != null)
              _Content(
                data: data!,
                onQuickAccess: onQuickAccess,
              ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.data,
    required this.onQuickAccess,
  });

  final AdminHomeData data;
  final ValueChanged<String> onQuickAccess;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatSummaryCard(
          label: "Today's Schedule",
          value: '${data.todayScheduleCount}',
          unit: 'Class Activity',
          iconName: 'calendar-03.svg',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatSummaryCard(
                label: 'Active Now',
                value: '${data.activeRoomCount}',
                unit: 'Class',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatSummaryCard(
                label: 'Device ON',
                value: '${data.deviceOnCount}',
                unit: 'Device',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _SectionTitle('Quick Access'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuickAccessButton(
              label: 'Manage\nSchedule',
              iconName: 'ManageSchedule.svg',
              onTap: () => onQuickAccess('kelola jadwal'),
            ),
            QuickAccessButton(
              label: 'Manage\nRoom',
              iconName: 'ManageRoom.svg',
              onTap: () => onQuickAccess('kelola ruangan'),
            ),
            QuickAccessButton(
              label: 'Manage\nDevice',
              iconName: 'ManageDevice.svg',
              onTap: () =>
                  onQuickAccess('kelola perangkat'),
            ),
            QuickAccessButton(
              label: 'Manage\nUser',
              iconName: 'ManageUser.svg',
              onTap: () => onQuickAccess('kelola pengguna'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Live Classroom Status'),
        if (data.rooms.isEmpty)
          const _EmptyText('Belum ada ruangan.')
        else
          for (final room in data.rooms)
            LiveRoomCard(item: room),
        const SizedBox(height: 8),
        const _SectionTitle('Recent Activity'),
        if (data.activities.isEmpty)
          const _EmptyText('Belum ada aktivitas.')
        else
          for (final activity in data.activities)
            ActivityTile(item: activity),
        const SizedBox(height: 8),
        const _SectionTitle('Attention Needed'),
        if (data.attentions.isEmpty)
          const _EmptyText(
            'Tidak ada masalah yang perlu ditangani.',
          )
        else
          for (final item in data.attentions)
            AttentionTile(item: item),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.muted),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
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
