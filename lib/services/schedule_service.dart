import '../models/schedule.dart';
import '../network/api_client.dart';

class ScheduleService {
  ScheduleService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Schedule>> getSchedules() async {
    final rows = await _apiClient.getList('/schedules');
    return rows.map(Schedule.fromJson).toList();
  }

  Future<Schedule> createSchedule(
    Map<String, dynamic> body,
  ) async {
    final json = await _apiClient.sendObject(
      'POST',
      '/schedules',
      body: body,
      fallback: 'Jadwal gagal ditambahkan.',
    );
    return Schedule.fromJson(json);
  }

  Future<void> createIncidentalUsage({
    required int roomId,
    required String requesterName,
    required String activityName,
    required String scheduleDate,
    required String startTime,
    required String endTime,
  }) async {
    await _apiClient.sendObject(
      'POST',
      '/schedules',
      body: {
        'id_room': roomId,
        'requester_name': requesterName,
        'activity_name': activityName,
        'schedule_type': 'ONCE',
        'schedule_date': scheduleDate,
        'start_time': startTime,
        'end_time': endTime,
      },
      fallback: 'Penggunaan ruangan gagal disimpan.',
    );
  }

  Future<Schedule> updateSchedule({
    required int idSchedule,
    required Map<String, dynamic> body,
  }) async {
    final json = await _apiClient.sendObject(
      'PUT',
      '/schedules/$idSchedule',
      body: body,
      fallback: 'Jadwal gagal diperbarui.',
    );
    return Schedule.fromJson(json);
  }

  Future<void> deleteSchedule(int idSchedule) {
    return _apiClient.delete(
      '/schedules/$idSchedule',
      fallback: 'Jadwal gagal dihapus.',
    );
  }
}
