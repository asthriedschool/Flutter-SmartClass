class Schedule {
  const Schedule({
    required this.idSchedule,
    required this.idRoom,
    required this.scheduleDate,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isCancelled,
  });

  final int idSchedule;
  final int? idRoom;
  final DateTime? scheduleDate;
  final String? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final bool isCancelled;

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final rawDate = json['schedule_date'];
    return Schedule(
      idSchedule: (json['id_schedule'] as num).toInt(),
      idRoom: (json['id_room'] as num?)?.toInt(),
      scheduleDate: rawDate is String
          ? DateTime.tryParse(rawDate)
          : null,
      dayOfWeek: json['day_of_week'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      isCancelled: json['is_cancelled'] == true,
    );
  }
}
