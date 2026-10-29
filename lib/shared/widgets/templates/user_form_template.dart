import 'package:flutter/material.dart';

import '../../app_colors.dart';
import '../atoms/schedule_field.dart';
import '../organisms/schedule_form_header.dart';
import '../organisms/schedule_form_section.dart';

class UserFormTemplate extends StatelessWidget {
  const UserFormTemplate({
    super.key,
    required this.editing,
    required this.saving,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.role,
    required this.accountStatus,
    required this.obscurePassword,
    required this.onBack,
    required this.onRole,
    required this.onStatus,
    required this.onTogglePassword,
    required this.onSave,
  });

  final bool editing;
  final bool saving;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String role;
  final String accountStatus;
  final bool obscurePassword;
  final VoidCallback onBack;
  final ValueChanged<String?> onRole;
  final ValueChanged<String?> onStatus;
  final VoidCallback onTogglePassword;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final title = editing ? 'Edit User' : 'Add User';
    final subtitle = editing
        ? 'Update SmartClass account information'
        : 'Create a SmartClass account';
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
                    title: 'Account',
                    subtitle: 'Name, email, and password',
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const ScheduleFieldLabel(
                          'Full name',
                        ),
                        const SizedBox(height: 6),
                        ScheduleTextField(
                          controller: nameController,
                          hint: 'Full name',
                          enabled: !saving,
                        ),
                        const SizedBox(height: 10),
                        const ScheduleFieldLabel('Email'),
                        const SizedBox(height: 6),
                        ScheduleTextField(
                          controller: emailController,
                          hint: 'name@email.com',
                          enabled: !saving,
                          keyboardType:
                              TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 10),
                        ScheduleFieldLabel(
                          editing
                              ? 'New password'
                              : 'Password',
                        ),
                        const SizedBox(height: 6),
                        ScheduleTextField(
                          controller: passwordController,
                          hint: 'Password',
                          enabled: !saving,
                          obscureText: obscurePassword,
                          suffix: IconButton(
                            tooltip: obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            onPressed: onTogglePassword,
                            icon: Icon(
                              obscurePassword
                                  ? Icons
                                        .visibility_outlined
                                  : Icons
                                        .visibility_off_outlined,
                              color: AppColors.muted,
                              size: 20,
                            ),
                          ),
                        ),
                        if (editing) ...[
                          const SizedBox(height: 6),
                          const Text(
                            'Password baru wajib diisi. Server meminta password pada setiap pembaruan.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ScheduleFormSection(
                    title: 'Access',
                    subtitle: 'Role and account status',
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const ScheduleFieldLabel('Role'),
                        const SizedBox(height: 6),
                        ScheduleDropdownField<String>(
                          value: role,
                          hint: 'Role',
                          items: const [
                            DropdownMenuItem(
                              value: 'ADMIN',
                              child: Text('ADMIN'),
                            ),
                            DropdownMenuItem(
                              value: 'PETUGAS',
                              child: Text('PETUGAS'),
                            ),
                          ],
                          onChanged: saving ? null : onRole,
                        ),
                        const SizedBox(height: 10),
                        const ScheduleFieldLabel(
                          'Account status',
                        ),
                        const SizedBox(height: 6),
                        ScheduleDropdownField<String>(
                          value: accountStatus,
                          hint: 'Account status',
                          items: const [
                            DropdownMenuItem(
                              value: 'ACTIVE',
                              child: Text('ACTIVE'),
                            ),
                            DropdownMenuItem(
                              value: 'INACTIVE',
                              child: Text('INACTIVE'),
                            ),
                          ],
                          onChanged: saving
                              ? null
                              : onStatus,
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
                              : 'Create User',
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
