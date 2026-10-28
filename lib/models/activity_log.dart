class ActivityLog {
  const ActivityLog({
    required this.idActivityLog,
    required this.idRoom,
    required this.activityType,
    required this.description,
    required this.source,
    required this.createdAt,
  });

  final int idActivityLog;
  final int? idRoom;
  final String activityType;
  final String description;
  final String? source;
  final DateTime? createdAt;

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    final rawCreated = json['created_at'];
    return ActivityLog(
      idActivityLog: (json['id_activity_log'] as num)
          .toInt(),
      idRoom: (json['id_room'] as num?)?.toInt(),
      activityType: json['activity_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      source: json['source'] as String?,
      createdAt: rawCreated is String
          ? DateTime.tryParse(rawCreated)
          : null,
    );
  }
}
