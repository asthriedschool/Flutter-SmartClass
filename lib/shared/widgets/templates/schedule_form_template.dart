import 'package:flutter/material.dart';

import '../../../models/room.dart';
import '../../app_colors.dart';
import '../organisms/schedule_form_actions.dart';
import '../organisms/schedule_form_header.dart';
import '../organisms/schedule_information_section.dart';
import '../organisms/schedule_room_time_section.dart';

class ScheduleFormTemplate extends StatelessWidget {
  const ScheduleFormTemplate({
    super.key,
    required this.editing,
    required this.loading,
    required this.saving,
    required this.errorMessage,
    required this.rooms,
    required this.roomId,
    required this.customRoom,
    required this.customRoomController,
    required this.subjectController,
    required this.lecturerController,
    required this.type,
    required this.whenLabel,
    required this.startLabel,
    required this.endLabel,
    required this.cancelled,
    required this.onBack,
    required this.onRetry,
    required this.onRoom,
    required this.onType,
    required this.onWhen,
    required this.onStart,
    required this.onEnd,
    required this.onCancelled,
    required this.onSave,
    required this.onDelete,
  });

  final bool editing;
  final bool loading;
  final bool saving;
  final String? errorMessage;
  final List<Room> rooms;
  final int? roomId;
  final bool customRoom;
  final TextEditingController customRoomController;
  final TextEditingController subjectController;
  final TextEditingController lecturerController;
  final String type;
  final String whenLabel;
  final String? startLabel;
  final String? endLabel;
  final bool cancelled;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final ValueChanged<int?> onRoom;
  final ValueChanged<String> onType;
  final VoidCallback onWhen;
  final VoidCallback onStart;
  final VoidCallback onEnd;
  final ValueChanged<bool> onCancelled;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final title = editing
        ? 'Edit Schedule'
        : 'Add Schedule';
    final subtitle = editing
        ? 'Update classroom schedule information'
        : 'Create a new classroom schedule';
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
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    )
                  : errorMessage != null
                  ? _FormStatus(
                      message: errorMessage!,
                      onRetry: onRetry,
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        16,
                        16,
                        16,
                      ),
                      children: [
                        ScheduleInformationSection(
                          subjectController:
                              subjectController,
                          lecturerController:
                              lecturerController,
                          rooms: rooms,
                          roomId: roomId,
                          customRoom: customRoom,
                          customRoomController:
                              customRoomController,
                          enabled: !saving,
                          onRoom: onRoom,
                        ),
                        const SizedBox(height: 14),
                        ScheduleRoomTimeSection(
                          whenLabel: whenLabel,
                          startLabel: startLabel,
                          endLabel: endLabel,
                          type: type,
                          cancelled: cancelled,
                          enabled: !saving,
                          onWhen: onWhen,
                          onStart: onStart,
                          onEnd: onEnd,
                          onType: onType,
                          onCancelled: onCancelled,
                        ),
                      ],
                    ),
            ),
            if (!loading && errorMessage == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  12,
                ),
                child: ScheduleFormActions(
                  editing: editing,
                  saving: saving,
                  onCancel: onBack,
                  onSave: onSave,
                  onDelete: onDelete,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FormStatus extends StatelessWidget {
  const _FormStatus({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.text),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }
}
