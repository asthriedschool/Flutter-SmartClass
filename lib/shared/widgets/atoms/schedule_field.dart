import 'package:flutter/material.dart';

import '../../app_colors.dart';

const scheduleFieldFill = Color(0xFF1C1E22);
const scheduleFieldBorder = Color(0xFF3A3D42);

class ScheduleFieldLabel extends StatelessWidget {
  const ScheduleFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.muted,
        fontSize: 12,
      ),
    );
  }
}

class ScheduleTextField extends StatelessWidget {
  const ScheduleTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.enabled,
  });

  final TextEditingController controller;
  final String hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 14,
      ),
      decoration: _fieldDecoration(hint: hint),
    );
  }
}

class ScheduleDropdownField<T> extends StatelessWidget {
  const ScheduleDropdownField({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      hint: Text(
        hint,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
        ),
      ),
      dropdownColor: const Color(0xFF2A2C30),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.muted,
      ),
      style: const TextStyle(
        color: AppColors.text,
        fontSize: 13,
      ),
      decoration: _fieldDecoration(),
      items: items,
      onChanged: onChanged,
    );
  }
}

class SchedulePickerField extends StatelessWidget {
  const SchedulePickerField({
    super.key,
    required this.value,
    required this.hint,
    required this.icon,
    required this.onPressed,
  });

  final String? value;
  final String hint;
  final Widget icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final filled = value != null && value!.isNotEmpty;
    return Material(
      color: scheduleFieldFill,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: scheduleFieldBorder),
          ),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  filled ? value! : hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: filled
                        ? AppColors.text
                        : AppColors.muted,
                    fontSize: 13,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.muted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _fieldDecoration({String? hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      color: AppColors.muted,
      fontSize: 13,
    ),
    isDense: true,
    filled: true,
    fillColor: scheduleFieldFill,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 14,
    ),
    enabledBorder: _border(scheduleFieldBorder),
    disabledBorder: _border(scheduleFieldBorder),
    focusedBorder: _border(AppColors.primary),
    border: _border(scheduleFieldBorder),
  );
}

OutlineInputBorder _border(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );
}
