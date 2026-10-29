import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../shared/widgets/organisms/login_form_card.dart';
import '../../shared/widgets/templates/login_template.dart';
import '../admin/admin_dashboard.dart';
import '../petugas/petugas_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _emailError;
  String? _passwordError;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(email);
    if (!valid) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password wajib diisi.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_loading) {
      return;
    }
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final emailError = _validateEmail(email);
    final passwordError = _validatePassword(password);
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
      _formError = null;
    });
    if (emailError != null || passwordError != null) {
      return;
    }

    setState(() => _loading = true);
    try {
      final auth = await _authService.login(
        email: email,
        password: password,
      );
      final role = _authService.roleFromAccessToken(
        auth.accessToken,
      );
      if (!mounted) {
        return;
      }
      final Widget? page = switch (role) {
        'ADMIN' => const AdminDashboard(),
        'PETUGAS' => const PetugasDashboard(),
        _ => null,
      };
      if (page == null) {
        await _authService.logout();
        if (!mounted) {
          return;
        }
        setState(() {
          _loading = false;
          _formError =
              'Peran akun tidak dikenali. Hubungi admin.';
        });
        return;
      }
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => page),
      );
    } on AuthException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _formError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _formError = 'Login gagal. Coba lagi.';
      });
    }
  }

  void _showUnavailable(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return LoginTemplate(
      card: LoginFormCard(
        emailController: _emailController,
        passwordController: _passwordController,
        emailError: _emailError,
        passwordError: _passwordError,
        formError: _formError,
        loading: _loading,
        obscurePassword: _obscurePassword,
        onEmailChanged: (_) {
          if (_emailError != null || _formError != null) {
            setState(() {
              _emailError = null;
              _formError = null;
            });
          }
        },
        onPasswordChanged: (_) {
          if (_passwordError != null ||
              _formError != null) {
            setState(() {
              _passwordError = null;
              _formError = null;
            });
          }
        },
        onTogglePassword: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        onForgotPassword: () => _showUnavailable(
          'Reset password belum tersedia.',
        ),
        onSubmit: _submit,
        onRegister: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const RegisterScreen(),
            ),
          );
        },
      ),
    );
  }
}
