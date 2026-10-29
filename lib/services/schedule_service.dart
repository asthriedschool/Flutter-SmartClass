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
