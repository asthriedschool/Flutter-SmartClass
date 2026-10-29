import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../network/api_client.dart';
import '../../services/user_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/templates/user_form_template.dart';

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key, this.user});

  final AppUser? user;

  @override
  State<UserFormScreen> createState() =>
      _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final UserService _userService = UserService();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final TextEditingController _passwordController =
      TextEditingController();

  late String _role;
  late String _accountStatus;
  bool _saving = false;
  bool _obscurePassword = true;

  bool get _editing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(
      text: user?.fullName ?? '',
    );
    _emailController = TextEditingController(
      text: user?.email ?? '',
    );
    _role = user?.role == 'ADMIN' ? 'ADMIN' : 'PETUGAS';
    _accountStatus = user?.accountStatus == 'INACTIVE'
        ? 'INACTIVE'
        : 'ACTIVE';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final message = _validate(name, email, password);
    if (message != null) {
      _message(message);
      return;
    }
    setState(() => _saving = true);
    try {
      final existing = widget.user;
      if (existing == null) {
        await _userService.createUser(
          fullName: name,
          email: email,
          password: password,
          role: _role,
          accountStatus: _accountStatus,
        );
      } else {
        await _userService.updateUser(
          current: existing,
          fullName: name,
          email: email,
          password: password,
          role: _role,
          accountStatus: _accountStatus,
        );
      }
      if (!mounted) {
        return;
      }
      _message(
        existing == null
            ? 'Pengguna berhasil ditambahkan.'
            : 'Pengguna berhasil diperbarui.',
      );
      Navigator.of(context).pop(true);
    } on ApiException catch (error) {
      _message(error.message);
    } catch (_) {
      _message('Pengguna gagal disimpan.');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  String? _validate(
    String name,
    String email,
    String password,
  ) {
    if (name.isEmpty) {
      return 'Nama lengkap wajib diisi.';
    }
    if (name.length > 100) {
      return 'Nama lengkap maksimal 100 karakter.';
    }
    if (email.isEmpty) {
      return 'Email wajib diisi.';
    }
    if (email.length > 150 ||
        !email.contains('@') ||
        email.startsWith('@') ||
        email.endsWith('@')) {
      return 'Email tidak valid.';
    }
    if (password.trim().isEmpty) {
      return 'Password wajib diisi.';
    }
    if (_role != 'ADMIN' && _role != 'PETUGAS') {
      return 'Role wajib dipilih.';
    }
    if (_accountStatus != 'ACTIVE' &&
        _accountStatus != 'INACTIVE') {
      return 'Status akun wajib dipilih.';
    }
    return null;
  }

  void _message(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: UserFormTemplate(
        editing: _editing,
        saving: _saving,
        nameController: _nameController,
        emailController: _emailController,
        passwordController: _passwordController,
        role: _role,
        accountStatus: _accountStatus,
        obscurePassword: _obscurePassword,
        onBack: () {
          if (!_saving) {
            Navigator.of(context).maybePop();
          }
        },
        onRole: (value) {
          if (value == null) {
            return;
          }
          setState(() => _role = value);
        },
        onStatus: (value) {
          if (value == null) {
            return;
          }
          setState(() => _accountStatus = value);
        },
        onTogglePassword: () => setState(
          () => _obscurePassword = !_obscurePassword,
        ),
        onSave: _save,
      ),
    );
  }
}
