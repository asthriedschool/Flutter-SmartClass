import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app_colors.dart';
import '../molecules/room_info_row.dart';
import '../organisms/room_device_config.dart';
import '../organisms/room_form_header.dart';
import '../organisms/room_picture_section.dart';

class RoomFormTemplate extends StatelessWidget {
  const RoomFormTemplate({
    super.key,
    required this.editing,
    required this.saving,
    required this.formKey,
    required this.nameController,
    required this.buildingController,
    required this.floorController,
    required this.delayController,
    required this.status,
    required this.mode,
    required this.picture,
    required this.lampCount,
    required this.acCount,
    required this.projectorCount,
    required this.onBack,
    required this.onStatusChanged,
    required this.onModeChanged,
    required this.onPictureAction,
    required this.onRemovePicture,
    required this.onSave,
  });

  final bool editing;
  final bool saving;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController buildingController;
  final TextEditingController floorController;
  final TextEditingController delayController;
  final String status;
  final String mode;
  final String? picture;
  final int? lampCount;
  final int? acCount;
  final int? projectorCount;
  final VoidCallback onBack;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onPictureAction;
  final VoidCallback onRemovePicture;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B4261), AppColors.background],
          stops: [0, 0.28],
        ),
      ),
      child: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    16,
                  ),
                  children: [
                    RoomFormHeader(
                      title: editing
                          ? 'Edit Room'
                          : 'Add Room',
                      subtitle: editing
                          ? 'Update room information and device setup'
                          : 'Create a new smart classroom',
                      onBack: onBack,
                    ),
                    const SizedBox(height: 18),
                    _InfoCard(
                      nameController: nameController,
                      buildingController:
                          buildingController,
                      floorController: floorController,
                    ),
                    const SizedBox(height: 12),
                    RoomPictureSection(
                      picture: picture,
                      onAddOrChange: onPictureAction,
                      onRemove: onRemovePicture,
                    ),
                    const SizedBox(height: 12),
                    RoomDeviceConfig(
                      lampCount: lampCount,
                      acCount: acCount,
                      projectorCount: projectorCount,
                    ),
                    const SizedBox(height: 12),
                    _ControlCard(
                      delayController: delayController,
                      status: status,
                      mode: mode,
                      onStatusChanged: onStatusChanged,
                      onModeChanged: onModeChanged,
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
                      child: OutlinedButton(
                        onPressed: saving ? null : onBack,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.text,
                          backgroundColor: const Color(
                            0xFF3A3D42,
                          ),
                          side: BorderSide.none,
                          minimumSize:
                              const Size.fromHeight(48),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: saving ? null : onSave,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              AppColors.primary,
                          minimumSize:
                              const Size.fromHeight(48),
                          shape: const StadiumBorder(),
                        ),
                        child: Text(
                          saving
                              ? 'Menyimpan...'
                              : editing
                              ? 'Save Changes'
                              : 'Create Room',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.nameController,
    required this.buildingController,
    required this.floorController,
  });

  final TextEditingController nameController;
  final TextEditingController buildingController;
  final TextEditingController floorController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 2),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Room Information',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Basic information about this classroom',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          RoomInfoRow(
            iconName: 'DevicesImg.svg',
            label: 'Room Name',
            iconWidth: 16,
            iconHeight: 20,
            child: _boxField(
              controller: nameController,
              hint: 'e.g. GK 1 - LAB 505',
              emptyMessage: 'Nama ruangan wajib diisi.',
            ),
          ),
          RoomInfoRow(
            iconName: 'BuildingImg.svg',
            label: 'Building',
            iconWidth: 12,
            iconHeight: 22,
            child: _boxField(
              controller: buildingController,
              hint: 'Gedung',
              emptyMessage: 'Gedung wajib diisi.',
            ),
          ),
          RoomInfoRow(
            iconName: 'FloorImg.svg',
            label: 'Floor',
            iconWidth: 14,
            iconHeight: 22,
            child: _boxField(
              controller: floorController,
              hint: 'Lantai',
              emptyMessage: 'Lantai wajib diisi.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _boxField({
    required TextEditingController controller,
    required String hint,
    required String emptyMessage,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 12,
        ),
        filled: true,
        fillColor: const Color(0xFF1A1D21),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        enabledBorder: _border,
        focusedBorder: _border.copyWith(
          borderSide: const BorderSide(
            color: AppColors.primary,
          ),
        ),
        errorBorder: _border.copyWith(
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        focusedErrorBorder: _border.copyWith(
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return emptyMessage;
        }
        return null;
      },
    );
  }

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: Color(0xFF5C636A)),
  );
}

class _ControlCard extends StatelessWidget {
  const _ControlCard({
    required this.delayController,
    required this.status,
    required this.mode,
    required this.onStatusChanged,
    required this.onModeChanged,
  });

  final TextEditingController delayController;
  final String status;
  final String mode;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2F33),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status and mode',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Required by the room service',
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          _choice(
            label: 'System status',
            value: status,
            options: const {
              'ENABLED': 'Enabled',
              'DISABLED': 'Disabled',
            },
            onChanged: onStatusChanged,
          ),
          const SizedBox(height: 10),
          _choice(
            label: 'Operation mode',
            value: mode,
            options: const {
              'AUTO': 'Auto',
              'MANUAL': 'Manual',
            },
            onChanged: onModeChanged,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: delayController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(color: AppColors.text),
            decoration: const InputDecoration(
              labelText: 'Auto off delay (minutes)',
              labelStyle: TextStyle(color: AppColors.muted),
              filled: true,
              fillColor: Color(0xFF1A1D21),
              enabledBorder: _InfoCard._border,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(8),
                ),
                borderSide: BorderSide(
                  color: AppColors.primary,
                ),
              ),
            ),
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) {
                return 'Auto off delay wajib diisi.';
              }
              final parsed = int.tryParse(text);
              if (parsed == null || parsed < 0) {
                return 'Auto off delay tidak boleh kurang dari 0.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _choice({
    required String label,
    required String value,
    required Map<String, String> options,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: AppColors.card,
      style: const TextStyle(color: AppColors.text),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.muted),
        filled: true,
        fillColor: const Color(0xFF1A1D21),
        enabledBorder: _InfoCard._border,
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(color: AppColors.primary),
        ),
      ),
      items: [
        for (final entry in options.entries)
          DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value),
          ),
      ],
      onChanged: (next) {
        if (next != null) {
          onChanged(next);
        }
      },
    );
  }
}
