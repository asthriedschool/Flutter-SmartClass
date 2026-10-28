import '../network/api_client.dart';

class DeviceCommandService {
  DeviceCommandService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<void> createCommand({
    required int idDevice,
    required String command,
  }) async {
    await _apiClient.sendObject(
      'POST',
      '/device-commands',
      fallback: 'Perintah perangkat gagal dikirim.',
      body: {
        'id_device': idDevice,
        'command': command,
        'source': 'MANUAL',
        'command_status': 'PENDING',
        'error_message': null,
        'executed_at': null,
      },
    );
  }
}
