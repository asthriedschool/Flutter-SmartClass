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
}
