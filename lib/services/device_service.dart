import '../models/device.dart';
import '../network/api_client.dart';

class DeviceService {
  DeviceService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Device>> getDevices() async {
    final rows = await _apiClient.getList('/devices');
    return rows.map(Device.fromJson).toList();
  }
}
