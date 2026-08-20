import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../providers/auth_providers.dart';

class AdminSecurityScreen extends ConsumerWidget {
  const AdminSecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    if (user == null || !user.isAdmin) {
      return const Scaffold(
        body: Center(
            child: Text('Unauthorized Access',
                style: TextStyle(color: AppTheme.errorColor))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Access'),
      ),
      drawerScrimColor: Colors.black.withValues(alpha: 0.86),
      endDrawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('USER MANAGEMENT',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _buildActionTile(context, Icons.people, 'Manage Users',
              'Add, edit, or disable warehouse staff', '/admin/security/users'),
          _buildActionTile(
              context,
              Icons.security,
              'Role Policies',
              'Modify permission boundaries for roles',
              '/admin/security/roles'),
          const SizedBox(height: 32),
          const Text('DEVICE MANAGEMENT',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _buildUnavailableTile(
            Icons.devices,
            'Active Devices',
            'Device-wide revocation is not available in this local-data release.',
          ),
          const SizedBox(height: 32),
          const Text('GLOBAL AUDIT',
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _buildUnavailableTile(
            Icons.history,
            'System Audit Logs',
            'A central audit service is not enabled for this local-data release.',
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String title,
      String subtitle, String route) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: () {
          context.push(route);
        },
      ),
    );
  }

  Widget _buildUnavailableTile(IconData icon, String title, String subtitle) {
    return Opacity(
      opacity: 0.58,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppTheme.textSecondary),
          title: Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          trailing: const Icon(Icons.info_outline, color: Colors.white24),
        ),
      ),
    );
  }
}
