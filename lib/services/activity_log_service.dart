import '../models/activity_log.dart';
import '../network/api_client.dart';

class ActivityLogService {
  ActivityLogService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ActivityLog>> getActivityLogs() async {
    final rows = await _apiClient.getList('/activity-logs');
    return rows.map(ActivityLog.fromJson).toList();
  }
}
