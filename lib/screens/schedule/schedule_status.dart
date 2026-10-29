import '../../models/schedule.dart';

enum SchedulePhase { inactive, active, upcoming, finished }

const scheduleWeekdays = <String>[
  'MONDAY',
  'TUESDAY',
  'WEDNESDAY',
  'THURSDAY',
  'FRIDAY',
  'SATURDAY',
];

const _weekdayLabels = <String, String>{
  'MONDAY': 'Senin',
  'TUESDAY': 'Selasa',
  'WEDNESDAY': 'Rabu',
  'THURSDAY': 'Kamis',
  'FRIDAY': 'Jumat',
  'SATURDAY': 'Sabtu',
};

const _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

SchedulePhase schedulePhase(
  Schedule schedule,
  DateTime now,
) {
  if (schedule.isCancelled) {
    return SchedulePhase.inactive;
  }
  final start = _minutes(schedule.startTime);
  final end = _minutes(schedule.endTime);
  if (start == null || end == null) {
    return SchedulePhase.upcoming;
  }
  final date = schedule.scheduleDate;
  if (date != null) {
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(
      date.year,
      date.month,
      date.day,
    );
    final minute = now.hour * 60 + now.minute;
    if (target == today) {
      if (minute >= start && minute <= end) {
        return SchedulePhase.active;
      }
      if (minute < start) {
        return SchedulePhase.upcoming;
      }
      return SchedulePhase.finished;
    }
    if (target.isAfter(today)) {
      return SchedulePhase.upcoming;
    }
    return SchedulePhase.finished;
  }
  if (schedule.dayOfWeek == null) {
    return SchedulePhase.upcoming;
  }
  if (schedule.dayOfWeek == weekdayName(now)) {
    final minute = now.hour * 60 + now.minute;
    if (minute >= start && minute <= end) {
      return SchedulePhase.active;
    }
  }
  return SchedulePhase.upcoming;
}

bool scheduleOccursToday(Schedule schedule, DateTime now) {
  final date = schedule.scheduleDate;
  if (date != null) {
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
  return schedule.dayOfWeek == weekdayName(now);
}

String weekdayName(DateTime now) {
  const names = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  return names[now.weekday - 1];
}

String schedulePhaseLabel(SchedulePhase phase) {
  switch (phase) {
    case SchedulePhase.inactive:
      return 'Inactive';
    case SchedulePhase.active:
      return 'Active';
    case SchedulePhase.upcoming:
      return 'Upcoming';
    case SchedulePhase.finished:
      return 'Finished';
  }
}

String scheduleClock(String? start, String? end) {
  final left = _clock(start);
  final right = _clock(end);
  if (left == null && right == null) {
    return '--';
  }
  return '${left ?? '--'} - ${right ?? '--'}';
}

String scheduleDateLabel(Schedule schedule) {
  final date = schedule.scheduleDate;
  if (date != null) {
    final month = _months[date.month - 1];
    return '${date.day} $month ${date.year}';
  }
  final day = schedule.dayOfWeek;
  if (day == null || day.isEmpty) {
    return 'Tanggal tidak tersedia';
  }
  final label = _weekdayLabels[day] ?? day;
  return 'Setiap $label';
}

String? weekdayLabel(String? day) {
  if (day == null) {
    return null;
  }
  return _weekdayLabels[day];
}

const formWeekdayLabels = <String, String>{
  'MONDAY': 'Monday',
  'TUESDAY': 'Tuesday',
  'WEDNESDAY': 'Wednesday',
  'THURSDAY': 'Thursday',
  'FRIDAY': 'Friday',
  'SATURDAY': 'Saturday',
};

String formScheduleWhenLabel({
  required String type,
  required DateTime? date,
  required String? day,
}) {
  if (type == 'WEEKLY') {
    final label = formWeekdayLabels[day];
    if (label == null) {
      return 'Day / Date';
    }
    return 'Every $label';
  }
  if (date == null) {
    return 'Day / Date';
  }
  const weekdays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${weekdays[date.weekday - 1]}, '
      '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatTimeOfDay(int hour, int minute) {
  final h = hour.toString().padLeft(2, '0');
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m:00';
}

String? clockLabel(String? value) {
  return _clock(value);
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

String? _clock(String? value) {
  final minutes = _minutes(value);
  if (minutes == null) {
    return null;
  }
  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour.$minute';
}
