import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../network/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../shared/app_colors.dart';
import '../../shared/widgets/templates/manage_users_template.dart';
import '../../storage/token_storage.dart';
import '../login/login_screen.dart';
import 'user_form_screen.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() =>
      _ManageUsersScreenState();
}

class _ManageUsersScreenState
    extends State<ManageUsersScreen> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final TokenStorage _tokenStorage = TokenStorage();
  final TextEditingController _searchController =
      TextEditingController();

  List<AppUser> _users = const [];
  bool _loading = true;
  bool _unauthorized = false;
  String? _errorMessage;
  String _query = '';
  String _filter = 'All';
  final Set<int> _busyIds = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _unauthorized = false;
    });
    try {
      final token = await _tokenStorage.getAccessToken();
      final role = token == null
          ? null
          : _authService.roleFromAccessToken(token);
      if (role != 'ADMIN') {
        if (!mounted) {
          return;
        }
        setState(() {
          _loading = false;
          _errorMessage =
              'Anda tidak memiliki akses ke data ini.';
        });
        return;
      }
      final users = await _userService.getUsers();
      if (!mounted) {
        return;
      }
      setState(() {
        _users = users;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _unauthorized = error.unauthorized;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = 'Data pengguna gagal dimuat.';
      });
    }
  }

  List<AppUser> get _visibleUsers {
    final query = _query.trim().toLowerCase();
    return _users.where((user) {
      final matchesRole =
          _filter == 'All' || user.role == _filter;
      if (!matchesRole) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      return user.fullName.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();
  }

  bool get _hasActiveQuery =>
      _query.trim().isNotEmpty || _filter != 'All';

  Future<void> _openForm(AppUser? user) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => UserFormScreen(user: user),
      ),
    );
    if (saved == true) {
      await _load();
    }
  }

  Future<void> _delete(AppUser user) async {
    if (_busyIds.contains(user.idUser)) {
      return;
    }
    final name = user.fullName.isEmpty
        ? user.email
        : user.fullName;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Hapus pengguna?'),
          content: Text(
            '"$name" akan dihapus. Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _busyIds.add(user.idUser));
    try {
      await _userService.deleteUser(user.idUser);
      if (!mounted) {
        return;
      }
      _message('Pengguna berhasil dihapus.');
      await _load();
    } on ApiException catch (error) {
      if (error.unauthorized) {
        await _goToLogin();
        return;
      }
      _message(error.message);
    } catch (_) {
      _message('Pengguna gagal dihapus.');
    } finally {
      if (mounted) {
        setState(() => _busyIds.remove(user.idUser));
      }
    }
  }

  Future<void> _goToLogin() async {
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
    final adminCount = _users
        .where((user) => user.role == 'ADMIN')
        .length;
    final petugasCount = _users
        .where((user) => user.role == 'PETUGAS')
        .length;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: ManageUsersTemplate(
        searchController: _searchController,
        onSearchChanged: (value) =>
            setState(() => _query = value),
        onClearSearch: () {
          _searchController.clear();
          setState(() => _query = '');
        },
        filter: _filter,
        onFilterSelected: (value) =>
            setState(() => _filter = value),
        users: _visibleUsers,
        total: _users.length,
        adminCount: adminCount,
        petugasCount: petugasCount,
        loading: _loading,
        errorMessage: _errorMessage,
        unauthorized: _unauthorized,
        busyIds: _busyIds,
        hasActiveQuery: _hasActiveQuery,
        onBack: () => Navigator.of(context).maybePop(),
        onAdd: () => _openForm(null),
        onRetry: _load,
        onLogin: _goToLogin,
        onEdit: _openForm,
        onDelete: _delete,
      ),
    );
  }
}
