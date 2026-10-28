import 'package:flutter/material.dart';

import '../../login_colors.dart';
import '../atoms/asset_image.dart';
import '../molecules/login_field.dart';
import 'registration_prompt.dart';

class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailError,
    required this.passwordError,
    required this.formError,
    required this.loading,
    required this.obscurePassword,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onSubmit,
    required this.onRegister,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? emailError;
  final String? passwordError;
  final String? formError;
  final bool loading;
  final bool obscurePassword;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback onSubmit;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Selamat Datang',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LoginColors.text,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Login untuk mengakses\nsistem Smart Class',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: LoginColors.muted,
            fontSize: 14,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 22),
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
          textInputAction: TextInputAction.done,
          enabled: !loading,
          onSubmitted: (_) => onSubmit(),
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
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: loading ? null : onForgotPassword,
            child: const Text(
              'Lupa password?',
              style: TextStyle(
                color: LoginColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
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
                        name: 'Enter.svg',
                        height: 20,
                        semanticLabel: 'Masuk',
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Login',
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
        const Row(
          children: [
            Expanded(
              child: Divider(color: LoginColors.line),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'atau',
                style: TextStyle(
                  color: LoginColors.muted,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: LoginColors.line),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RegistrationPrompt(
          onTap: loading ? null : onRegister,
        ),
      ],
    );
  }
}
