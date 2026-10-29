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

  Future<Device> createDevice({
    required int idRoom,
    required String deviceName,
    required String deviceCode,
    required String deviceType,
    required bool isEnabled,
  }) async {
    final json = await _apiClient.sendObject(
      'POST',
      '/devices',
      fallback: 'Perangkat gagal ditambahkan.',
      body: {
        'id_room': idRoom,
        'device_name': deviceName.trim(),
        'device_code': deviceCode.trim(),
        'device_type': deviceType,
        'status': 'OFF',
        'is_enabled': isEnabled,
      },
    );
    return Device.fromJson(json);
  }

  Future<Device> updateDevice({
    required Device current,
    required int idRoom,
    required String deviceName,
    required String deviceCode,
    required String deviceType,
    required bool isEnabled,
  }) async {
    final json = await _apiClient.sendObject(
      'PUT',
      '/devices/${current.idDevice}',
      fallback: 'Perangkat gagal diperbarui.',
      body: {
        'id_room': idRoom,
        'device_name': deviceName.trim(),
        'device_code': deviceCode.trim(),
        'device_type': deviceType,
        'status': current.status.isEmpty
            ? 'UNKNOWN'
            : current.status,
        'is_enabled': isEnabled,
        'last_seen_at': deviceTimestamp(current.lastSeenAt),
      },
    );
    return Device.fromJson(json);
  }

  Future<void> deleteDevice(int idDevice) {
    return _apiClient.delete(
      '/devices/$idDevice',
      fallback: 'Perangkat gagal dihapus.',
    );
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

  Future<Device> updateEnabled({
    required int idDevice,
    required bool isEnabled,
  }) async {
    final json = await _apiClient.sendObject(
      'PATCH',
      '/devices/$idDevice/enabled',
      query: {'isEnabled': '$isEnabled'},
      fallback: 'Status perangkat gagal diubah.',
    );
    return Device.fromJson(json);
  }
}
