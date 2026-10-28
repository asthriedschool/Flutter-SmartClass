import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/asset_image.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({
    super.key,
    required this.displayName,
    required this.onNotification,
  });

  final String? displayName;
  final VoidCallback onNotification;

  @override
  Widget build(BuildContext context) {
    final hasName =
        displayName != null && displayName!.isNotEmpty;
    final greeting = hasName
        ? 'Hi ${displayName!.split(' ').first},'
        : 'Selamat datang,';

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.input,
            shape: BoxShape.circle,
          ),
          child: const LocalAssetImage(
            directory: berandaAssetDir,
            name: 'ManageUser.svg',
            height: 24,
            semanticLabel: 'Profil admin',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Welcome back to Smart Class!',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary,
                  ),
                ),
                child: const Text(
                  'Admin',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: onNotification,
          icon: const LocalAssetImage(
            directory: berandaAssetDir,
            name: 'Notification.svg',
            height: 22,
            semanticLabel: 'Notifikasi',
          ),
        ),
      ],
    );
  }
}
