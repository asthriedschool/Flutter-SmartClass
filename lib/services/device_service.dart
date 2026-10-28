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

  Future<Device> updateStatus({
    required int idDevice,
    required String status,
  }) async {
    final json = await _apiClient.sendObject(
      'PATCH',
      '/devices/$idDevice/status',
      query: {'status': status},
      fallback: 'Status perangkat gagal diubah.',
    );
    return Device.fromJson(json);
  }
}
