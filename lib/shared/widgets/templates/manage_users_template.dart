import 'package:flutter/material.dart';

import '../../../models/user.dart';
import '../../app_colors.dart';
import '../molecules/user_role_filter.dart';
import '../molecules/user_search_field.dart';
import '../organisms/manage_users_header.dart';
import '../organisms/user_account_card.dart';
import '../organisms/user_summary_row.dart';

class ManageUsersTemplate extends StatelessWidget {
  const ManageUsersTemplate({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.filter,
    required this.onFilterSelected,
    required this.users,
    required this.total,
    required this.adminCount,
    required this.petugasCount,
    required this.loading,
    required this.errorMessage,
    required this.unauthorized,
    required this.busyIds,
    required this.hasActiveQuery,
    required this.onBack,
    required this.onAdd,
    required this.onRetry,
    required this.onLogin,
    required this.onEdit,
    required this.onDelete,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final String filter;
  final ValueChanged<String> onFilterSelected;
  final List<AppUser> users;
  final int total;
  final int adminCount;
  final int petugasCount;
  final bool loading;
  final String? errorMessage;
  final bool unauthorized;
  final Set<int> busyIds;
  final bool hasActiveQuery;
  final VoidCallback onBack;
  final VoidCallback onAdd;
  final VoidCallback onRetry;
  final VoidCallback onLogin;
  final ValueChanged<AppUser> onEdit;
  final ValueChanged<AppUser> onDelete;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B4261), AppColors.background],
          stops: [0, 0.28],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                8,
                12,
                0,
              ),
              child: ManageUsersHeader(
                onBack: onBack,
                onAdd: onAdd,
              ),
            ),
            Expanded(child: _body(context)),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
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
              onPressed: unauthorized ? onLogin : onRetry,
              child: Text(
                unauthorized ? 'Login' : 'Coba lagi',
              ),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        UserSearchField(
          controller: searchController,
          onChanged: onSearchChanged,
          onClear: onClearSearch,
        ),
        const SizedBox(height: 12),
        UserRoleFilter(
          selected: filter,
          onSelected: onFilterSelected,
        ),
        const SizedBox(height: 14),
        UserSummaryRow(
          total: total,
          adminCount: adminCount,
          petugasCount: petugasCount,
        ),
        const SizedBox(height: 16),
        if (users.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(
              hasActiveQuery
                  ? 'Tidak ada pengguna yang cocok.'
                  : 'Belum ada pengguna.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
              ),
            ),
          )
        else
          for (final user in users) ...[
            UserAccountCard(
              user: user,
              busy: busyIds.contains(user.idUser),
              onEdit: () => onEdit(user),
              onDelete: () => onDelete(user),
            ),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}
