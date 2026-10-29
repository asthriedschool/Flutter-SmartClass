import 'package:flutter/material.dart';

import '../../../models/device.dart';
import '../../../models/room.dart';
import '../../app_colors.dart';
import '../atoms/schedule_field.dart';
import '../organisms/schedule_form_header.dart';
import '../organisms/schedule_form_section.dart';

class DeviceFormTemplate extends StatelessWidget {
  const DeviceFormTemplate({
    super.key,
    required this.editing,
    required this.saving,
    required this.rooms,
    required this.roomId,
    required this.nameController,
    required this.codeController,
    required this.deviceType,
    required this.enabled,
    required this.onBack,
    required this.onRoom,
    required this.onType,
    required this.onEnabled,
    required this.onSave,
  });

  final bool editing;
  final bool saving;
  final List<Room> rooms;
  final int? roomId;
  final TextEditingController nameController;
  final TextEditingController codeController;
  final String deviceType;
  final bool enabled;
  final VoidCallback onBack;
  final ValueChanged<int?> onRoom;
  final ValueChanged<String?> onType;
  final ValueChanged<bool> onEnabled;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final title = editing ? 'Edit Device' : 'Add Device';
    final subtitle = editing
        ? 'Update classroom device information'
        : 'Register a classroom device';
    final selected =
        rooms.any((room) => room.idRoom == roomId)
        ? roomId
        : null;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B4261), AppColors.background],
          stops: [0, 0.32],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                0,
              ),
              child: ScheduleFormHeader(
                title: title,
                subtitle: subtitle,
                onBack: onBack,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  16,
                ),
                children: [
                  ScheduleFormSection(
                    title: 'Device Information',
                    subtitle: 'Name, code, and type',
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const ScheduleFieldLabel(
                          'Device name',
                        ),
                        const SizedBox(height: 6),
                        ScheduleTextField(
                          controller: nameController,
                          hint: 'Device name',
                          enabled: !saving,
                        ),
                        const SizedBox(height: 10),
                        const ScheduleFieldLabel(
                          'Device code',
                        ),
                        const SizedBox(height: 6),
                        ScheduleTextField(
                          controller: codeController,
                          hint: 'Device code',
                          enabled: !saving,
                        ),
                        const SizedBox(height: 10),
                        const ScheduleFieldLabel('Type'),
                        const SizedBox(height: 6),
                        ScheduleDropdownField<String>(
                          value:
                              deviceTypes.contains(
                                deviceType,
                              )
                              ? deviceType
                              : null,
                          hint: 'Type',
                          items: const [
                            DropdownMenuItem(
                              value: 'LAMP',
                              child: Text('Lamp'),
                            ),
                            DropdownMenuItem(
                              value: 'AC',
                              child: Text(
                                'Air Conditioner',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'PROJECTOR',
                              child: Text('Projector'),
                            ),
                          ],
                          onChanged: saving ? null : onType,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ScheduleFormSection(
                    title: 'Placement',
                    subtitle: 'Room and availability',
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const ScheduleFieldLabel('Room'),
                        const SizedBox(height: 6),
                        ScheduleDropdownField<int>(
                          value: selected,
                          hint: 'Room',
                          items: [
                            for (final room in rooms)
                              DropdownMenuItem(
                                value: room.idRoom,
                                child: Text(
                                  room.scheduleOption,
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: saving ? null : onRoom,
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Enabled',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: const Text(
                            'Perangkat dapat digunakan',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          value: enabled,
                          onChanged: saving
                              ? null
                              : onEnabled,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: saving ? null : onBack,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(
                            0xFF3A3C40,
                          ),
                          foregroundColor: AppColors.text,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: saving ? null : onSave,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              AppColors.primary,
                          foregroundColor: AppColors.text,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          saving
                              ? 'Menyimpan...'
                              : editing
                              ? 'Save Changes'
                              : 'Create Device',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
