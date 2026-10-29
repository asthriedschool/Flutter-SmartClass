import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../shared/widgets/organisms/register_form_card.dart';
import '../../shared/widgets/templates/login_template.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController =
      TextEditingController();
  final TextEditingController _emailController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();
  final TextEditingController _confirmController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _formError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) {
      return;
    }
    FocusScope.of(context).unfocus();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final nameError = name.isEmpty
        ? 'Nama lengkap wajib diisi.'
        : name.length > 100
        ? 'Nama lengkap maksimal 100 karakter.'
        : null;
    final emailError = _validateEmail(email);
    final passwordError = password.isEmpty
        ? 'Password wajib diisi.'
        : null;
    final confirmError = confirm.isEmpty
        ? 'Konfirmasi password wajib diisi.'
        : confirm != password
        ? 'Password tidak sama.'
        : null;
    setState(() {
      _nameError = nameError;
      _emailError = emailError;
      _passwordError = passwordError;
      _confirmError = confirmError;
      _formError = null;
    });
    if (nameError != null ||
        emailError != null ||
        passwordError != null ||
        confirmError != null) {
      return;
    }

    setState(() => _loading = true);
    try {
      await _authService.register(
        fullName: name,
        email: email,
        password: password,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Registrasi berhasil. Silakan login.',
            ),
          ),
        );
      Navigator.of(context).pop();
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
        _formError = 'Registrasi gagal. Coba lagi.';
      });
    }
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

  void _clearError(VoidCallback update) {
    if (_formError == null &&
        _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmError == null) {
      return;
    }
    setState(update);
  }

  @override
  Widget build(BuildContext context) {
    return LoginTemplate(
      card: RegisterFormCard(
        nameController: _nameController,
        emailController: _emailController,
        passwordController: _passwordController,
        confirmController: _confirmController,
        nameError: _nameError,
        emailError: _emailError,
        passwordError: _passwordError,
        confirmError: _confirmError,
        formError: _formError,
        loading: _loading,
        obscurePassword: _obscurePassword,
        obscureConfirm: _obscureConfirm,
        onNameChanged: (_) => _clearError(() {
          _nameError = null;
          _formError = null;
        }),
        onEmailChanged: (_) => _clearError(() {
          _emailError = null;
          _formError = null;
        }),
        onPasswordChanged: (_) => _clearError(() {
          _passwordError = null;
          _confirmError = null;
          _formError = null;
        }),
        onConfirmChanged: (_) => _clearError(() {
          _confirmError = null;
          _formError = null;
        }),
        onTogglePassword: () {
          setState(() {
            _obscurePassword = !_obscurePassword;
          });
        },
        onToggleConfirm: () {
          setState(() {
            _obscureConfirm = !_obscureConfirm;
          });
        },
        onSubmit: _submit,
        onLogin: () {
          if (!_loading) {
            Navigator.of(context).maybePop();
          }
        },
      ),
    );
  }
}
