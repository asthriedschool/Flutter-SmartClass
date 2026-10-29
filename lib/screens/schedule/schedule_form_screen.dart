import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../models/schedule.dart';
import '../../network/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/room_service.dart';
import '../../services/schedule_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/templates/schedule_form_template.dart';
import '../../storage/token_storage.dart';
import 'schedule_status.dart';

class ScheduleFormScreen extends StatefulWidget {
  const ScheduleFormScreen({super.key, this.schedule});

  final Schedule? schedule;

  @override
  State<ScheduleFormScreen> createState() =>
      _ScheduleFormScreenState();
}

class _ScheduleFormScreenState
    extends State<ScheduleFormScreen> {
  final RoomService _roomService = RoomService();
  final ScheduleService _scheduleService =
      ScheduleService();
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();
  final TextEditingController _subjectController =
      TextEditingController();
  final TextEditingController _lecturerController =
      TextEditingController();
  final TextEditingController _customRoomController =
      TextEditingController();

  List<Room> _rooms = const [];
  bool _loading = true;
  bool _saving = false;
  bool _canManage = false;
  String? _errorMessage;
  int? _roomId;
  bool _customRoom = false;
  String _type = 'ONCE';
  DateTime? _date;
  String? _day;
  TimeOfDay? _start;
  TimeOfDay? _end;
  bool _cancelled = false;

  bool get _editing => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    final schedule = widget.schedule;
    if (schedule != null) {
      _subjectController.text = schedule.activityName;
      _lecturerController.text =
          schedule.lecturerName ?? '';
      _roomId = schedule.idRoom;
      _type = schedule.scheduleType == 'WEEKLY'
          ? 'WEEKLY'
          : 'ONCE';
      _date = schedule.scheduleDate;
      _day = schedule.dayOfWeek;
      _start = _time(schedule.startTime);
      _end = _time(schedule.endTime);
      _cancelled = schedule.isCancelled;
    }
    _loadRooms();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _lecturerController.dispose();
    _customRoomController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
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
              'Anda tidak memiliki izin untuk mengelola jadwal.';
        });
        return;
      }
      final rooms = await _roomService.getRooms();
      if (!mounted) {
        return;
      }
      final current = _roomById(_roomId, rooms);
      setState(() {
        _canManage = true;
        _rooms = rooms;
        _loading = false;
        if (current != null && current.isCustomEntry) {
          _customRoom = true;
          _customRoomController.text = current.roomName;
        }
      });
    } on ApiException catch (error) {
      if (!mounted) {
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

  Future<void> _pickWhen() async {
    if (_type == 'WEEKLY') {
      final picked = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: AppColors.card,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final day in scheduleWeekdays)
                  ListTile(
                    title: Text(
                      formWeekdayLabels[day] ?? day,
                    ),
                    onTap: () =>
                        Navigator.pop(context, day),
                  ),
              ],
            ),
          );
        },
      );
      if (picked != null) {
        setState(() => _day = picked);
      }
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime(bool start) async {
    final current = start ? _start : _end;
    final picked = await showTimePicker(
      context: context,
      initialTime: current ?? TimeOfDay.now(),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (start) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_canManage || _saving) {
      return;
    }
    final subject = _subjectController.text.trim();
    final lecturer = _lecturerController.text.trim();
    final message = _validate(subject);
    if (message != null) {
      _message(message);
      return;
    }
    setState(() => _saving = true);
    late final int roomId;
    try {
      roomId = await _resolveRoomId();
      _roomId = roomId;
    } on ApiException catch (error) {
      _message(error.message);
      if (mounted) {
        setState(() => _saving = false);
      }
      return;
    } catch (_) {
      _message('Ruangan gagal disimpan.');
      if (mounted) {
        setState(() => _saving = false);
      }
      return;
    }
    if (!mounted) {
      return;
    }
    final body = <String, dynamic>{
      'id_room': roomId,
      'activity_name': subject,
      'lecturer_name': lecturer.isEmpty ? null : lecturer,
      'schedule_type': _type,
      'schedule_date': _type == 'ONCE'
          ? _dateOnly(_date!)
          : null,
      'day_of_week': _type == 'WEEKLY' ? _day : null,
      'start_time': formatTimeOfDay(
        _start!.hour,
        _start!.minute,
      ),
      'end_time': formatTimeOfDay(_end!.hour, _end!.minute),
      'is_cancelled': _cancelled,
    };
    try {
      final existing = widget.schedule;
      if (existing == null) {
        await _scheduleService.createSchedule(body);
      } else {
        await _scheduleService.updateSchedule(
          idSchedule: existing.idSchedule,
          body: body,
        );
      }
      if (!mounted) {
        return;
      }
      _message(
        existing == null
            ? 'Jadwal berhasil ditambahkan.'
            : 'Jadwal berhasil diperbarui.',
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Jadwal gagal disimpan.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<int> _resolveRoomId() async {
    if (!_customRoom) {
      return _roomId!;
    }
    final name = _customRoomController.text.trim();
    final current = _roomById(_roomId, _rooms);
    final match = _roomByName(name, _rooms);
    if (current != null && current.isCustomEntry) {
      if (current.roomName.trim().toLowerCase() ==
          name.toLowerCase()) {
        return current.idRoom;
      }
      if (match != null && match.idRoom != current.idRoom) {
        return match.idRoom;
      }
      final updated = await _roomService.updateRoom(
        idRoom: current.idRoom,
        roomName: name,
        building: current.building,
        floor: current.floor,
        systemStatus: current.systemStatus,
        operationMode: current.operationMode,
        autoOffDelayMinutes: current.autoOffDelayMinutes,
        picture: current.picture,
      );
      _replaceRoom(updated);
      return updated.idRoom;
    }
    if (match != null) {
      return match.idRoom;
    }
    final created = await _roomService.createRoom(
      roomName: name,
      building: otherRoomBuilding,
      floor: otherRoomFloor,
      systemStatus: 'ENABLED',
      operationMode: 'MANUAL',
      autoOffDelayMinutes: 0,
    );
    _replaceRoom(created);
    return created.idRoom;
  }

  void _replaceRoom(Room room) {
    final rooms = [
      for (final item in _rooms)
        if (item.idRoom != room.idRoom) item,
      room,
    ];
    if (!mounted) {
      _rooms = rooms;
      _roomId = room.idRoom;
      return;
    }
    setState(() {
      _rooms = rooms;
      _roomId = room.idRoom;
    });
  }

  String? _validate(String subject) {
    if (!_customRoom && _roomId == null) {
      return 'Ruangan wajib dipilih.';
    }
    if (_customRoom &&
        _customRoomController.text.trim().isEmpty) {
      return 'Nama ruangan wajib diisi.';
    }
    if (_customRoom &&
        _customRoomController.text.trim().length > 100) {
      return 'Nama ruangan maksimal 100 karakter.';
    }
    if (subject.isEmpty) {
      return 'Subject wajib diisi.';
    }
    if (_type != 'ONCE' && _type != 'WEEKLY') {
      return 'Tipe jadwal wajib dipilih.';
    }
    if (_type == 'ONCE' && _date == null) {
      return 'Tanggal wajib diisi.';
    }
    if (_type == 'WEEKLY' &&
        (_day == null ||
            !scheduleWeekdays.contains(_day))) {
      return 'Hari wajib dipilih.';
    }
    if (_start == null || _end == null) {
      return 'Jam mulai dan selesai wajib diisi.';
    }
    final start = _start!.hour * 60 + _start!.minute;
    final end = _end!.hour * 60 + _end!.minute;
    if (end <= start) {
      return 'Jam selesai harus setelah jam mulai.';
    }
    return null;
  }

  Future<void> _delete() async {
    final schedule = widget.schedule;
    if (!_canManage || _saving || schedule == null) {
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
    setState(() => _saving = true);
    try {
      await _scheduleService.deleteSchedule(
        schedule.idSchedule,
      );
      if (!mounted) {
        return;
      }
      _message('Jadwal berhasil dihapus.');
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Jadwal gagal dihapus.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ScheduleFormTemplate(
        editing: _editing,
        loading: _loading,
        saving: _saving,
        errorMessage: _errorMessage,
        rooms: _rooms,
        roomId: _roomId,
        customRoom: _customRoom,
        customRoomController: _customRoomController,
        subjectController: _subjectController,
        lecturerController: _lecturerController,
        type: _type,
        whenLabel: formScheduleWhenLabel(
          type: _type,
          date: _date,
          day: _day,
        ),
        startLabel: _clockLabel(_start),
        endLabel: _clockLabel(_end),
        cancelled: _cancelled,
        onBack: () {
          if (!_saving) {
            Navigator.of(context).maybePop();
          }
        },
        onRetry: _loadRooms,
        onRoom: (value) => setState(() {
          if (value == otherRoomChoice) {
            _customRoom = true;
            return;
          }
          _customRoom = false;
          _roomId = value;
        }),
        onType: (value) => setState(() => _type = value),
        onWhen: _pickWhen,
        onStart: () => _pickTime(true),
        onEnd: () => _pickTime(false),
        onCancelled: (value) =>
            setState(() => _cancelled = value),
        onSave: _save,
        onDelete: _editing ? _delete : null,
      ),
    );
  }
}

TimeOfDay? _time(String? value) {
  if (value == null || !value.contains(':')) {
    return null;
  }
  final parts = value.split(':');
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  return TimeOfDay(hour: hour, minute: minute);
}

Room? _roomById(int? id, List<Room> rooms) {
  if (id == null) {
    return null;
  }
  for (final room in rooms) {
    if (room.idRoom == id) {
      return room;
    }
  }
  return null;
}

Room? _roomByName(String name, List<Room> rooms) {
  final key = name.toLowerCase();
  for (final room in rooms) {
    if (room.roomName.trim().toLowerCase() == key) {
      return room;
    }
  }
  for (final room in rooms) {
    if (room.scheduleOption.toLowerCase() == key) {
      return room;
    }
  }
  return null;
}

String? _clockLabel(TimeOfDay? time) {
  if (time == null) {
    return null;
  }
  final minute = time.minute.toString().padLeft(2, '0');
  return '${time.hour}.$minute';
}

String _dateOnly(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}
