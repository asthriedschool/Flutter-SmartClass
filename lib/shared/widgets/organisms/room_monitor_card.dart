import 'package:flutter/material.dart';

import '../../app_colors.dart';

class RoomMonitorCard extends StatelessWidget {
  const RoomMonitorCard({
    super.key,
    required this.name,
    required this.modeLabel,
    required this.statusLabel,
    required this.active,
    required this.deviceLabel,
    required this.scheduleTime,
    required this.scheduleCaption,
    this.pictureUrl,
  });

  final String name;
  final String modeLabel;
  final String statusLabel;
  final bool active;
  final String deviceLabel;
  final String scheduleTime;
  final String scheduleCaption;
  final String? pictureUrl;

  static const fallbackPhoto =
      'assets/asset_login_page/FotoKelas.png';

  @override
  Widget build(BuildContext context) {
    final url = pictureUrl?.trim() ?? '';
    final network =
        url.startsWith('http://') ||
        url.startsWith('https://');
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 156,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (network)
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.asset(
                  fallbackPhoto,
                  fit: BoxFit.cover,
                ),
              )
            else
              Image.asset(fallbackPhoto, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xE60B3A5C),
                    Color(0xCC0E4E78),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ModePill(label: modeLabel),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.active
                              : const Color(0xFFFF5A5A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          statusLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.text,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: _Metric(
                          value: deviceLabel,
                          caption: 'Device ON',
                        ),
                      ),
                      Expanded(
                        child: _Metric(
                          value: scheduleTime,
                          caption: scheduleCaption,
                        ),
                      ),
                    ],
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

class _ModePill extends StatelessWidget {
  const _ModePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E6FEA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.caption,
  });

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFD5DDE6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
