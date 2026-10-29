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
import '../../shared/widgets/organisms/smart_bottom_nav.dart';
import '../../shared/widgets/templates/admin_home_template.dart';
import '../../storage/token_storage.dart';
import '../login/login_screen.dart';
import 'admin_home_data.dart';
import 'manage_room_screen.dart';
import '../schedule/schedule_page.dart';
import 'room_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() =>
      _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
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
    });
    try {
      final token = await _tokenStorage.getAccessToken();
      final name = token == null
          ? null
          : _authService.fullNameFromAccessToken(token);
      if (mounted && name != null && name.isNotEmpty) {
        setState(() => _displayName = name);
      }
      final results = await Future.wait<Object>([
        _roomService.getRooms(),
        _deviceService.getDevices(),
        _scheduleService.getSchedules(),
        _activityLogService.getActivityLogs(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _displayName = name;
        _data = AdminHomeData.fromSources(
          rooms: results[0] as List<Room>,
          devices: results[1] as List<Device>,
          schedules: results[2] as List<Schedule>,
          logs: results[3] as List<ActivityLog>,
          now: DateTime.now(),
        );
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

  void _showUnavailable(String pageName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Halaman $pageName belum tersedia.',
          ),
        ),
      );
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

  Future<void> _openManageRoom() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManageRoomScreen(),
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

  void _onQuickAccess(String pageName) {
    if (pageName == 'kelola ruangan') {
      _openManageRoom();
      return;
    }
    if (pageName == 'kelola jadwal') {
      _openSchedulePage();
      return;
    }
    _showUnavailable(pageName);
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
    const unavailable = <int, String>{3: 'Profile'};
    final pageName = unavailable[index];
    if (pageName == null) {
      return;
    }
    _showUnavailable(pageName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: AdminHomeTemplate(
              displayName: _displayName,
              loading: _loading,
              errorMessage: _errorMessage,
              unauthorized: _unauthorized,
              data: _data,
              onNotification: () =>
                  _showUnavailable('notifikasi'),
              onRetry: _load,
              onLogin: _goToLogin,
              onQuickAccess: _onQuickAccess,
            ),
          ),
          SmartBottomNav(
            currentIndex: 0,
            onSelected: _onNavSelected,
            items: adminBottomNavItems,
          ),
        ],
      ),
    );
  }
}
