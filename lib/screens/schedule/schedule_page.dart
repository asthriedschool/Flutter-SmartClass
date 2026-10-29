import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../models/schedule.dart';
import '../../network/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/room_service.dart';
import '../../services/schedule_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/organisms/smart_bottom_nav.dart';
import '../../shared/widgets/templates/schedule_template.dart';
import '../../storage/token_storage.dart';
import '../admin/room_page.dart';
import '../profile/profile_page.dart';
import '../login/login_screen.dart';
import 'schedule_form_screen.dart';
import 'schedule_status.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleService _scheduleService =
      ScheduleService();
  final RoomService _roomService = RoomService();
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();
  final TextEditingController _searchController =
      TextEditingController();

  List<Schedule> _schedules = const [];
  List<Room> _rooms = const [];
  bool _loading = true;
  bool _unauthorized = false;
  bool _canManage = false;
  String? _errorMessage;
  String _query = '';
  String _filter = 'All';
  int? _busyId;

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
      _unauthorized = false;
    });
    try {
      final token = await _tokenStorage.getAccessToken();
      final role = token == null
          ? null
          : _authService.roleFromAccessToken(token);
      final schedules = await _scheduleService
          .getSchedules();
      List<Room> rooms = const [];
      try {
        rooms = await _roomService.getRooms();
      } on ApiException {
        rooms = const [];
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _canManage = role == 'ADMIN';
        _schedules = schedules;
        _rooms = rooms;
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
        _errorMessage = 'Data jadwal gagal dimuat.';
      });
    }
  }

  List<Schedule> get _visible {
    final now = DateTime.now();
    final query = _query.trim().toLowerCase();
    return _schedules.where((schedule) {
      if (query.isNotEmpty &&
          !schedule.activityName.toLowerCase().contains(
            query,
          )) {
        return false;
      }
      switch (_filter) {
        case 'Today':
          return scheduleOccursToday(schedule, now);
        case 'Active':
          return schedulePhase(schedule, now) ==
              SchedulePhase.active;
        case 'Upcoming':
          return schedulePhase(schedule, now) ==
              SchedulePhase.upcoming;
        case 'Inactive':
          return schedule.isCancelled;
        default:
          return true;
      }
    }).toList();
  }

  Room? _roomFor(Schedule schedule) {
    for (final room in _rooms) {
      if (room.idRoom == schedule.idRoom) {
        return room;
      }
    }
    return null;
  }

  Future<void> _openForm(Schedule? schedule) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            ScheduleFormScreen(schedule: schedule),
      ),
    );
    if (saved == true && mounted) {
      await _load();
    }
  }

  Future<void> _delete(int id) async {
    if (_busyId != null) {
      return;
    }
    Schedule? schedule;
    for (final item in _schedules) {
      if (item.idSchedule == id) {
        schedule = item;
      }
    }
    if (schedule == null) {
      return;
    }
    final subject = schedule.activityName.isEmpty
        ? 'jadwal ini'
        : schedule.activityName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Hapus jadwal?'),
        content: Text('"$subject" akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _busyId = id);
    try {
      await _scheduleService.deleteSchedule(id);
      if (!mounted) {
        return;
      }
      _message('Jadwal berhasil dihapus.');
      await _load();
    } on ApiException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Jadwal gagal dihapus.');
    } finally {
      if (mounted) {
        setState(() => _busyId = null);
      }
    }
  }

  void _message(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  void _onNav(int index) {
    if (index == 0) {
      Navigator.of(context)
          .popUntil((route) => route.isFirst);
      return;
    }
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const RoomPage(),
        ),
      );
      return;
    }
    if (index == 3) {
      ProfilePage.open(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    var today = 0;
    var active = 0;
    var upcoming = 0;
    var finished = 0;
    for (final schedule in _schedules) {
      if (!schedule.isCancelled &&
          scheduleOccursToday(schedule, now)) {
        today++;
      }
      switch (schedulePhase(schedule, now)) {
        case SchedulePhase.active:
          active++;
        case SchedulePhase.upcoming:
          upcoming++;
        case SchedulePhase.finished:
          finished++;
        case SchedulePhase.inactive:
          break;
      }
    }
    final items = _visible.map((schedule) {
      final room = _roomFor(schedule);
      final mode = room?.operationMode;
      return ScheduleCardData(
        id: schedule.idSchedule,
        roomName:
            room?.roomName ?? 'Ruangan tidak tersedia',
        modeLabel: mode == 'MANUAL'
            ? 'MANUAL'
            : mode == 'AUTO'
            ? 'AUTO'
            : 'Mode tidak tersedia',
        phase: schedulePhase(schedule, now),
        subject: schedule.activityName,
        timeLabel: scheduleClock(
          schedule.startTime,
          schedule.endTime,
        ),
        dateLabel: scheduleDateLabel(schedule),
        lecturerName: schedule.lecturerName,
        pictureUrl: room?.picture,
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ScheduleTemplate(
              loading: _loading,
              errorMessage: _errorMessage,
              unauthorized: _unauthorized,
              canManage: _canManage,
              searchController: _searchController,
              filter: _filter,
              todayCount: today,
              activeCount: active,
              upcomingCount: upcoming,
              finishedCount: finished,
              items: items,
              busyId: _busyId,
              onBack: () =>
                  Navigator.of(context).maybePop(),
              onAdd: () => _openForm(null),
              onSearchChanged: (value) =>
                  setState(() => _query = value),
              onSearchClear: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              onFilter: (value) =>
                  setState(() => _filter = value),
              onRetry: _load,
              onLogin: _goToLogin,
              onEdit: (id) {
                if (_busyId != null) {
                  return;
                }
                for (final schedule in _schedules) {
                  if (schedule.idSchedule == id) {
                    _openForm(schedule);
                    return;
                  }
                }
              },
              onDelete: _delete,
            ),
          ),
          SmartBottomNav(
            currentIndex: 2,
            onSelected: _onNav,
            items: adminBottomNavItems,
          ),
        ],
      ),
    );
  }
}
