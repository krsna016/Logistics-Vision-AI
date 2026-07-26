import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../features/wagon/presentation/providers/wagon_providers.dart';
import '../../../features/truck/presentation/providers/truck_providers.dart';
import '../../../features/layer/presentation/providers/layer_providers.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('CORE OPERATIONS'),
                  _buildSection([
                    _buildTile(
                      icon: Icons.dashboard_rounded,
                      title: 'Wagon Control Center',
                      onTap: () {
                        Navigator.pop(context);
                        context.go('/wagons'); // Force route to ensure it works anywhere
                      },
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.description_outlined,
                      title: 'Digital Registers',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/registers');
                      },
                    ),
                  ]),
                  
                  const SizedBox(height: 12),
                  _buildSectionLabel('RESOURCES'),
                  _buildSection([
                    _buildTile(
                      icon: Icons.menu_book_rounded,
                      title: 'Documentation',
                      subtitle: 'User manuals & workflow guides',
                      iconColor: AppTheme.primaryColor,
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/manual');
                      },
                    ),
                  ]),

                  const SizedBox(height: 12),
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
                      icon: Icons.photo_library_rounded,
                      title: 'Dataset Mode',
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/dataset');
                      },
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.bug_report_rounded,
                      title: 'Load Demo Data',
                      subtitle: 'Inject mock data for testing',
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () async {
                        Navigator.pop(context);
                        await ref.read(wagonRepositoryProvider).clearAndLoadDemoData();
                        await ref.read(truckRepositoryProvider).clearAndLoadDemoData();
                        await ref.read(layerRepositoryProvider).clearAndLoadDemoData();
                        ref.read(wagonListProvider.notifier).refresh();
                        ref.read(truckListProvider.notifier).refresh();
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Demo Data Loaded.')));
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

  Widget _buildHeader(BuildContext context) {
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
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
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, fontWeight: FontWeight.w500),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
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
          ? Text(subtitle, style: TextStyle(color: textColor?.withValues(alpha: 0.7) ?? Colors.white.withValues(alpha: 0.5), fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, color: AppTheme.dividerColor, indent: 54, endIndent: 16);
  }
}
