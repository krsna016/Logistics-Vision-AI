import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/role.dart';
import '../widgets/role_chip.dart';

class RolePoliciesScreen extends StatelessWidget {
  const RolePoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Policies'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: Role.values.length,
        itemBuilder: (context, index) {
          final role = Role.values[index];
          return _buildRolePolicyCard(role);
        },
      ),
    );
  }

  Widget _buildRolePolicyCard(Role role) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                RoleChip(role: role),
                const Spacer(),
                const Text('Static Policy',
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildPermissionRow('Manage Wagons', role.canManageWagons),
                _buildPermissionRow('Complete Trucks', role.canCompleteTrucks),
                _buildPermissionRow('View Analytics', role.canViewAnalytics),
                _buildPermissionRow('Export Reports', role.canExportReports),
                _buildPermissionRow('Manage Users', role.canManageUsers),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow(String label, bool isGranted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.cancel,
            color: isGranted ? AppTheme.successColor : Colors.white24,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isGranted ? Colors.white : Colors.white54,
              decoration:
                  isGranted ? TextDecoration.none : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
}
