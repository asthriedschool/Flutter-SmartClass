import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class ScheduleFormActions extends StatelessWidget {
  const ScheduleFormActions({
    super.key,
    required this.editing,
    required this.saving,
    required this.onCancel,
    required this.onSave,
    required this.onDelete,
  });

  final bool editing;
  final bool saving;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (editing && onDelete != null) ...[
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: saving ? null : onDelete,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB42318),
                foregroundColor: AppColors.text,
                disabledBackgroundColor: const Color(
                  0xFF6E2A24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              icon: const LocalAssetImage(
                directory: scheduleAssetDir,
                name: 'Trash.svg',
                width: 16,
                height: 16,
                semanticLabel: 'Delete Schedule',
              ),
              label: const Text('Delete Schedule'),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: saving ? null : onCancel,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF3A3C40,
                    ),
                    foregroundColor: AppColors.text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        24,
                      ),
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
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        24,
                      ),
                    ),
                  ),
                  child: Text(
                    saving
                        ? 'Menyimpan...'
                        : editing
                        ? 'Save Changes'
                        : 'Create Schedule',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
