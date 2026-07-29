import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/role.dart';
import '../providers/auth_providers.dart';
import '../widgets/role_chip.dart';
import 'package:uuid/uuid.dart';

InputDecoration _dialogFieldDecoration(String label) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppTheme.dividerColor),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppTheme.dividerColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
    );

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              _showCreateUserDialog(context, ref);
            },
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final u = users[index];
              return _buildUserCard(context, ref, u);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
            child: Text('Failed to load users',
                style: TextStyle(color: AppTheme.errorColor))),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
          child: Text(
            user.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
                color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Text(user.employeeId,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(width: 8),
              RoleChip(role: user.role),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white54),
          onPressed: () {
            _showUserOptions(context, ref, user);
          },
        ),
      ),
    );
  }

  void _showUserOptions(BuildContext context, WidgetRef ref, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                user.isActive ? Icons.block : Icons.check_circle,
                color: user.isActive
                    ? AppTheme.warningColor
                    : AppTheme.successColor,
              ),
              title: Text(
                user.isActive ? 'Disable Account' : 'Enable Account',
                style: TextStyle(
                    color: user.isActive
                        ? AppTheme.warningColor
                        : AppTheme.successColor),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final newStatus = !user.isActive;
                await ref
                    .read(authRepositoryProvider)
                    .toggleUserStatus(user.id, newStatus);
                ref.invalidate(userListProvider);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        '${newStatus ? "Enabled" : "Disabled"} ${user.name}')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final empIdCtrl = TextEditingController();
    final pwdCtrl = TextEditingController();
    Role selectedRole = Role.operator;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Create User', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _dialogFieldDecoration('Full Name'),
                ),
                TextField(
                  controller: empIdCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _dialogFieldDecoration('Employee ID'),
                ),
                TextField(
                  controller: pwdCtrl,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _dialogFieldDecoration('Temporary Password'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Role>(
                  value: selectedRole,
                  dropdownColor: AppTheme.surfaceColor,
                  items: Role.values
                      .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(r.name,
                              style: const TextStyle(color: Colors.white))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedRole = val);
                  },
                  decoration: _dialogFieldDecoration('Role'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty ||
                  empIdCtrl.text.isEmpty ||
                  pwdCtrl.text.isEmpty) return;

              final newUser = User(
                id: const Uuid().v4(),
                employeeId: empIdCtrl.text.trim(),
                name: nameCtrl.text.trim(),
                role: selectedRole,
                warehouse: 'WH-01',
              );

              final offlineAuth = ref.read(offlineAuthProvider);
              await offlineAuth.registerUser(newUser, pwdCtrl.text);

              ref.invalidate(userListProvider);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
