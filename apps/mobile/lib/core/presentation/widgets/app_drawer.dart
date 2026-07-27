import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../features/wagon/presentation/providers/wagon_providers.dart';
import '../../../features/truck/presentation/providers/truck_providers.dart';
import '../../../features/layer/presentation/providers/layer_providers.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import 'action_warning_dialog.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, user),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  
                  const SizedBox(height: 4),
                  _buildSectionLabel('CORE OPERATIONS'),
                  _buildSection([
                    _buildTile(
                      icon: Icons.analytics_outlined,
                      title: 'Analytics & Operations',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/wagons');
                        context.push('/dashboard');
                      },
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.dashboard_rounded,
                      title: 'Wagon Control Center',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/wagons');
                      },
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.description_outlined,
                      title: 'Digital Registers',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/wagons');
                        context.push('/registers');
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 4),
                  _buildSectionLabel('RESOURCES'),
                  _buildSection([
                    _buildTile(
                      icon: Icons.menu_book_rounded,
                      title: 'Documentation',
                      subtitle: 'User manuals & workflow guides',
                      iconColor: AppTheme.primaryColor,
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/wagons');
                        context.push('/manual');
                      },
                    ),
                  ]),

                  const SizedBox(height: 4),
                  _buildSectionLabel('DEVELOPER & TOOLS'),
                  _buildSection([
                    _buildTile(
                      icon: Icons.refresh_rounded,
                      title: 'Sync & Refresh Data',
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(truckListProvider.notifier).refresh();
                        await ref.read(wagonListProvider.notifier).refresh();
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data refreshed successfully.')));
                      },
                    ),

                    _buildDivider(),
                    _buildTile(
                      icon: Icons.bug_report_rounded,
                      title: 'Load Demo Data',
                      subtitle: 'Inject mock data for testing',
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () {
                        _confirmDemoDataLoad(context, ref);
                      },
                    ),
                  ]),
                  

                  const SizedBox(height: 4),
                  _buildSectionLabel('ACCOUNT'),
                  _buildSection([
                    _buildTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (context.mounted) {
                          Navigator.pop(context); // close drawer
                          context.go('/login');
                        }
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 32),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Vinayak SmartLoad v1.0.0\nSecure Enterprise Release',
                        style: TextStyle(color: Colors.white30, fontSize: 11, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, user) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 36,
                width: 36,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vinayak SmartLoad',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enterprise Warehouse System',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (user != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          user.role.displayName.toUpperCase(),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8, top: 8),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.white.withValues(alpha: 0.7), size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: textColor?.withValues(alpha: 0.7) ?? Colors.white.withValues(alpha: 0.5), fontSize: 11))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 18),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppTheme.dividerColor, indent: 48, endIndent: 12);
  }

  void _confirmDemoDataLoad(BuildContext context, WidgetRef ref) {
    // Capture provider references before showing dialog, since the drawer
    // (and its ConsumerElement) will be disposed by the time onConfirm runs.
    final wagonRepo = ref.read(wagonRepositoryProvider);
    final truckRepo = ref.read(truckRepositoryProvider);
    final layerRepo = ref.read(layerRepositoryProvider);
    final wagonNotifier = ref.read(wagonListProvider.notifier);
    final truckNotifier = ref.read(truckListProvider.notifier);

    showDialog<void>(
      context: context,
      builder: (ctx) => ActionWarningDialog(
        title: 'Load Demo Data?',
        content: 'WARNING: This will permanently DELETE all current local data (wagons, trucks, layers) and replace them with mock data for testing. This action cannot be undone.',
        actionLabel: 'Inject Demo Data',
        actionColor: Colors.redAccent,
        icon: Icons.bug_report_rounded,
        onConfirm: () async {
          Navigator.of(context).pop(); // close drawer
          
          // Clear data (must delete children before parents to avoid FK errors)
          await layerRepo.clearAllData();
          await truckRepo.clearAllData();
          await wagonRepo.clearAllData();

          // Load data (must insert parents before children)
          await wagonRepo.loadDemoData();
          await truckRepo.loadDemoData();
          await layerRepo.loadDemoData();

          wagonNotifier.refresh();
          truckNotifier.refresh();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo Data Loaded successfully.')));
          }
        },
      ),
    );
  }
}
