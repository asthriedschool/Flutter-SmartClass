import 'package:flutter/material.dart';

import '../../../screens/schedule/schedule_status.dart';
import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.roomName,
    required this.modeLabel,
    required this.phase,
    required this.subject,
    required this.timeLabel,
    required this.dateLabel,
    required this.lecturerName,
    required this.pictureUrl,
    required this.canManage,
    required this.busy,
    required this.onEdit,
    required this.onDelete,
  });

  final String roomName;
  final String modeLabel;
  final SchedulePhase phase;
  final String subject;
  final String timeLabel;
  final String dateLabel;
  final String? lecturerName;
  final String? pictureUrl;
  final bool canManage;
  final bool busy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final status = schedulePhaseLabel(phase);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: _Photo(url: pictureUrl),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xCC0B4261),
                        const Color(0xE6050607),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  12,
                  14,
                  12,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            roomName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        _Badge(
                          text: modeLabel,
                          color: const Color(0xFF3DB7FF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subject.isEmpty
                          ? 'Subject tidak tersedia'
                          : subject,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _Meta(
                      icon: 'Clock.svg',
                      text: timeLabel,
                    ),
                    const SizedBox(height: 4),
                    _Meta(
                      icon: 'Calendar 1.svg',
                      text: dateLabel,
                    ),
                    if (lecturerName != null) ...[
                      const SizedBox(height: 4),
                      _Meta(
                        icon: 'User.svg',
                        text: lecturerName!,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Badge(
                          text: status,
                          color: _statusColor(phase),
                        ),
                        const Spacer(),
                        if (canManage) ...[
                          _Action(
                            tooltip: 'Edit',
                            asset: 'Edit Pencil.svg',
                            enabled: !busy,
                            onPressed: onEdit,
                          ),
                          _Action(
                            tooltip: 'Delete',
                            asset: 'Trash.svg',
                            enabled: !busy,
                            onPressed: onDelete,
                          ),
                        ],
                      ],
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

class _Photo extends StatelessWidget {
  const _Photo({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final network =
        url != null &&
        (url!.startsWith('http://') ||
            url!.startsWith('https://'));
    if (network) {
      return Image.network(
        url!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const _FallbackPhoto(),
      );
    }
    return const _FallbackPhoto();
  }
}

class _FallbackPhoto extends StatelessWidget {
  const _FallbackPhoto();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/asset_login_page/FotoKelas.png',
      fit: BoxFit.cover,
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LocalAssetImage(
          directory: scheduleAssetDir,
          name: icon,
          width: 14,
          height: 14,
          semanticLabel: text,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.tooltip,
    required this.asset,
    required this.enabled,
    required this.onPressed,
  });

  final String tooltip;
  final String asset;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onPressed : null,
      icon: LocalAssetImage(
        directory: scheduleAssetDir,
        name: asset,
        width: 18,
        height: 18,
        semanticLabel: tooltip,
      ),
    );
  }
}

Color _statusColor(SchedulePhase phase) {
  switch (phase) {
    case SchedulePhase.active:
      return AppColors.active;
    case SchedulePhase.upcoming:
      return const Color(0xFF3DB7FF);
    case SchedulePhase.finished:
      return AppColors.muted;
    case SchedulePhase.inactive:
      return AppColors.error;
  }
}
