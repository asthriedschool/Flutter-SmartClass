import '../models/room.dart';
import '../network/api_client.dart';

class RoomService {
  RoomService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<Room>> getRooms() async {
    final rows = await _apiClient.getList('/rooms');
    return rows.map(Room.fromJson).toList();
  }

  Future<Room> createRoom({
    required String roomName,
    required String building,
    required String floor,
    required String systemStatus,
    required String operationMode,
    required int autoOffDelayMinutes,
    String? picture,
  }) async {
    final stamp = _timestamp(DateTime.now());
    final json = await _apiClient.sendObject(
      'POST',
      '/rooms',
      fallback: 'Ruangan gagal ditambahkan.',
      body: {
        'room_name': roomName.trim(),
        'building': building.trim(),
        'floor': floor.trim(),
        'picture': picture,
        'system_status': systemStatus,
        'operation_mode': operationMode,
        'auto_off_delay_minutes': autoOffDelayMinutes,
        'created_at': stamp,
        'updated_at': stamp,
      },
    );
    return Room.fromJson(json);
  }

  Future<Room> updateRoom({
    required int idRoom,
    required String roomName,
    required String building,
    required String floor,
    required String systemStatus,
    required String operationMode,
    required int autoOffDelayMinutes,
    String? picture,
  }) async {
    final json = await _apiClient.sendObject(
      'PUT',
      '/rooms/$idRoom',
      fallback: 'Ruangan gagal diperbarui.',
      body: {
        'room_name': roomName.trim(),
        'building': building.trim(),
        'floor': floor.trim(),
        'picture': picture,
        'system_status': systemStatus,
        'operation_mode': operationMode,
        'auto_off_delay_minutes': autoOffDelayMinutes,
      },
    );
    return Room.fromJson(json);
  }

  Future<void> deleteRoom(int idRoom) {
    return _apiClient.delete(
      '/rooms/$idRoom',
      fallback: 'Ruangan gagal dihapus.',
    );
  }

  Future<Room> updateOperationMode({
    required int idRoom,
    required String operationMode,
  }) async {
    final json = await _apiClient.sendObject(
      'PATCH',
      '/rooms/$idRoom/mode',
      query: {'operationMode': operationMode},
      fallback: 'Mode ruangan gagal diubah.',
    );
    return Room.fromJson(json);
  }

  Future<Room> updateSystemStatus({
    required int idRoom,
    required String systemStatus,
  }) async {
    final json = await _apiClient.sendObject(
      'PATCH',
      '/rooms/$idRoom/status',
      query: {'systemStatus': systemStatus},
      fallback: 'Status ruangan gagal diubah.',
    );
    return Room.fromJson(json);
  }

  String _timestamp(DateTime time) {
    String two(int value) =>
        value.toString().padLeft(2, '0');
    return '${time.year}-${two(time.month)}-${two(time.day)}'
        'T${two(time.hour)}:${two(time.minute)}:${two(time.second)}';
  }
}
