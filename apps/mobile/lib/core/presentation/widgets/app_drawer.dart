import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryDark,
              border: Border(bottom: BorderSide(color: AppTheme.surfaceDark, width: 2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_shipping, color: AppTheme.primaryBlue, size: 36),
                    const SizedBox(width: 12),
                    Text(
                      'Vinayak\nSmartLoad',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Powered by Vinayak Logistics',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: Colors.white70),
            title: const Text('Wagon Control Center', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // We are already on the dashboard, so just close the drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: Colors.white70),
            title: const Text('Digital Registers', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              context.push('/registers');
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Divider(color: AppTheme.surfaceDark),
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: AppTheme.primaryBlue),
            title: const Text('Documentation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('User manual & guides', style: TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () {
              Navigator.pop(context);
              context.push('/manual');
            },
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.white30, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
