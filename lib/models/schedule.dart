class Schedule {
  const Schedule({
    required this.idSchedule,
    required this.idRoom,
    required this.scheduleDate,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isCancelled,
    this.activityName = '',
    this.lecturerName,
    this.scheduleType,
    this.createdBy,
  });

  final int idSchedule;
  final int? idRoom;
  final DateTime? scheduleDate;
  final String? dayOfWeek;
  final String? startTime;
  final String? endTime;
  final bool isCancelled;
  final String activityName;
  final String? lecturerName;
  final String? scheduleType;
  final int? createdBy;

  factory Schedule.fromJson(Map<String, dynamic> json) {
    final rawDate = json['schedule_date'];
    final lecturer = json['lecturer_name'];
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
      activityName:
          (json['activity_name'] as String?)?.trim() ?? '',
      lecturerName:
          lecturer is String && lecturer.trim().isNotEmpty
          ? lecturer.trim()
          : null,
      scheduleType: json['schedule_type'] as String?,
      createdBy: (json['created_by'] as num?)?.toInt(),
    );
  }
}
