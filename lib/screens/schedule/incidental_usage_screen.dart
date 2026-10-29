import 'package:flutter/material.dart';

import '../../models/room.dart';
import '../../network/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/room_service.dart';
import '../../services/schedule_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/atoms/schedule_field.dart';
import '../../shared/widgets/organisms/schedule_form_section.dart';
import '../../storage/token_storage.dart';
import '../login/login_screen.dart';
import 'schedule_status.dart';

class IncidentalUsageScreen extends StatefulWidget {
  const IncidentalUsageScreen({super.key});

  @override
  State<IncidentalUsageScreen> createState() =>
      _IncidentalUsageScreenState();
}

class _IncidentalUsageScreenState
    extends State<IncidentalUsageScreen> {
  final RoomService _roomService = RoomService();
  final ScheduleService _scheduleService =
      ScheduleService();
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();
  final TextEditingController _requesterController =
      TextEditingController();
  final TextEditingController _activityController =
      TextEditingController();

  List<Room> _rooms = const [];
  int? _roomId;
  DateTime? _date;
  TimeOfDay? _start;
  TimeOfDay? _end;
  bool _loading = true;
  bool _saving = false;
  bool _unauthorized = false;
  bool _accessDenied = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  @override
  void dispose() {
    _requesterController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _unauthorized = false;
      _accessDenied = false;
    });
    try {
      final token = await _tokenStorage.getAccessToken();
      final role = token == null
          ? null
          : _authService.roleFromAccessToken(token);
      if (role != 'PETUGAS') {
        if (!mounted) {
          return;
        }
        setState(() {
          _loading = false;
          _accessDenied = true;
          _errorMessage = 'Anda tidak memiliki izin untuk menggunakan fitur ini.';
        });
        return;
      }

      final rooms = await _roomService.getRooms();
      if (!mounted) {
        return;
      }
      setState(() {
        _rooms = rooms;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      if (error.unauthorized) {
        setState(() => _unauthorized = true);
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
        _errorMessage = 'Daftar ruangan gagal dimuat.';
      });
    }
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: DateTime(
        today.year,
        today.month,
        today.day,
      ),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTime({required bool start}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (start ? _start : _end) ?? TimeOfDay.now(),
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

  Future<void> _submit() async {
    if (_saving) {
      return;
    }
    final validation = _validate();
    if (validation != null) {
      _showMessage(validation);
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      await _scheduleService.createIncidentalUsage(
        roomId: _roomId!,
        requesterName: _requesterController.text.trim(),
        activityName: _activityController.text.trim(),
        scheduleDate: _dateOnly(_date!),
        startTime: formatTimeOfDay(
          _start!.hour,
          _start!.minute,
        ),
        endTime: formatTimeOfDay(_end!.hour, _end!.minute),
      );
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.card,
          icon: const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF3DB7FF),
            size: 40,
          ),
          title: const Text('Penggunaan disetujui'),
          content: const Text(
            'Penggunaan ruangan telah disetujui.',
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Selesai'),
            ),
          ],
        ),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (error) {
      if (error.unauthorized) {
        await _goToLogin();
        return;
      }
      final message = switch (error.statusCode) {
        400 => 'Input tidak valid: ${error.message}',
        409 => 'Jadwal bentrok: ${error.message}',
        _ => error.message,
      };
      _showMessage(message);
    } catch (_) {
      _showMessage(
        'Penggunaan ruangan gagal disimpan. Periksa koneksi lalu coba lagi.',
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? _validate() {
    if (_requesterController.text.trim().isEmpty) {
      return 'Nama pemohon wajib diisi.';
    }
    if (_roomId == null ||
        !_rooms.any((room) => room.idRoom == _roomId)) {
      return 'Pilih ruangan dari daftar.';
    }
    if (_date == null) {
      return 'Tanggal penggunaan wajib dipilih.';
    }
    if (_start == null || _end == null) {
      return 'Waktu mulai dan selesai wajib dipilih.';
    }
    if (_activityController.text.trim().isEmpty) {
      return 'Tujuan penggunaan wajib diisi.';
    }
    final startMinutes = _start!.hour * 60 + _start!.minute;
    final endMinutes = _end!.hour * 60 + _end!.minute;
    if (startMinutes >= endMinutes) {
      return 'Waktu mulai harus lebih awal daripada waktu selesai.';
    }
    return null;
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

  void _showMessage(String message) {
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
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.navy, AppColors.background],
            stops: [0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  4,
                  16,
                  8,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Kembali',
                      onPressed: () =>
                          Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Penggunaan Insidental',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Ajukan penggunaan ruangan',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : _errorMessage != null
                    ? _LoadError(
                        message: _errorMessage!,
                        onRetry: _loadRooms,
                        onLogin: _goToLogin,
                        onBack: () =>
                            Navigator.of(context).pop(),
                        unauthorized: _unauthorized,
                        accessDenied: _accessDenied,
                      )
                    : _buildForm(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_rooms.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Belum ada ruangan yang tersedia.',
                    style: TextStyle(
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ScheduleFormSection(
                title: 'Informasi Penggunaan',
                subtitle:
                    'Lengkapi detail pengajuan ruangan',
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const ScheduleFieldLabel(
                      'Nama pemohon *',
                    ),
                    const SizedBox(height: 6),
                    ScheduleTextField(
                      controller: _requesterController,
                      hint: 'Nama lengkap pemohon',
                      enabled: !_saving,
                      keyboardType: TextInputType.name,
                    ),
                    const SizedBox(height: 12),
                    const ScheduleFieldLabel('Ruangan *'),
                    const SizedBox(height: 6),
                    ScheduleDropdownField<int>(
                      value:
                          _rooms.any(
                            (room) =>
                                room.idRoom == _roomId,
                          )
                          ? _roomId
                          : null,
                      hint: 'Pilih ruangan',
                      items: [
                        for (final room in _rooms)
                          DropdownMenuItem(
                            value: room.idRoom,
                            child: Text(
                              room.scheduleOption,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: _saving || _rooms.isEmpty
                          ? null
                          : (value) => setState(
                              () => _roomId = value,
                            ),
                    ),
                    const SizedBox(height: 12),
                    const ScheduleFieldLabel(
                      'Tujuan penggunaan *',
                    ),
                    const SizedBox(height: 6),
                    ScheduleTextField(
                      controller: _activityController,
                      hint: 'Jelaskan tujuan penggunaan',
                      enabled: !_saving,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ScheduleFormSection(
                title: 'Waktu Penggunaan',
                subtitle: 'Pilih tanggal dan rentang waktu',
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const ScheduleFieldLabel(
                      'Tanggal penggunaan *',
                    ),
                    const SizedBox(height: 6),
                    SchedulePickerField(
                      value: _date == null
                          ? null
                          : _dateLabel(_date!),
                      hint: 'Pilih tanggal',
                      icon: const Icon(
                        Icons.calendar_month_outlined,
                        color: Color(0xFF3DB7FF),
                        size: 18,
                      ),
                      onPressed: _saving ? null : _pickDate,
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Expanded(
                          child: ScheduleFieldLabel(
                            'Waktu mulai *',
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ScheduleFieldLabel(
                            'Waktu selesai *',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: SchedulePickerField(
                            value: _timeLabel(_start),
                            hint: 'Mulai',
                            icon: const Icon(
                              Icons.access_time,
                              color: Color(0xFF3DB7FF),
                              size: 18,
                            ),
                            onPressed: _saving
                                ? null
                                : () => _pickTime(
                                    start: true,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SchedulePickerField(
                            value: _timeLabel(_end),
                            hint: 'Selesai',
                            icon: const Icon(
                              Icons.access_time,
                              color: Color(0xFF3DB7FF),
                              size: 18,
                            ),
                            onPressed: _saving
                                ? null
                                : () => _pickTime(
                                    start: false,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: _saving || _rooms.isEmpty
                      ? null
                      : _submit,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.text,
                          ),
                        )
                      : const Icon(Icons.send_outlined),
                  label: Text(
                    _saving
                        ? 'Mengirim pengajuan...'
                        : 'Ajukan Penggunaan',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.text,
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.message,
    required this.onRetry,
    required this.onLogin,
    required this.onBack,
    required this.unauthorized,
    required this.accessDenied,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onLogin;
  final VoidCallback onBack;
  final bool unauthorized;
  final bool accessDenied;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.text),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: unauthorized
                  ? onLogin
                  : accessDenied
                  ? onBack
                  : onRetry,
              child: Text(
                unauthorized
                    ? 'Ke halaman login'
                    : accessDenied
                    ? 'Kembali'
                    : 'Coba lagi',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _dateOnly(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${date.year}-${two(date.month)}-${two(date.day)}';
}

String _dateLabel(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}-${two(date.month)}-${date.year}';
}

String? _timeLabel(TimeOfDay? time) {
  if (time == null) {
    return null;
  }
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(time.hour)}:${two(time.minute)}';
}
