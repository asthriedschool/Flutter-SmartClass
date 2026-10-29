import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../organisms/profile_header.dart';
import '../organisms/profile_info_section.dart';
import '../organisms/smart_bottom_nav.dart';

class ProfileTemplate extends StatelessWidget {
  const ProfileTemplate({
    super.key,
    required this.loading,
    required this.errorMessage,
    required this.fullName,
    required this.email,
    required this.role,
    required this.initials,
    required this.appVersion,
    required this.onRetry,
    required this.onLogout,
    required this.onNavSelected,
  });

  final bool loading;
  final String? errorMessage;
  final String fullName;
  final String email;
  final String role;
  final String initials;
  final String appVersion;
  final VoidCallback onRetry;
  final VoidCallback onLogout;
  final ValueChanged<int> onNavSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B4261),
                  AppColors.background,
                ],
                stops: [0, 0.28],
              ),
            ),
            child: SafeArea(bottom: false, child: _body()),
          ),
        ),
        SmartBottomNav(
          currentIndex: 3,
          onSelected: onNavSelected,
          items: adminBottomNavItems,
        ),
      ],
    );
  }

  Widget _body() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }
    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.text,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Account information',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),
        ProfileHeader(
          fullName: fullName,
          email: email,
          role: role,
          initials: initials,
        ),
        const SizedBox(height: 14),
        ProfileInfoSection(
          title: 'Account Information',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileInfoRow(
                label: 'Full name',
                value: fullName.isEmpty
                    ? 'Tidak tersedia'
                    : fullName,
              ),
              ProfileInfoRow(
                label: 'Email',
                value: email.isEmpty
                    ? 'Tidak tersedia'
                    : email,
              ),
              ProfileInfoRow(
                label: 'Role',
                value: role.isEmpty
                    ? 'Tidak tersedia'
                    : role,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ProfileInfoSection(
          title: 'Security',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton(
                onPressed: onLogout,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFB42318),
                  foregroundColor: AppColors.text,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Logout'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ProfileInfoSection(
          title: 'About SmartClass',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileInfoRow(
                label: 'Application',
                value: 'SmartClass',
              ),
              ProfileInfoRow(
                label: 'Version',
                value: appVersion,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
