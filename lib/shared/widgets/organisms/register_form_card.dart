import 'package:flutter/material.dart';

import '../../login_colors.dart';
import '../atoms/asset_image.dart';
import '../molecules/login_field.dart';

class RegisterFormCard extends StatelessWidget {
  const RegisterFormCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.nameError,
    required this.emailError,
    required this.passwordError,
    required this.confirmError,
    required this.formError,
    required this.loading,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmChanged,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSubmit,
    required this.onLogin,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String? nameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final String? formError;
  final bool loading;
  final bool obscurePassword;
  final bool obscureConfirm;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback onSubmit;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Buat Akun',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LoginColors.text,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Daftar sebagai petugas untuk\nmengakses Smart Class',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LoginColors.muted,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
        LoginField(
          controller: nameController,
          label: 'Nama lengkap',
          hint: 'Masukkan nama lengkap',
          icon: 'Add User Male.svg',
          errorText: nameError,
          textInputAction: TextInputAction.next,
          enabled: !loading,
          onChanged: onNameChanged,
        ),
        const SizedBox(height: 12),
        LoginField(
          controller: emailController,
          label: 'Email',
          hint: 'Masukkan email anda',
          icon: 'Email.svg',
          errorText: emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !loading,
          onChanged: onEmailChanged,
        ),
        const SizedBox(height: 12),
        LoginField(
          controller: passwordController,
          label: 'Password',
          hint: 'Masukkan password anda',
          icon: 'Password.svg',
          errorText: passwordError,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.next,
          enabled: !loading,
          onChanged: onPasswordChanged,
          suffix: IconButton(
            tooltip: obscurePassword
                ? 'Tampilkan password'
                : 'Sembunyikan password',
            onPressed: loading ? null : onTogglePassword,
            icon: const LocalAssetImage(
              name: 'Blind.svg',
              height: 22,
              semanticLabel: 'Visibilitas password',
            ),
          ),
        ),
        const SizedBox(height: 12),
        LoginField(
          controller: confirmController,
          label: 'Konfirmasi password',
          hint: 'Ulangi password anda',
          icon: 'Password.svg',
          errorText: confirmError,
          obscureText: obscureConfirm,
          textInputAction: TextInputAction.done,
          enabled: !loading,
          onSubmitted: (_) => onSubmit(),
          onChanged: onConfirmChanged,
          suffix: IconButton(
            tooltip: obscureConfirm
                ? 'Tampilkan password'
                : 'Sembunyikan password',
            onPressed: loading ? null : onToggleConfirm,
            icon: const LocalAssetImage(
              name: 'Blind.svg',
              height: 22,
              semanticLabel: 'Visibilitas password',
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (formError != null) ...[
          Text(
            formError!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: LoginColors.error,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
        ],
        SizedBox(
          height: 52,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: LoginColors.primary,
              disabledBackgroundColor: LoginColors.primary
                  .withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: loading ? null : onSubmit,
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: LoginColors.text,
                    ),
                  )
                : const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      LocalAssetImage(
                        name: 'Add User Male.svg',
                        height: 20,
                        semanticLabel: 'Daftar',
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Daftar',
                        style: TextStyle(
                          color: LoginColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: loading ? null : onLogin,
          child: const Text(
            'Sudah punya akun? Login',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LoginColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
