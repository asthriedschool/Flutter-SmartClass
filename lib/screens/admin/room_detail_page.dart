import 'package:flutter/material.dart';

import '../../models/device.dart';
import '../../models/room.dart';
import '../../models/schedule.dart';
import '../../network/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/device_command_service.dart';
import '../../services/device_service.dart';
import '../../services/room_service.dart';
import '../../services/schedule_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/organisms/room_detail_body.dart';
import '../../shared/widgets/organisms/smart_bottom_nav.dart';
import '../login/login_screen.dart';
import 'room_schedule.dart';

class RoomDetailPage extends StatefulWidget {
  const RoomDetailPage({super.key, required this.room});

  final Room room;

  @override
  State<RoomDetailPage> createState() =>
      _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final RoomService _roomService = RoomService();
  final DeviceService _deviceService = DeviceService();
  final ScheduleService _scheduleService =
      ScheduleService();
  final DeviceCommandService _commandService =
      DeviceCommandService();
  final AuthService _authService = AuthService();

  late Room _room;
  List<Device> _devices = const [];
  bool _devicesReady = false;
  RoomScheduleInfo _schedule = const RoomScheduleInfo(
    time: '--',
    caption: 'Schedule',
  );
  bool _loading = true;
  String? _errorMessage;
  bool _switching = false;
  final Set<int> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final rooms = await _roomService.getRooms();
      final match = rooms.where(
        (room) => room.idRoom == widget.room.idRoom,
      );
      if (match.isEmpty) {
        throw const ApiException(
          'Ruangan tidak ditemukan.',
        );
      }
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
      setState(() {
        _room = match.first;
        _devicesReady = devicesReady;
        _devices = devices
            .where(
              (device) => device.idRoom == _room.idRoom,
            )
            .toList();
        _schedule = roomScheduleInfo(
          schedules: schedules,
          roomId: _room.idRoom,
          now: DateTime.now(),
          ready: schedulesReady,
        );
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
        _errorMessage = 'Detail ruangan gagal dimuat.';
      });
    }
  }

  Future<void> _switchMode() async {
    if (_switching) {
      return;
    }
    final next = _room.operationMode == 'MANUAL'
        ? 'AUTO'
        : 'MANUAL';
    setState(() => _switching = true);
    try {
      final updated = await _roomService
          .updateOperationMode(
            idRoom: _room.idRoom,
            operationMode: next,
          );
      if (!mounted) {
        return;
      }
      setState(() => _room = updated);
    } on ApiException catch (error) {
      if (error.unauthorized) {
        await _goToLogin();
        return;
      }
      _message(error.message);
    } catch (_) {
      _message('Mode ruangan gagal diubah.');
    } finally {
      if (mounted) {
        setState(() => _switching = false);
      }
    }
  }

  Future<void> _toggle(Device device) async {
    if (_room.operationMode != 'MANUAL' ||
        _busyIds.contains(device.idDevice) ||
        device.isEnabled == false) {
      return;
    }
    final next = device.isOn ? 'OFF' : 'ON';
    setState(() => _busyIds.add(device.idDevice));
    try {
      await _commandService.createCommand(
        idDevice: device.idDevice,
        command: next,
      );
      final updated = await _deviceService.updateStatus(
        idDevice: device.idDevice,
        status: next,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _devices = [
          for (final item in _devices)
            if (item.idDevice == updated.idDevice)
              updated
            else
              item,
        ];
      });
    } on ApiException catch (error) {
      if (error.unauthorized) {
        await _goToLogin();
        return;
      }
      _message(error.message);
    } catch (_) {
      _message('Perintah perangkat gagal dikirim.');
    } finally {
      if (mounted) {
        setState(() => _busyIds.remove(device.idDevice));
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

  void _onNav(int index) {
    if (index == 0) {
      Navigator.of(context)
          .popUntil((route) => route.isFirst);
      return;
    }
    if (index == 1) {
      Navigator.of(context).pop();
      return;
    }
    const names = {2: 'Schedule', 3: 'Profile'};
    final name = names[index];
    if (name != null) {
      _message('Halaman $name belum tersedia.');
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
    final manual = _room.operationMode == 'MANUAL';
    final onCount = _devices
        .where((device) => device.isOn)
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
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppColors.text,
                              ),
                            ),
                            TextButton(
                              onPressed: _load,
                              child: const Text(
                                'Coba lagi',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          16,
                        ),
                        children: [
                          RoomDetailHeader(
                            onBack: () =>
                                Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 12),
                          RoomDetailBanner(
                            name: _room.roomName,
                            modeLabel: manual
                                ? 'Manual'
                                : _room.operationMode ==
                                      'AUTO'
                                ? 'AUTO MODE'
                                : _room.operationMode,
                            statusLabel: _room.isEnabled
                                ? 'Active'
                                : _room.systemStatus ==
                                      'DISABLED'
                                ? 'Inactive'
                                : _room.systemStatus,
                            active: _room.isEnabled,
                            pictureUrl: _room.picture,
                            deviceLabel: _devicesReady
                                ? '$onCount/${_devices.length}'
                                : '--',
                            scheduleTime: _schedule.time,
                            scheduleCaption:
                                _schedule.caption,
                          ),
                          const SizedBox(height: 18),
                          if (manual)
                            ManualControlSection(
                              devices: _devices,
                              busyIds: _busyIds,
                              switching: _switching,
                              onToggle: _toggle,
                              onSwitchMode: _switchMode,
                            )
                          else
                            DeviceStatusSection(
                              devices: _devices,
                              switching: _switching,
                              onSwitchMode: _switchMode,
                            ),
                        ],
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
