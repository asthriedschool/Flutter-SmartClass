import 'package:flutter/material.dart';

import '../../models/device.dart';
import '../../models/room.dart';
import '../../network/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/device_service.dart';
import '../../services/room_service.dart';
import '../../shared/widgets/templates/manage_room_template.dart';
import '../login/login_screen.dart';
import 'room_form_screen.dart';
import '../schedule/schedule_page.dart';
import 'room_page.dart';

class ManageRoomScreen extends StatefulWidget {
  const ManageRoomScreen({super.key});

  @override
  State<ManageRoomScreen> createState() =>
      _ManageRoomScreenState();
}

class _ManageRoomScreenState
    extends State<ManageRoomScreen> {
  final RoomService _roomService = RoomService();
  final DeviceService _deviceService = DeviceService();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController =
      TextEditingController();

  List<Room> _rooms = const [];
  Map<int, int> _deviceTotals = const {};
  Map<int, int> _lampCounts = const {};
  Map<int, int> _acCounts = const {};
  Map<int, int> _projectorCounts = const {};
  bool _devicesReady = false;
  bool _loading = true;
  String? _errorMessage;
  String _filter = 'All';
  final Set<int> _busyRoomIds = {};

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
      if (!mounted) {
        return;
      }
      final totals = <int, int>{};
      final lamps = <int, int>{};
      final acs = <int, int>{};
      final projectors = <int, int>{};
      if (devicesReady) {
        for (final device in devices) {
          final roomId = device.idRoom;
          if (roomId == null) {
            continue;
          }
          totals[roomId] = (totals[roomId] ?? 0) + 1;
          switch (device.deviceType) {
            case 'LAMP':
              lamps[roomId] = (lamps[roomId] ?? 0) + 1;
            case 'AC':
              acs[roomId] = (acs[roomId] ?? 0) + 1;
            case 'PROJECTOR':
              projectors[roomId] =
                  (projectors[roomId] ?? 0) + 1;
          }
        }
      }
      setState(() {
        _rooms = rooms;
        _devicesReady = devicesReady;
        _deviceTotals = totals;
        _lampCounts = lamps;
        _acCounts = acs;
        _projectorCounts = projectors;
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
        'Enabled' => room.isEnabled,
        'Disabled' => room.systemStatus == 'DISABLED',
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

  Future<void> _openForm(Room? room) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => RoomFormScreen(
          room: room,
          lampCount: room == null
              ? 0
              : !_devicesReady
              ? null
              : _lampCounts[room.idRoom] ?? 0,
          acCount: room == null
              ? 0
              : !_devicesReady
              ? null
              : _acCounts[room.idRoom] ?? 0,
          projectorCount: room == null
              ? 0
              : !_devicesReady
              ? null
              : _projectorCounts[room.idRoom] ?? 0,
        ),
      ),
    );
    if (saved == true) {
      await _load();
    }
  }

  Future<void> _delete(Room room) async {
    if (_busyRoomIds.contains(room.idRoom)) {
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF272829),
          title: const Text('Delete room?'),
          content: Text(
            'Hapus ${room.roomName}? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _busyRoomIds.add(room.idRoom));
    try {
      await _roomService.deleteRoom(room.idRoom);
      _showMessage('Ruangan dihapus.');
      await _load();
    } on ApiException catch (error) {
      if (error.unauthorized) {
        await _goToLogin();
        return;
      }
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Ruangan gagal dihapus.');
    } finally {
      if (mounted) {
        setState(() => _busyRoomIds.remove(room.idRoom));
      }
    }
  }

  Future<void> _toggleStatus(Room room) async {
    if (_busyRoomIds.contains(room.idRoom)) {
      return;
    }
    final next = room.isEnabled ? 'DISABLED' : 'ENABLED';
    setState(() => _busyRoomIds.add(room.idRoom));
    try {
      await _roomService.updateSystemStatus(
        idRoom: room.idRoom,
        systemStatus: next,
      );
      _showMessage(
        next == 'ENABLED'
            ? 'Ruangan diaktifkan.'
            : 'Ruangan dinonaktifkan.',
      );
      await _load();
    } on ApiException catch (error) {
      if (error.unauthorized) {
        await _goToLogin();
        return;
      }
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Status ruangan gagal diubah.');
    } finally {
      if (mounted) {
        setState(() => _busyRoomIds.remove(room.idRoom));
      }
    }
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() => _filter = 'All');
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onNavSelected(int index) {
    if (index == 0) {
      Navigator.of(context).pop();
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
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SchedulePage(),
        ),
      );
      return;
    }
    const names = {3: 'Profile'};
    final name = names[index];
    if (name != null) {
      _showMessage('Halaman $name belum tersedia.');
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
    return Scaffold(
      backgroundColor: const Color(0xFF050607),
      body: ManageRoomTemplate(
        searchController: _searchController,
        onSearchChanged: (_) => setState(() {}),
        onClearSearch: _clearQuery,
        filter: _filter,
        onFilterSelected: (value) {
          setState(() => _filter = value);
        },
        rooms: _visibleRooms,
        deviceTotals: _deviceTotals,
        lampCounts: _lampCounts,
        acCounts: _acCounts,
        projectorCounts: _projectorCounts,
        devicesReady: _devicesReady,
        loading: _loading,
        errorMessage: _errorMessage,
        busyRoomIds: _busyRoomIds,
        hasActiveQuery: _hasActiveQuery,
        onBack: () => Navigator.of(context).pop(),
        onAdd: () => _openForm(null),
        onRetry: _load,
        onEdit: _openForm,
        onDelete: _delete,
        onToggleStatus: _toggleStatus,
        onNavSelected: _onNavSelected,
      ),
    );
  }
}
