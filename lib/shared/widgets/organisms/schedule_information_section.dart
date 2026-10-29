import 'package:flutter/material.dart';

import '../../../models/room.dart';
import '../atoms/schedule_field.dart';
import 'schedule_form_section.dart';

class ScheduleInformationSection extends StatelessWidget {
  const ScheduleInformationSection({
    super.key,
    required this.subjectController,
    required this.lecturerController,
    required this.rooms,
    required this.roomId,
    required this.customRoom,
    required this.customRoomController,
    required this.enabled,
    required this.onRoom,
  });

  final TextEditingController subjectController;
  final TextEditingController lecturerController;
  final List<Room> rooms;
  final int? roomId;
  final bool customRoom;
  final TextEditingController customRoomController;
  final bool enabled;
  final ValueChanged<int?> onRoom;

  @override
  Widget build(BuildContext context) {
    final listed = [
      for (final room in rooms)
        if (!room.isCustomEntry) room,
    ];
    final selected = customRoom
        ? otherRoomChoice
        : listed.any((room) => room.idRoom == roomId)
        ? roomId
        : null;
    return ScheduleFormSection(
      title: 'Schedule Information',
      subtitle: 'Basic information about the class',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScheduleFieldLabel(
            'Activity / Subject Name',
          ),
          const SizedBox(height: 6),
          ScheduleTextField(
            controller: subjectController,
            hint: 'e.g. Machine Learning',
            enabled: enabled,
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: ScheduleFieldLabel('Room')),
              SizedBox(width: 10),
              Expanded(
                child: ScheduleFieldLabel('Lecturer'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ScheduleDropdownField<int>(
                  value: selected,
                  hint: 'Room',
                  items: [
                    for (final room in listed)
                      DropdownMenuItem(
                        value: room.idRoom,
                        child: Text(
                          room.scheduleOption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const DropdownMenuItem(
                      value: otherRoomChoice,
                      child: Text(
                        'Others',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: enabled ? onRoom : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ScheduleTextField(
                  controller: lecturerController,
                  hint: 'Lecturer',
                  enabled: enabled,
                ),
              ),
            ],
          ),
          if (customRoom) ...[
            const SizedBox(height: 10),
            const ScheduleFieldLabel('Room name'),
            const SizedBox(height: 6),
            ScheduleTextField(
              controller: customRoomController,
              hint: 'Type a room name',
              enabled: enabled,
            ),
          ],
        ],
      ),
    );
  }
}
