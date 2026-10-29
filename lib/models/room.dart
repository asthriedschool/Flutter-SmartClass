const otherRoomChoice = -1;
const otherRoomBuilding = 'Lainnya';
const otherRoomFloor = '-';

class Room {
  const Room({
    required this.idRoom,
    required this.roomName,
    required this.building,
    required this.floor,
    required this.systemStatus,
    required this.operationMode,
    required this.autoOffDelayMinutes,
    this.picture,
  });

  final int idRoom;
  final String roomName;
  final String building;
  final String floor;
  final String systemStatus;
  final String operationMode;
  final int autoOffDelayMinutes;
  final String? picture;

  bool get isEnabled => systemStatus == 'ENABLED';

  bool get isCustomEntry =>
      building.trim() == otherRoomBuilding &&
      floor.trim() == otherRoomFloor;

  String get scheduleOption {
    final place = building.trim();
    if (place.isEmpty || isCustomEntry) {
      return roomName;
    }
    return '$place - $roomName';
  }

  String get locationLabel {
    final place = building.trim();
    final level = floor.trim();
    if (place.isEmpty && level.isEmpty) {
      return '';
    }
    if (place.isEmpty) {
      return 'Floor $level';
    }
    if (level.isEmpty) {
      return place;
    }
    return '$place - Floor $level';
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      idRoom: (json['id_room'] as num).toInt(),
      roomName: json['room_name'] as String? ?? '',
      building: json['building'] as String? ?? '',
      floor: json['floor'] as String? ?? '',
      picture: json['picture'] as String?,
      systemStatus: json['system_status'] as String? ?? '',
      operationMode:
          json['operation_mode'] as String? ?? '',
      autoOffDelayMinutes:
          (json['auto_off_delay_minutes'] as num?)
              ?.toInt() ??
          0,
    );
  }
}
