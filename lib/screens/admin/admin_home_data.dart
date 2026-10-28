import '../../models/activity_log.dart';
import '../../models/device.dart';
import '../../models/room.dart';
import '../../models/schedule.dart';

class RoomStatusItem {
  const RoomStatusItem({
    required this.name,
    required this.modeLabel,
    required this.isEnabled,
    required this.devicesOn,
    required this.deviceTotal,
    required this.scheduleLabel,
  });

  final String name;
  final String modeLabel;
  final bool isEnabled;
  final int devicesOn;
  final int deviceTotal;
  final String scheduleLabel;
}

class ActivityItem {
  const ActivityItem({
    required this.timeLabel,
    required this.title,
    required this.description,
    required this.source,
    required this.iconName,
  });

  final String timeLabel;
  final String title;
  final String description;
  final String? source;
  final String iconName;
}

class AttentionItem {
  const AttentionItem({
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;
}

class AdminHomeData {
  const AdminHomeData({
    required this.todayScheduleCount,
    required this.activeRoomCount,
    required this.deviceOnCount,
    required this.rooms,
    required this.activities,
    required this.attentions,
  });

  final int todayScheduleCount;
  final int activeRoomCount;
  final int deviceOnCount;
  final List<RoomStatusItem> rooms;
  final List<ActivityItem> activities;
  final List<AttentionItem> attentions;

  factory AdminHomeData.fromSources({
    required List<Room> rooms,
    required List<Device> devices,
    required List<Schedule> schedules,
    required List<ActivityLog> logs,
    required DateTime now,
  }) {
    final todaySchedules = schedules
        .where(
          (schedule) =>
              !schedule.isCancelled &&
              _isToday(schedule, now),
        )
        .toList();
    final roomItems = rooms.map((room) {
      final roomDevices = devices
          .where((device) => device.idRoom == room.idRoom)
          .toList();
      final current = _currentSchedule(
        todaySchedules,
        room.idRoom,
        now,
      );
      return RoomStatusItem(
        name: room.roomName,
        modeLabel: room.operationMode == 'MANUAL'
            ? 'MANUAL MODE'
            : 'AUTO MODE',
        isEnabled: room.isEnabled,
        devicesOn: roomDevices
            .where((device) => device.isOn)
            .length,
        deviceTotal: roomDevices.length,
        scheduleLabel: current == null
            ? 'Tidak ada jadwal'
            : _clockRange(
                current.startTime,
                current.endTime,
              ),
      );
    }).toList();

    final roomNames = {
      for (final room in rooms) room.idRoom: room.roomName,
    };
    final sortedLogs = [...logs]
      ..sort((a, b) {
        final left = a.createdAt;
        final right = b.createdAt;
        if (left == null && right == null) {
          return 0;
        }
        if (left == null) {
          return 1;
        }
        if (right == null) {
          return -1;
        }
        return right.compareTo(left);
      });

    return AdminHomeData(
      todayScheduleCount: todaySchedules.length,
      activeRoomCount: rooms
          .where((room) => room.isEnabled)
          .length,
      deviceOnCount: devices
          .where((device) => device.isOn)
          .length,
      rooms: roomItems,
      activities: sortedLogs
          .take(5)
          .map(
            (log) => ActivityItem(
              timeLabel: _clock(log.createdAt),
              title: roomNames[log.idRoom] ?? 'Aktivitas',
              description: log.description,
              source: log.source,
              iconName: _activityIcon(log),
            ),
          )
          .toList(),
      attentions: [
        for (final room in rooms)
          if (!room.isEnabled)
            AttentionItem(
              title: room.roomName,
              detail: 'Sistem ruangan nonaktif',
            ),
        for (final device in devices)
          if (device.needsAttention)
            AttentionItem(
              title: device.deviceName,
              detail: device.status == 'UNKNOWN'
                  ? 'Status perangkat tidak diketahui'
                  : 'Perangkat dinonaktifkan',
            ),
      ],
    );
  }
}

bool _isToday(Schedule schedule, DateTime now) {
  final date = schedule.scheduleDate;
  if (date != null) {
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  const names = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  final index = now.weekday - 1;
  return schedule.dayOfWeek == names[index];
}

Schedule? _currentSchedule(
  List<Schedule> today,
  int roomId,
  DateTime now,
) {
  final matches = today
      .where((schedule) => schedule.idRoom == roomId)
      .toList();
  Schedule? upcoming;
  for (final schedule in matches) {
    final start = _minutes(schedule.startTime);
    final end = _minutes(schedule.endTime);
    final current = now.hour * 60 + now.minute;
    if (start != null &&
        end != null &&
        current >= start &&
        current <= end) {
      return schedule;
    }
    if (start != null && start > current) {
      final upcomingStart = upcoming == null
          ? null
          : _minutes(upcoming.startTime);
      if (upcomingStart == null || start < upcomingStart) {
        upcoming = schedule;
      }
    }
  }
  return upcoming;
}

int? _minutes(String? value) {
  if (value == null || !value.contains(':')) {
    return null;
  }
  final parts = value.split(':');
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  return hour * 60 + minute;
}

String _clockRange(String? start, String? end) {
  final left = _clockFromRaw(start);
  final right = _clockFromRaw(end);
  if (left == null && right == null) {
    return 'Tidak ada jadwal';
  }
  return '${left ?? '-'} - ${right ?? '-'}';
}

String _clock(DateTime? value) {
  if (value == null) {
    return '--.--';
  }
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour.$minute';
}

String? _clockFromRaw(String? value) {
  final minutes = _minutes(value);
  if (minutes == null) {
    return null;
  }
  final hour = minutes ~/ 60;
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour.$minute';
}

String _activityIcon(ActivityLog log) {
  final text = '${log.activityType} ${log.description}'
      .toLowerCase();
  if (text.contains('mode') || text.contains('manual')) {
    return 'setting-done-02.svg';
  }
  if (text.contains('schedule') ||
      text.contains('jadwal')) {
    return 'date-time.svg';
  }
  return 'power.svg';
}
