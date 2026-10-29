import 'package:flutter_test/flutter_test.dart';
import 'package:smart_class_mobile_app/network/api_client.dart';
import 'package:smart_class_mobile_app/services/schedule_service.dart';

void main() {
  test('posts incidental usage payload to existing schedules endpoint', () async {
    final apiClient = _RecordingApiClient();
    final service = ScheduleService(apiClient: apiClient);

    await service.createIncidentalUsage(
      roomId: 12,
      requesterName: 'Petugas SmartClass',
      activityName: 'Kegiatan laboratorium',
      scheduleDate: '2026-10-30',
      startTime: '09:15:00',
      endTime: '10:30:00',
    );

    expect(apiClient.method, 'POST');
    expect(apiClient.path, '/schedules');
    expect(apiClient.body, {
      'id_room': 12,
      'requester_name': 'Petugas SmartClass',
      'activity_name': 'Kegiatan laboratorium',
      'schedule_type': 'ONCE',
      'schedule_date': '2026-10-30',
      'start_time': '09:15:00',
      'end_time': '10:30:00',
    });
  });

  test(
    'preserves API errors for the form to handle',
    () async {
      final service = ScheduleService(
        apiClient: _RecordingApiClient(
          error: const ApiException(
            'Jadwal bentrok.',
            statusCode: 409,
          ),
        ),
      );

      await expectLater(
        service.createIncidentalUsage(
          roomId: 12,
          requesterName: 'Petugas SmartClass',
          activityName: 'Kegiatan laboratorium',
          scheduleDate: '2026-10-30',
          startTime: '09:15:00',
          endTime: '10:30:00',
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            409,
          ),
        ),
      );
    },
  );
}

class _RecordingApiClient extends ApiClient {
  _RecordingApiClient({this.error});

  final ApiException? error;

  String? method;
  String? path;
  Map<String, dynamic>? body;

  @override
  Future<Map<String, dynamic>> sendObject(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    String fallback = 'Permintaan gagal. Coba lagi.',
  }) async {
    if (error != null) {
      throw error!;
    }
    this.method = method;
    this.path = path;
    this.body = body;
    return const {};
  }
}
