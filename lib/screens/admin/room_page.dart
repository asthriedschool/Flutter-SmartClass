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
import '../../shared/widgets/atoms/asset_image.dart';
import '../../shared/widgets/molecules/room_search_field.dart';
import '../../shared/widgets/organisms/smart_bottom_nav.dart';
import '../../storage/token_storage.dart';
import '../login/login_screen.dart';
import 'manage_room_screen.dart';
import 'room_detail_page.dart';
import '../profile/profile_page.dart';
import '../schedule/schedule_page.dart';
import 'room_schedule.dart';

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
  final TokenStorage _tokenStorage = TokenStorage();
  final TextEditingController _searchController =
      TextEditingController();

  List<Room> _rooms = const [];
  Map<int, int> _on = const {};
  Map<int, int> _total = const {};
  bool _devicesReady = false;
  List<Schedule> _schedules = const [];
  bool _schedulesReady = false;
  bool _loading = true;
  String? _errorMessage;
  String _filter = 'All';
  bool _isAdmin = false;

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
      final token = await _tokenStorage.getAccessToken();
      final role = token == null
          ? null
          : _authService.roleFromAccessToken(token);
      if (mounted) {
        setState(() => _isAdmin = role == 'ADMIN');
      }
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
        _total = totals;
        _on = onCounts;
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

  List<Room> get _visible {
    final query = _searchController.text
        .trim()
        .toLowerCase();
    return _rooms.where((room) {
      final matches = switch (_filter) {
        'Auto' => room.operationMode == 'AUTO',
        'Manual' => room.operationMode == 'MANUAL',
        'Active' => room.isEnabled,
        'Inactive' => room.systemStatus == 'DISABLED',
        _ => true,
      };
      if (!matches) {
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

  Future<void> _openDetail(Room room) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoomDetailPage(room: room),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  Future<void> _openManage() async {
    if (!_isAdmin) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const ManageRoomScreen(),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  void _onNav(int index) {
    if (index == 0) {
      Navigator.of(context).pop();
      return;
    }
    if (index == 1) {
      return;
    }
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SchedulePage(),
        ),
      );
      return;
    }
    if (index == 3) {
      ProfilePage.open(context);
    }
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
    final rooms = _visible;
    final active = _rooms
        .where((room) => room.isEnabled)
        .length;
    final inactive = _rooms
        .where((room) => room.systemStatus == 'DISABLED')
        .length;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: DecoratedBox(
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
        child: Column(
          children: [
            Expanded(
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
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Room',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 32,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Monitor all smart classroom',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isAdmin)
                            OutlinedButton.icon(
                              onPressed: _openManage,
                              icon: const LocalAssetImage(
                                directory: berandaAssetDir,
                                name: 'ManageRoom.svg',
                                width: 14,
                                height: 16,
                                semanticLabel: 'Manage Room',
                              ),
                              label: const Text(
                                'Manage Room',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(
                                  0xFF3DB7FF,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFF3DB7FF),
                                ),
                                visualDensity:
                                    VisualDensity.compact,
                                shape: const StadiumBorder(),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      RoomSearchField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        onClear: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _loading
                            ? const Center(
                                child:
                                    CircularProgressIndicator(
                                      color:
                                          AppColors.primary,
                                    ),
                              )
                            : _errorMessage != null
                            ? Center(
                                child: TextButton(
                                  onPressed: _load,
                                  child: Text(
                                    _errorMessage!,
                                  ),
                                ),
                              )
                            : ListView(
                                padding:
                                    const EdgeInsets.only(
                                      bottom: 16,
                                    ),
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection:
                                        Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for (final label
                                            in [
                                              'All',
                                              'Auto',
                                              'Manual',
                                              'Active',
                                              'Inactive',
                                            ])
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                            child: ChoiceChip(
                                              label: Text(
                                                label,
                                              ),
                                              selected:
                                                  _filter ==
                                                  label,
                                              onSelected: (_) {
                                                setState(
                                                  () => _filter =
                                                      label,
                                                );
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Text(
                                    '${_rooms.length} Rooms · $active Active · $inactive Inactive',
                                    style: const TextStyle(
                                      color:
                                          AppColors.muted,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  if (rooms.isEmpty)
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(
                                            top: 32,
                                          ),
                                      child: Text(
                                        'No rooms found',
                                        textAlign: TextAlign
                                            .center,
                                        style: TextStyle(
                                          color: AppColors
                                              .text,
                                        ),
                                      ),
                                    )
                                  else
                                    for (final room
                                        in rooms) ...[
                                      _RoomCard(
                                        room: room,
                                        devices:
                                            _devicesReady
                                            ? '${_on[room.idRoom] ?? 0}/${_total[room.idRoom] ?? 0}'
                                            : '--',
                                        schedule: roomScheduleInfo(
                                          schedules:
                                              _schedules,
                                          roomId:
                                              room.idRoom,
                                          now:
                                              DateTime.now(),
                                          ready:
                                              _schedulesReady,
                                        ),
                                        onTap: () =>
                                            _openDetail(
                                              room,
                                            ),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                    ],
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SmartBottomNav(
              currentIndex: 1,
              items: adminBottomNavItems,
              onSelected: _onNav,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.room,
    required this.devices,
    required this.schedule,
    required this.onTap,
  });

  final Room room;
  final String devices;
  final RoomScheduleInfo schedule;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final url = room.picture?.trim() ?? '';
    final network =
        url.startsWith('http://') ||
        url.startsWith('https://');
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 148,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (network)
                  Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      'assets/asset_login_page/FotoKelas.png',
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Image.asset(
                    'assets/asset_login_page/FotoKelas.png',
                    fit: BoxFit.cover,
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xE60B3A5C),
                        Color(0xCC0E4E78),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.roomName,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        room.operationMode == 'MANUAL'
                            ? 'MANUAL'
                            : room.operationMode == 'AUTO'
                            ? 'AUTO MODE'
                            : room.operationMode,
                        style: const TextStyle(
                          color: AppColors.text,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$devices Device ON',
                        style: const TextStyle(
                          color: AppColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${schedule.time}  ${schedule.caption}',
                        style: const TextStyle(
                          color: Color(0xFFD5DDE6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
