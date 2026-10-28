import '../../models/schedule.dart';

class RoomScheduleInfo {
  const RoomScheduleInfo({
    required this.time,
    required this.caption,
  });

  final String time;
  final String caption;
}

RoomScheduleInfo roomScheduleInfo({
  required List<Schedule> schedules,
  required int roomId,
  required DateTime now,
  required bool ready,
}) {
  if (!ready) {
    return const RoomScheduleInfo(
      time: '--',
      caption: 'Schedule',
    );
  }
  final today = schedules.where(
    (schedule) =>
        !schedule.isCancelled &&
        schedule.idRoom == roomId &&
        _isToday(schedule, now),
  );
  Schedule? current;
  Schedule? upcoming;
  var upcomingStart = 1 << 30;
  final minuteNow = now.hour * 60 + now.minute;
  for (final schedule in today) {
    final start = _minutes(schedule.startTime);
    final end = _minutes(schedule.endTime);
    if (start != null &&
        end != null &&
        minuteNow >= start &&
        minuteNow <= end) {
      current = schedule;
      break;
    }
    if (start != null &&
        start > minuteNow &&
        start < upcomingStart) {
      upcoming = schedule;
      upcomingStart = start;
    }
  }
  final match = current ?? upcoming;
  if (match == null) {
    return const RoomScheduleInfo(
      time: '--',
      caption: 'No schedule',
    );
  }
  return RoomScheduleInfo(
    time: _clockRange(match.startTime, match.endTime),
    caption: current != null
        ? 'Current Schedule'
        : 'Next Schedule',
  );
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
  return schedule.dayOfWeek == names[now.weekday - 1];
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
  String? clock(String? value) {
    final minutes = _minutes(value);
    if (minutes == null) {
      return null;
    }
    final hour = minutes ~/ 60;
    final minute = (minutes % 60).toString().padLeft(
      2,
      '0',
    );
    return '$hour.$minute';
  }

  final left = clock(start);
  final right = clock(end);
  if (left == null && right == null) {
    return '--';
  }
  return '${left ?? '--'} - ${right ?? '--'}';
}
