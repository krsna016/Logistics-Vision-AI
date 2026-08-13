import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../providers/auth_providers.dart';
import '../widgets/role_chip.dart';
import '../widgets/audit_timeline.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool? _trackingEnabled;
  bool _changingTracking = false;

  Future<void> _setTracking(bool enabled) async {
    if (_changingTracking) return;
    setState(() => _changingTracking = true);
    final notifier = ref.read(authProvider.notifier);
    final active = enabled
        ? await notifier.startLiveTracking()
        : await notifier.stopLiveTracking().then((_) => false);
    if (!mounted) return;
    setState(() {
      _trackingEnabled = active;
      _changingTracking = false;
    });
    if (enabled && !active) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Live location was not enabled. Allow the required location and notification permissions in Settings.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final sessionAsync = ref.watch(sessionProvider);
    final logsAsync = ref.watch(auditLogsProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }
    _trackingEnabled ??= ref.read(locationTrackingServiceProvider).isRunning;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      drawerScrimColor: Colors.black.withValues(alpha: 0.86),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(Icons.person, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.employeeId,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  RoleChip(role: user.role),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: SwitchListTile.adaptive(
                value: _trackingEnabled ?? false,
                onChanged: _changingTracking ? null : _setTracking,
                secondary: Icon(
                  Icons.location_on_outlined,
                  color: _trackingEnabled == true
                      ? AppTheme.successColor
                      : AppTheme.textSecondary,
                ),
                title: const Text('Share live work location'),
                subtitle: const Text(
                  'Optional. Shares precise location with authorized administrators, including while the app is in the background. Stops at logout.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text('CURRENT SESSION',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 12),

            sessionAsync.when(
              data: (session) {
                if (session == null) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(
                          'Device', session.deviceName, Icons.smartphone),
                      const Divider(color: Colors.white10, height: 24),
                      _buildInfoRow(
                          'Login Time',
                          '${session.loginTime.hour}:${session.loginTime.minute}',
                          Icons.access_time),
                      const Divider(color: Colors.white10, height: 24),
                      _buildInfoRow(
                          'Status',
                          session.isLocked ? 'Locked' : 'Active',
                          Icons.security),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),
            const Text('RECENT ACTIVITY',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 16),

            logsAsync.when(
              data: (logs) => AuditTimeline(logs: logs),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: 12),
        Text(label,
            style:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
