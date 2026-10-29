import 'package:flutter/material.dart';

import '../../models/device.dart';
import '../../models/room.dart';
import '../../network/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/device_service.dart';
import '../../services/room_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/templates/manage_device_template.dart';
import '../../storage/token_storage.dart';
import '../login/login_screen.dart';
import 'device_form_screen.dart';

class ManageDeviceScreen extends StatefulWidget {
  const ManageDeviceScreen({super.key});

  @override
  State<ManageDeviceScreen> createState() =>
      _ManageDeviceScreenState();
}

class _ManageDeviceScreenState
    extends State<ManageDeviceScreen> {
  final DeviceService _deviceService = DeviceService();
  final RoomService _roomService = RoomService();
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();
  final TextEditingController _searchController =
      TextEditingController();

  List<Device> _devices = const [];
  List<Room> _rooms = const [];
  bool _loading = true;
  bool _unauthorized = false;
  String? _errorMessage;
  String _query = '';
  String _typeFilter = 'All';
  String _statusFilter = '';
  final Set<int> _busyIds = {};

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
      if (role != 'ADMIN') {
        if (!mounted) {
          return;
        }
        setState(() {
          _loading = false;
          _errorMessage =
              'Anda tidak memiliki akses ke data ini.';
        });
        return;
      }
      final devices = await _deviceService.getDevices();
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
        _devices = devices;
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
        _errorMessage = 'Data perangkat gagal dimuat.';
      });
    }
  }

  List<Device> get _visibleDevices {
    final query = _query.trim().toLowerCase();
    return _devices.where((device) {
      final matchesType =
          _typeFilter == 'All' ||
          device.deviceType == _typeFilter;
      if (!matchesType) {
        return false;
      }
      final matchesStatus = switch (_statusFilter) {
        'Enabled' => device.isEnabled != false,
        'Disabled' => device.isEnabled == false,
        _ => true,
      };
      if (!matchesStatus) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final room = _roomLabel(device).toLowerCase();
      return device.deviceName.toLowerCase().contains(
            query,
          ) ||
          device.deviceCode.toLowerCase().contains(query) ||
          room.contains(query);
    }).toList();
  }

  bool get _hasActiveQuery =>
      _query.trim().isNotEmpty ||
      _typeFilter != 'All' ||
      _statusFilter.isNotEmpty;

  String _roomLabel(Device device) {
    for (final room in _rooms) {
      if (room.idRoom == device.idRoom) {
        return room.scheduleOption;
      }
    }
    return 'Ruangan tidak tersedia';
  }

  Future<void> _openForm(Device? device) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => DeviceFormScreen(device: device),
      ),
    );
    if (saved == true) {
      await _load();
    }
  }

  Future<void> _toggleEnabled(Device device) async {
    if (_busyIds.contains(device.idDevice)) {
      return;
    }
    final next = device.isEnabled == false;
    setState(() => _busyIds.add(device.idDevice));
    try {
      await _deviceService.updateEnabled(
        idDevice: device.idDevice,
        isEnabled: next,
      );
      if (!mounted) {
        return;
      }
      _message(
        next
            ? 'Perangkat diaktifkan.'
            : 'Perangkat dinonaktifkan.',
      );
      await _load();
    } on ApiException catch (error) {
      if (error.unauthorized) {
        await _goToLogin();
        return;
      }
      _message(error.message);
    } catch (_) {
      _message('Status perangkat gagal diubah.');
    } finally {
      if (mounted) {
        setState(() => _busyIds.remove(device.idDevice));
      }
    }
  }

  Future<void> _delete(Device device) async {
    if (_busyIds.contains(device.idDevice)) {
      return;
    }
    final name = device.deviceName.isEmpty
        ? 'perangkat ini'
        : device.deviceName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Hapus perangkat?'),
          content: Text(
            '"$name" akan dihapus. Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _busyIds.add(device.idDevice));
    try {
      await _deviceService.deleteDevice(device.idDevice);
      if (!mounted) {
        return;
      }
      _message('Perangkat berhasil dihapus.');
      await _load();
    } on ApiException catch (error) {
      if (error.unauthorized) {
        await _goToLogin();
        return;
      }
      _message(error.message);
    } catch (_) {
      _message('Perangkat gagal dihapus.');
    } finally {
      if (mounted) {
        setState(() => _busyIds.remove(device.idDevice));
      }
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

  void _message(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final enabledCount = _devices
        .where((device) => device.isEnabled != false)
        .length;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ManageDeviceTemplate(
        searchController: _searchController,
        onSearchChanged: (value) =>
            setState(() => _query = value),
        onClearSearch: () {
          _searchController.clear();
          setState(() => _query = '');
        },
        typeFilter: _typeFilter,
        statusFilter: _statusFilter,
        onType: (value) =>
            setState(() => _typeFilter = value),
        onStatus: (value) =>
            setState(() => _statusFilter = value),
        devices: _visibleDevices,
        roomLabel: _roomLabel,
        total: _devices.length,
        enabledCount: enabledCount,
        disabledCount: _devices.length - enabledCount,
        lampCount: _devices
            .where((device) => device.deviceType == 'LAMP')
            .length,
        acCount: _devices
            .where((device) => device.deviceType == 'AC')
            .length,
        projectorCount: _devices
            .where(
              (device) => device.deviceType == 'PROJECTOR',
            )
            .length,
        loading: _loading,
        errorMessage: _errorMessage,
        unauthorized: _unauthorized,
        busyIds: _busyIds,
        hasActiveQuery: _hasActiveQuery,
        onBack: () => Navigator.of(context).maybePop(),
        onAdd: () => _openForm(null),
        onRetry: _load,
        onLogin: _goToLogin,
        onEdit: _openForm,
        onDelete: _delete,
        onToggleEnabled: _toggleEnabled,
      ),
    );
  }
}
