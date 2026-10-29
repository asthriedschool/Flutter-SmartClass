import 'package:flutter/material.dart';

import '../../models/device.dart';
import '../../models/room.dart';
import '../../network/api_client.dart';
import '../../services/device_service.dart';
import '../../services/room_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/templates/device_form_template.dart';

class DeviceFormScreen extends StatefulWidget {
  const DeviceFormScreen({super.key, this.device});

  final Device? device;

  @override
  State<DeviceFormScreen> createState() =>
      _DeviceFormScreenState();
}

class _DeviceFormScreenState
    extends State<DeviceFormScreen> {
  final DeviceService _deviceService = DeviceService();
  final RoomService _roomService = RoomService();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;

  List<Room> _rooms = const [];
  bool _loadingRooms = true;
  bool _saving = false;
  String? _errorMessage;
  int? _roomId;
  late String _type;
  late bool _enabled;

  bool get _editing => widget.device != null;

  @override
  void initState() {
    super.initState();
    final device = widget.device;
    _nameController = TextEditingController(
      text: device?.deviceName ?? '',
    );
    _codeController = TextEditingController(
      text: device?.deviceCode ?? '',
    );
    _roomId = device?.idRoom;
    _type = deviceTypes.contains(device?.deviceType)
        ? device!.deviceType
        : 'LAMP';
    _enabled = device?.isEnabled != false;
    _loadRooms();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _loadingRooms = true;
      _errorMessage = null;
    });
    try {
      final rooms = await _roomService.getRooms();
      if (!mounted) {
        return;
      }
      setState(() {
        _rooms = rooms;
        _loadingRooms = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingRooms = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadingRooms = false;
        _errorMessage = 'Data ruangan gagal dimuat.';
      });
    }
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();
    final message = _validate(name, code);
    if (message != null) {
      _message(message);
      return;
    }
    setState(() => _saving = true);
    try {
      final existing = widget.device;
      if (existing == null) {
        await _deviceService.createDevice(
          idRoom: _roomId!,
          deviceName: name,
          deviceCode: code,
          deviceType: _type,
          isEnabled: _enabled,
        );
      } else {
        await _deviceService.updateDevice(
          current: existing,
          idRoom: _roomId!,
          deviceName: name,
          deviceCode: code,
          deviceType: _type,
          isEnabled: _enabled,
        );
      }
      if (!mounted) {
        return;
      }
      _message(
        existing == null
            ? 'Perangkat berhasil ditambahkan.'
            : 'Perangkat berhasil diperbarui.',
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Perangkat gagal disimpan.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? _validate(String name, String code) {
    if (name.isEmpty) {
      return 'Nama perangkat wajib diisi.';
    }
    if (name.length > 100) {
      return 'Nama perangkat maksimal 100 karakter.';
    }
    if (code.isEmpty) {
      return 'Kode perangkat wajib diisi.';
    }
    if (code.length > 100) {
      return 'Kode perangkat maksimal 100 karakter.';
    }
    if (_roomId == null) {
      return 'Ruangan wajib dipilih.';
    }
    if (!deviceTypes.contains(_type)) {
      return 'Tipe perangkat wajib dipilih.';
    }
    return null;
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
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: _loadingRooms
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _errorMessage != null
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loadRooms,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            )
          : DeviceFormTemplate(
              editing: _editing,
              saving: _saving,
              rooms: _rooms,
              roomId: _roomId,
              nameController: _nameController,
              codeController: _codeController,
              deviceType: _type,
              enabled: _enabled,
              onBack: () {
                if (!_saving) {
                  Navigator.of(context).maybePop();
                }
              },
              onRoom: (value) =>
                  setState(() => _roomId = value),
              onType: (value) {
                if (value == null) {
                  return;
                }
                setState(() => _type = value);
              },
              onEnabled: (value) =>
                  setState(() => _enabled = value),
              onSave: _save,
            ),
    );
  }
}
