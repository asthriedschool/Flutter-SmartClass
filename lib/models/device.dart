const deviceTypes = ['LAMP', 'AC', 'PROJECTOR'];

class Device {
  const Device({
    required this.idDevice,
    required this.idRoom,
    required this.deviceName,
    required this.deviceCode,
    required this.deviceType,
    required this.status,
    required this.isEnabled,
    this.lastSeenAt,
  });

  final int idDevice;
  final int? idRoom;
  final String deviceName;
  final String deviceCode;
  final String deviceType;
  final String status;
  final bool? isEnabled;
  final DateTime? lastSeenAt;

  bool get isOn => status == 'ON';

  bool get needsAttention =>
      status == 'UNKNOWN' || isEnabled == false;

  String get typeLabel => switch (deviceType) {
    'LAMP' => 'Lamp',
    'AC' => 'Air Conditioner',
    'PROJECTOR' => 'Projector',
    _ => deviceType,
  };

  String get typeIcon => switch (deviceType) {
    'LAMP' => 'LampZonesImg.svg',
    'AC' => 'ACUnitsImg.svg',
    'PROJECTOR' => 'ProjectorUnitsImg.svg',
    _ => 'LampZonesImg.svg',
  };

  factory Device.fromJson(Map<String, dynamic> json) {
    final enabled = json['is_enabled'] ?? json['enabled'];
    return Device(
      idDevice: (json['id_device'] as num).toInt(),
      idRoom: (json['id_room'] as num?)?.toInt(),
      deviceName: json['device_name'] as String? ?? '',
      deviceCode: json['device_code'] as String? ?? '',
      deviceType: json['device_type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isEnabled: enabled is bool ? enabled : null,
      lastSeenAt: _date(json['last_seen_at']),
    );
  }
}

DateTime? _date(Object? value) {
  if (value is! String || value.isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

String? deviceTimestamp(DateTime? time) {
  if (time == null) {
    return null;
  }
  final local = time.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}'
      'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
}
