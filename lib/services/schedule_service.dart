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
}
