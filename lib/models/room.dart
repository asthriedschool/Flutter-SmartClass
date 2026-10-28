class Room {
  const Room({
    required this.idRoom,
    required this.roomName,
    required this.systemStatus,
    required this.operationMode,
  });

  final int idRoom;
  final String roomName;
  final String systemStatus;
  final String operationMode;

  bool get isEnabled => systemStatus == 'ENABLED';

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      idRoom: (json['id_room'] as num).toInt(),
      roomName: json['room_name'] as String? ?? '',
      systemStatus: json['system_status'] as String? ?? '',
      operationMode:
          json['operation_mode'] as String? ?? '',
    );
  }
}
