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

  void _onNavSelected(int index) {
    const unavailable = <int, String>{
      1: 'Room',
      2: 'Schedule',
      3: 'Profile',
    };
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
              onQuickAccess: _showUnavailable,
            ),
          ),
          SmartBottomNav(
            currentIndex: 0,
            onSelected: _onNavSelected,
            items: const [
              SmartNavItem(
                label: 'Home',
                activeAsset: 'assets/asset_navbar/home/home_active.svg',
                inactiveAsset: 'assets/asset_navbar/home/home_inactive.svg',
              ),
              SmartNavItem(
                label: 'Room',
                activeAsset: 'assets/asset_navbar/room/room_active.png',
                inactiveAsset: 'assets/asset_navbar/room/room_inactive.svg',
              ),
              SmartNavItem(
                label: 'Schedule',
                activeAsset: 'assets/asset_navbar/schedule/schedule_active.png',
                inactiveAsset: 'assets/asset_navbar/schedule/schedule_inactive.svg',
              ),
              SmartNavItem(
                label: 'Account',
                activeAsset: 'assets/asset_navbar/profile/profile_active.svg',
                inactiveAsset: 'assets/asset_navbar/profile/profile_inactive.svg',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
