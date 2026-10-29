import '../models/user.dart';
import '../network/api_client.dart';

class UserService {
  UserService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<AppUser>> getUsers() async {
    final rows = await _apiClient.getList('/users');
    return rows.map(AppUser.fromJson).toList();
  }

  Future<AppUser> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String accountStatus,
  }) async {
    final json = await _apiClient.sendObject(
      'POST',
      '/users',
      fallback: 'Pengguna gagal ditambahkan.',
      body: {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'password': password,
        'role': role,
        'account_status': accountStatus,
        'profile_picture': null,
      },
    );
    return AppUser.fromJson(json);
  }

  Future<AppUser> updateUser({
    required AppUser current,
    required String fullName,
    required String email,
    required String password,
    required String role,
    required String accountStatus,
  }) async {
    final json = await _apiClient.sendObject(
      'PUT',
      '/users/${current.idUser}',
      fallback: 'Pengguna gagal diperbarui.',
      body: {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'password': password,
        'role': role,
        'account_status': accountStatus,
        'profile_picture': current.profilePicture,
        'last_login_at': userTimestamp(current.lastLoginAt),
      },
    );
    return AppUser.fromJson(json);
  }

  Future<void> deleteUser(int idUser) {
    return _apiClient.delete(
      '/users/$idUser',
      fallback: 'Pengguna gagal dihapus.',
    );
  }
}
