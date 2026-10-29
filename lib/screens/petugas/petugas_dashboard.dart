import 'package:flutter/material.dart';

import '../../models/activity_log.dart';
import '../../models/device.dart';
import '../../models/room.dart';
import '../../models/schedule.dart';
import '../../network/api_client.dart';
import '../../services/activity_log_service.dart';
import '../../services/auth_service.dart';
import '../../services/device_service.dart';
import '../../services/room_service.dart';
import '../../services/schedule_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/atoms/asset_image.dart';
import '../../shared/widgets/molecules/quick_access_button.dart';
import '../../shared/widgets/molecules/stat_summary_card.dart';
import '../../shared/widgets/organisms/activity_tile.dart';
import '../../shared/widgets/organisms/smart_bottom_nav.dart';
import '../../storage/token_storage.dart';
import '../admin/admin_home_data.dart';
import '../admin/room_detail_page.dart';
import '../admin/room_page.dart';
import '../login/login_screen.dart';
import '../profile/profile_page.dart';
import '../schedule/schedule_page.dart';
import '../schedule/schedule_status.dart';

class PetugasDashboard extends StatefulWidget {
  const PetugasDashboard({super.key});

  @override
  State<PetugasDashboard> createState() =>
      _PetugasDashboardState();
}

class _PetugasDashboardState
    extends State<PetugasDashboard> {
  final RoomService _roomService = RoomService();
  final DeviceService _deviceService = DeviceService();
  final ScheduleService _scheduleService =
      ScheduleService();
  final ActivityLogService _activityLogService =
      ActivityLogService();
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();

  String? _displayName;
  bool _loading = true;
  bool _unauthorized = false;
  String? _errorMessage;
  AdminHomeData? _data;
  List<Room> _rooms = const [];
  List<Device> _devices = const [];
  List<Schedule> _todaySchedules = const [];
  List<ActivityItem> _activityHistory = const [];
  bool _devicesReady = false;
  String? _scheduleError;
  String? _activityError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _unauthorized = false;
      _scheduleError = null;
      _activityError = null;
      _devicesReady = false;
    });
    try {
      final token = await _tokenStorage.getAccessToken();
      final name = token == null
          ? null
          : _authService.fullNameFromAccessToken(token);
      if (mounted && name != null && name.isNotEmpty) {
        setState(() => _displayName = name);
      }

      final rooms = await _roomService.getRooms();
      var devices = const <Device>[];
      var devicesReady = true;
      try {
        devices = await _deviceService.getDevices();
      } on ApiException {
        devicesReady = false;
      }
      var schedules = const <Schedule>[];
      String? scheduleError;
      try {
        schedules = await _scheduleService.getSchedules();
      } on ApiException catch (error) {
        scheduleError = error.message;
      }
      var logs = const <ActivityLog>[];
      String? activityError;
      try {
        logs = await _activityLogService.getActivityLogs();
      } on ApiException catch (error) {
        activityError = error.message;
      }
      if (!mounted) {
        return;
      }

      final now = DateTime.now();
      final dashboardData = AdminHomeData.fromSources(
        rooms: rooms,
        devices: devices,
        schedules: schedules,
        logs: logs,
        now: now,
      );
      final todaySchedules =
          schedules
              .where(
                (schedule) =>
                    !schedule.isCancelled &&
                    scheduleOccursToday(schedule, now),
              )
              .toList()
            ..sort(
              (left, right) => (left.startTime ?? '')
                  .compareTo(right.startTime ?? ''),
            );

      setState(() {
        _displayName = name;
        _rooms = rooms;
        _devices = devices;
        _devicesReady = devicesReady;
        _scheduleError = scheduleError;
        _activityError = activityError;
        _todaySchedules = todaySchedules;
        _activityHistory = _activityItems(logs, rooms);
        _data = dashboardData;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _unauthorized = error.unauthorized;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = 'Data beranda gagal dimuat.';
      });
    }
  }

  Future<void> _goToLogin() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  Future<void> _openRoomPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const RoomPage(),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  Future<void> _openRoom(Room room) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoomDetailPage(room: room),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  Future<void> _openSchedulePage() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SchedulePage(),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  void _onQuickAccess(String action) {
    switch (action) {
      case 'rooms':
      case 'devices':
        _openRoomPage();
        return;
      case 'schedules':
        _openSchedulePage();
        return;
      case 'activity':
        _showActivityHistory();
        return;
    }
  }

  void _onNavSelected(int index) {
    if (index == 1) {
      _openRoomPage();
      return;
    }
    if (index == 2) {
      _openSchedulePage();
      return;
    }
    if (index == 3) {
      ProfilePage.open(context);
    }
  }

  void _showActivityHistory() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.75,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  12,
                  12,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Activity History',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Tutup',
                      onPressed: () =>
                          Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _activityHistory.isEmpty
                    ? Center(
                        child: Text(
                          _activityError == null
                              ? 'Belum ada aktivitas.'
                              : 'Riwayat aktivitas tidak tersedia.',
                          style: TextStyle(
                            color: AppColors.muted,
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          20,
                        ),
                        children: [
                          for (final item
                              in _activityHistory)
                            ActivityTile(item: item),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnavailable(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature belum tersedia.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.navy,
                    AppColors.background,
                  ],
                  stops: [0, 0.28],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _load,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      24,
                    ),
                    children: [
                      _PetugasHeader(
                        displayName: _displayName,
                        onNotification: () =>
                            _showUnavailable('Notifikasi'),
                      ),
                      const SizedBox(height: 18),
                      if (_loading)
                        const Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: Center(
                            child:
                                CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                          ),
                        )
                      else if (_errorMessage != null)
                        _StatusMessage(
                          message: _errorMessage!,
                          actionLabel: _unauthorized
                              ? 'Ke halaman login'
                              : 'Coba lagi',
                          onPressed: _unauthorized
                              ? _goToLogin
                              : _load,
                        )
                      else if (_data != null)
                        _DashboardContent(
                          data: _data!,
                          rooms: _rooms,
                          devices: _devices,
                          devicesReady: _devicesReady,
                          schedules: _todaySchedules,
                          scheduleError: _scheduleError,
                          activityError: _activityError,
                          onQuickAccess: _onQuickAccess,
                          onOpenRoom: _openRoom,
                          onOpenSchedules:
                              _openSchedulePage,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SmartBottomNav(
            currentIndex: 0,
            items: adminBottomNavItems,
            onSelected: _onNavSelected,
          ),
        ],
      ),
    );
  }
}

class _PetugasHeader extends StatelessWidget {
  const _PetugasHeader({
    required this.displayName,
    required this.onNotification,
  });

  final String? displayName;
  final VoidCallback onNotification;

  @override
  Widget build(BuildContext context) {
    final firstName = displayName?.trim().split(' ').first;
    final greeting = firstName == null || firstName.isEmpty
        ? 'Selamat datang,'
        : 'Hi $firstName,';

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.input,
            shape: BoxShape.circle,
          ),
          child: const LocalAssetImage(
            directory: berandaAssetDir,
            name: 'ManageUser.svg',
            height: 24,
            semanticLabel: 'Profil petugas',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Welcome back to Smart Class!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary,
                  ),
                ),
                child: const Text(
                  'Petugas',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: onNotification,
          icon: const LocalAssetImage(
            directory: berandaAssetDir,
            name: 'Notification.svg',
            height: 22,
            semanticLabel: 'Notifikasi',
          ),
        ),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.data,
    required this.rooms,
    required this.devices,
    required this.devicesReady,
    required this.schedules,
    required this.scheduleError,
    required this.activityError,
    required this.onQuickAccess,
    required this.onOpenRoom,
    required this.onOpenSchedules,
  });

  final AdminHomeData data;
  final List<Room> rooms;
  final List<Device> devices;
  final bool devicesReady;
  final List<Schedule> schedules;
  final String? scheduleError;
  final String? activityError;
  final ValueChanged<String> onQuickAccess;
  final ValueChanged<Room> onOpenRoom;
  final VoidCallback onOpenSchedules;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final roomNames = {
      for (final room in rooms) room.idRoom: room.roomName,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatSummaryCard(
          label: "Today's Schedule",
          value: scheduleError == null
              ? '${data.todayScheduleCount}'
              : '--',
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
                value: devicesReady
                    ? '${data.deviceOnCount}'
                    : '--',
                unit: 'Device',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Quick Access'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuickAccessButton(
              label: 'Monitor\nRoom',
              iconName: 'MonitorRoom.svg',
              onTap: () => onQuickAccess('rooms'),
            ),
            QuickAccessButton(
              label: 'Control\nDevice',
              iconName: 'ManageDevice.svg',
              onTap: () => onQuickAccess('devices'),
            ),
            QuickAccessButton(
              label: 'Class\nSchedule',
              iconName: 'ClassSchedule.svg',
              onTap: () => onQuickAccess('schedules'),
            ),
            QuickAccessButton(
              label: 'Activity\nHistory',
              iconName: 'ActivityHistory.svg',
              onTap: () => onQuickAccess('activity'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _SectionTitle('My Rooms'),
        if (rooms.isEmpty)
          const _EmptyText('Belum ada ruangan.')
        else
          SizedBox(
            height: 164,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: rooms.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final room = rooms[index];
                final roomSchedules = schedules
                    .where(
                      (schedule) =>
                          schedule.idRoom == room.idRoom,
                    )
                    .toList();
                final roomDevices = devices
                    .where(
                      (device) =>
                          device.idRoom == room.idRoom,
                    )
                    .toList();
                return _PetugasRoomCard(
                  room: room,
                  deviceLabel: devicesReady
                      ? '${roomDevices.where((device) => device.isOn).length}/${roomDevices.length}'
                      : '--',
                  schedules: roomSchedules,
                  scheduleReady: scheduleError == null,
                  now: today,
                  onTap: () => onOpenRoom(room),
                );
              },
            ),
          ),
        const SizedBox(height: 12),
        _SectionTitle(
          "Today's Schedule",
          actionLabel: 'Lihat semua',
          onAction: onOpenSchedules,
        ),
        if (scheduleError != null)
          const _EmptyText('Jadwal tidak tersedia.')
        else if (schedules.isEmpty)
          const _EmptyText('Tidak ada jadwal hari ini.')
        else
          for (final schedule in schedules.take(3))
            _TodayScheduleRow(
              schedule: schedule,
              roomName:
                  roomNames[schedule.idRoom] ??
                  'Ruangan tidak tersedia',
              now: today,
            ),
        const SizedBox(height: 8),
        const _SectionTitle('Recent Activity'),
        if (activityError != null)
          const _EmptyText(
            'Riwayat aktivitas tidak tersedia.',
          )
        else if (data.activities.isEmpty)
          const _EmptyText('Belum ada aktivitas.')
        else
          for (final activity in data.activities)
            ActivityTile(item: activity),
      ],
    );
  }
}

class _PetugasRoomCard extends StatelessWidget {
  const _PetugasRoomCard({
    required this.room,
    required this.deviceLabel,
    required this.schedules,
    required this.scheduleReady,
    required this.now,
    required this.onTap,
  });

  final Room room;
  final String deviceLabel;
  final List<Schedule> schedules;
  final bool scheduleReady;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final picture = room.picture?.trim() ?? '';
    final hasNetworkPicture =
        picture.startsWith('http://') ||
        picture.startsWith('https://');
    final active = schedules.any(
      (schedule) =>
          schedulePhase(schedule, now) ==
          SchedulePhase.active,
    );
    final upcoming = schedules.any(
      (schedule) =>
          schedulePhase(schedule, now) ==
          SchedulePhase.upcoming,
    );
    final status = !room.isEnabled
        ? 'Nonaktif'
        : !scheduleReady
        ? 'Jadwal tidak tersedia'
        : active
        ? 'Sedang Digunakan'
        : upcoming
        ? 'Akan Digunakan'
        : 'Tersedia';
    final statusColor = !room.isEnabled
        ? AppColors.input
        : !scheduleReady
        ? AppColors.input
        : active
        ? AppColors.primary
        : const Color(0xFF087F57);

    return SizedBox(
      width: 118,
      child: Material(
        color: const Color(0xFF111C27),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: hasNetworkPicture
                        ? Image.network(
                            picture,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _roomFallback(),
                          )
                        : _roomFallback(),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  room.roomName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  room.locationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: AppColors.active,
                      size: 15,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        deviceLabel,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.muted,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roomFallback() {
    return Image.asset(
      'assets/asset_login_page/FotoKelas.png',
      fit: BoxFit.cover,
    );
  }
}

class _TodayScheduleRow extends StatelessWidget {
  const _TodayScheduleRow({
    required this.schedule,
    required this.roomName,
    required this.now,
  });

  final Schedule schedule;
  final String roomName;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final phase = schedulePhase(schedule, now);
    final status = switch (phase) {
      SchedulePhase.active => 'Sedang Berlangsung',
      SchedulePhase.upcoming => 'Akan Datang',
      SchedulePhase.finished => 'Selesai',
      SchedulePhase.inactive => 'Dibatalkan',
    };
    final badgeColor = phase == SchedulePhase.active
        ? AppColors.primary
        : const Color(0xFF303A46);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1721),
        border: Border.all(color: const Color(0xFF162431)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              _scheduleTime(schedule),
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 3,
            height: 38,
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF26B5FF),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.activityName.isEmpty
                      ? 'Nama kegiatan tidak tersedia'
                      : schedule.activityName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  roomName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            constraints: const BoxConstraints(
              maxWidth: 112,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              status,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(
    this.text, {
    this.actionLabel,
    this.onAction,
  });

  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.muted,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontSize: 11),
              ),
            ),
        ],
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
        ),
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

List<ActivityItem> _activityItems(
  List<ActivityLog> logs,
  List<Room> rooms,
) {
  final roomNames = {
    for (final room in rooms) room.idRoom: room.roomName,
  };
  final sortedLogs = [...logs]
    ..sort((left, right) {
      final leftDate = left.createdAt;
      final rightDate = right.createdAt;
      if (leftDate == null && rightDate == null) {
        return 0;
      }
      if (leftDate == null) {
        return 1;
      }
      if (rightDate == null) {
        return -1;
      }
      return rightDate.compareTo(leftDate);
    });

  return sortedLogs.map((log) {
    final text = '${log.activityType} ${log.description}'
        .toLowerCase();
    final iconName =
        text.contains('mode') || text.contains('manual')
        ? 'setting-done-02.svg'
        : text.contains('schedule') ||
              text.contains('jadwal')
        ? 'date-time.svg'
        : 'power.svg';
    final createdAt = log.createdAt;
    final timeLabel = createdAt == null
        ? '--.--'
        : '${createdAt.hour.toString().padLeft(2, '0')}.'
              '${createdAt.minute.toString().padLeft(2, '0')}';
    return ActivityItem(
      timeLabel: timeLabel,
      title: roomNames[log.idRoom] ?? 'Aktivitas',
      description: log.description,
      source: log.source,
      iconName: iconName,
    );
  }).toList();
}

String _scheduleTime(Schedule schedule) {
  final start = clockLabel(schedule.startTime) ?? '--.--';
  final end = clockLabel(schedule.endTime);
  return end == null ? start : '$start\n- $end';
}
