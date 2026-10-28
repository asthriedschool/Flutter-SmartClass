class Device {
  const Device({
    required this.idDevice,
    required this.idRoom,
    required this.deviceName,
    required this.deviceType,
    required this.status,
    required this.isEnabled,
  });

  final int idDevice;
  final int? idRoom;
  final String deviceName;
  final String deviceType;
  final String status;
  final bool? isEnabled;

  bool get isOn => status == 'ON';

  bool get needsAttention =>
      status == 'UNKNOWN' || isEnabled == false;

  factory Device.fromJson(Map<String, dynamic> json) {
    final enabled = json['is_enabled'] ?? json['enabled'];
    return Device(
      idDevice: (json['id_device'] as num).toInt(),
      idRoom: (json['id_room'] as num?)?.toInt(),
      deviceName: json['device_name'] as String? ?? '',
      deviceType: json['device_type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      isEnabled: enabled is bool ? enabled : null,
    );
  }
}
