import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../network/api_client.dart';
import '../../services/room_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/templates/room_form_template.dart';

class RoomFormScreen extends StatefulWidget {
  const RoomFormScreen({
    super.key,
    this.room,
    this.lampCount,
    this.acCount,
    this.projectorCount,
  });

  final Room? room;
  final int? lampCount;
  final int? acCount;
  final int? projectorCount;

  @override
  State<RoomFormScreen> createState() =>
      _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final RoomService _roomService = RoomService();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _buildingController;
  late final TextEditingController _floorController;
  late final TextEditingController _delayController;
  late String _status;
  late String _mode;
  String? _picture;
  bool _saving = false;

  bool get _editing => widget.room != null;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _nameController = TextEditingController(
      text: room?.roomName ?? '',
    );
    _buildingController = TextEditingController(
      text: room?.building ?? '',
    );
    _floorController = TextEditingController(
      text: room?.floor ?? '',
    );
    _delayController = TextEditingController(
      text: room == null
          ? ''
          : '${room.autoOffDelayMinutes}',
    );
    _status = room?.systemStatus == 'DISABLED'
        ? 'DISABLED'
        : 'ENABLED';
    _mode = room?.operationMode == 'MANUAL'
        ? 'MANUAL'
        : 'AUTO';
    _picture = room?.picture;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _delayController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    try {
      final delay = int.parse(_delayController.text.trim());
      final picture = _picture?.trim();
      final stored = picture == null || picture.isEmpty
          ? null
          : picture;
      if (_editing) {
        await _roomService.updateRoom(
          idRoom: widget.room!.idRoom,
          roomName: _nameController.text,
          building: _buildingController.text,
          floor: _floorController.text,
          systemStatus: _status,
          operationMode: _mode,
          autoOffDelayMinutes: delay,
          picture: stored,
        );
      } else {
        await _roomService.createRoom(
          roomName: _nameController.text,
          building: _buildingController.text,
          floor: _floorController.text,
          systemStatus: _status,
          operationMode: _mode,
          autoOffDelayMinutes: delay,
          picture: stored,
        );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage('Ruangan gagal disimpan.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onPictureAction() {
    _showMessage(
      'Upload file belum tersedia. Server hanya menyimpan referensi picture, bukan file foto.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: RoomFormTemplate(
        editing: _editing,
        saving: _saving,
        formKey: _formKey,
        nameController: _nameController,
        buildingController: _buildingController,
        floorController: _floorController,
        delayController: _delayController,
        status: _status,
        mode: _mode,
        picture: _picture,
        lampCount: widget.lampCount,
        acCount: widget.acCount,
        projectorCount: widget.projectorCount,
        onBack: () => Navigator.of(context).pop(),
        onStatusChanged: (value) {
          setState(() => _status = value);
        },
        onModeChanged: (value) {
          setState(() => _mode = value);
        },
        onPictureAction: _onPictureAction,
        onRemovePicture: () {
          setState(() => _picture = null);
        },
        onSave: _save,
      ),
    );
  }
}
