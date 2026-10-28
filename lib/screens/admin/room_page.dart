import 'package:flutter/material.dart';

import '../../models/device.dart';
import '../../models/room.dart';
import '../../models/schedule.dart';
import '../../network/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/device_service.dart';
import '../../services/room_service.dart';
import '../../services/schedule_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/templates/room_monitor_template.dart';
import '../login/login_screen.dart';
import 'manage_room_screen.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final RoomService _roomService = RoomService();
  final DeviceService _deviceService = DeviceService();
  final ScheduleService _scheduleService =
      ScheduleService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController =
      TextEditingController();

  List<Room> _rooms = const [];
  Map<int, int> _devicesOn = const {};
  Map<int, int> _deviceTotals = const {};
  bool _devicesReady = false;
  List<Schedule> _schedules = const [];
  bool _schedulesReady = false;
  bool _loading = true;
  String? _errorMessage;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final rooms = await _roomService.getRooms();
      var devicesReady = true;
      var devices = const <Device>[];
      try {
        devices = await _deviceService.getDevices();
      } on ApiException {
        devicesReady = false;
      }
      var schedulesReady = true;
      var schedules = const <Schedule>[];
      try {
        schedules = await _scheduleService.getSchedules();
      } on ApiException {
        schedulesReady = false;
      }
      if (!mounted) {
        return;
      }
      final totals = <int, int>{};
      final onCounts = <int, int>{};
      if (devicesReady) {
        for (final device in devices) {
          final roomId = device.idRoom;
          if (roomId == null) {
            continue;
          }
          totals[roomId] = (totals[roomId] ?? 0) + 1;
          if (device.isOn) {
            onCounts[roomId] = (onCounts[roomId] ?? 0) + 1;
          }
        }
      }
      setState(() {
        _rooms = rooms;
        _devicesReady = devicesReady;
        _deviceTotals = totals;
        _devicesOn = onCounts;
        _schedulesReady = schedulesReady;
        _schedules = schedules;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      if (error.unauthorized) {
        await _goToLogin();
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = 'Data ruangan gagal dimuat.';
      });
    }
  }

  List<Room> get _visibleRooms {
    final query = _searchController.text
        .trim()
        .toLowerCase();
    return _rooms.where((room) {
      final matchesFilter = switch (_filter) {
        'Auto' => room.operationMode == 'AUTO',
        'Manual' => room.operationMode == 'MANUAL',
        'Active' => room.isEnabled,
        'Inactive' => room.systemStatus == 'DISABLED',
        _ => true,
      };
      if (!matchesFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return room.roomName.toLowerCase().contains(query) ||
          room.building.toLowerCase().contains(query) ||
          room.floor.toLowerCase().contains(query);
    }).toList();
  }

  bool get _hasActiveQuery =>
      _searchController.text.trim().isNotEmpty ||
      _filter != 'All';

  List<RoomMonitorView> get _views {
    final now = DateTime.now();
    return [
      for (final room in _visibleRooms)
        RoomMonitorView(
          room: room,
          deviceLabel: _devicesReady
              ? '${_devicesOn[room.idRoom] ?? 0}/${_deviceTotals[room.idRoom] ?? 0}'
              : '--',
          scheduleTime: _scheduleTime(room.idRoom, now),
          scheduleCaption: _scheduleCaption(
            room.idRoom,
            now,
          ),
        ),
    ];
  }

  String _scheduleTime(int roomId, DateTime now) {
    if (!_schedulesReady) {
      return '--';
    }
    final match = _scheduleMatch(roomId, now);
    if (match == null) {
      return '--';
    }
    return _clockRange(
      match.schedule.startTime,
      match.schedule.endTime,
    );
  }

  String _scheduleCaption(int roomId, DateTime now) {
    if (!_schedulesReady) {
      return 'Schedule';
    }
    final match = _scheduleMatch(roomId, now);
    if (match == null) {
      return 'No schedule';
    }
    return match.current
        ? 'Current Schedule'
        : 'Next Schedule';
  }

  _ScheduleMatch? _scheduleMatch(int roomId, DateTime now) {
    final today = _schedules.where(
      (schedule) =>
          !schedule.isCancelled &&
          schedule.idRoom == roomId &&
          _isToday(schedule, now),
    );
    _ScheduleMatch? upcoming;
    for (final schedule in today) {
      final start = _minutes(schedule.startTime);
      final end = _minutes(schedule.endTime);
      final current = now.hour * 60 + now.minute;
      if (start != null &&
          end != null &&
          current >= start &&
          current <= end) {
        return _ScheduleMatch(schedule, current: true);
      }
      if (start != null && start > current) {
        final nextStart = upcoming == null
            ? null
            : _minutes(upcoming.schedule.startTime);
        if (nextStart == null || start < nextStart) {
          upcoming = _ScheduleMatch(
            schedule,
            current: false,
          );
        }
      }
    }
    return upcoming;
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() => _filter = 'All');
  }

  Future<void> _openManageRoom() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManageRoomScreen(
          openedFromRoomPage: true,
        ),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  void _onNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).pop();
      return;
    }
    if (index == 1) {
      return;
    }
    const names = {2: 'Schedule', 3: 'Profile'};
    final name = names[index];
    if (name == null || !mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Halaman $name belum tersedia.'),
        ),
      );
  }

  Future<void> _goToLogin() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = _rooms
        .where((room) => room.isEnabled)
        .length;
    final inactive = _rooms
        .where((room) => room.systemStatus == 'DISABLED')
        .length;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RoomMonitorTemplate(
        searchController: _searchController,
        onSearchChanged: (_) => setState(() {}),
        onClearSearch: () {
          _searchController.clear();
          setState(() {});
        },
        filter: _filter,
        onFilterSelected: (value) {
          setState(() => _filter = value);
        },
        totalRooms: _rooms.length,
        activeRooms: active,
        inactiveRooms: inactive,
        rooms: _loading || _errorMessage != null
            ? const []
            : _views,
        loading: _loading,
        errorMessage: _errorMessage,
        hasActiveQuery: _hasActiveQuery,
        onManageRoom: _openManageRoom,
        onRetry: _load,
        onClearQuery: _clearQuery,
        onNavSelected: _onNavSelected,
      ),
    );
  }
}

class _ScheduleMatch {
  const _ScheduleMatch(
    this.schedule, {
    required this.current,
  });

  final Schedule schedule;
  final bool current;
}

bool _isToday(Schedule schedule, DateTime now) {
  final date = schedule.scheduleDate;
  if (date != null) {
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  const names = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  return schedule.dayOfWeek == names[now.weekday - 1];
}

int? _minutes(String? value) {
  if (value == null || !value.contains(':')) {
    return null;
  }
  final parts = value.split(':');
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  return hour * 60 + minute;
}

String _clockRange(String? start, String? end) {
  String? clock(String? value) {
    final minutes = _minutes(value);
    if (minutes == null) {
      return null;
    }
    final hour = minutes ~/ 60;
    final minute = (minutes % 60).toString().padLeft(
      2,
      '0',
    );
    return '$hour.$minute';
  }

  final left = clock(start);
  final right = clock(end);
  if (left == null && right == null) {
    return '--';
  }
  return '${left ?? '--'} - ${right ?? '--'}';
}
