import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/templates/profile_template.dart';
import '../../storage/token_storage.dart';
import '../admin/room_page.dart';
import '../login/login_screen.dart';
import '../schedule/schedule_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const ProfilePage(),
      ),
    );
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();

  bool _loading = true;
  String? _errorMessage;
  String _fullName = '';
  String _email = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() {
          _loading = false;
          _errorMessage =
              'Sesi tidak valid. Silakan login kembali.';
        });
        return;
      }
      final name = _authService.fullNameFromAccessToken(
        token,
      );
      final email = _authService.emailFromAccessToken(
        token,
      );
      final role = _authService.roleFromAccessToken(token);
      if (!mounted) {
        return;
      }
      setState(() {
        _fullName = name ?? '';
        _email = email ?? '';
        _role = role ?? '';
        _loading = false;
        if (_fullName.isEmpty && _email.isEmpty) {
          _errorMessage = 'Data profil tidak tersedia.';
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = 'Data profil gagal dimuat.';
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Logout?'),
          content: const Text(
            'Anda akan keluar dari akun ini.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    await _authService.logout();
    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      ),
      (_) => false,
    );
  }

  void _onNav(int index) {
    if (index == 3) {
      return;
    }
    if (index == 0) {
      Navigator.of(context)
          .popUntil((route) => route.isFirst);
      return;
    }
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const RoomPage(),
        ),
      );
      return;
    }
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const SchedulePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ProfileTemplate(
        loading: _loading,
        errorMessage: _errorMessage,
        fullName: _fullName,
        email: _email,
        role: _role,
        initials: userInitials(_fullName),
        appVersion: '1.0.0',
        onRetry: _load,
        onLogout: _logout,
        onNavSelected: _onNav,
      ),
    );
  }
}
