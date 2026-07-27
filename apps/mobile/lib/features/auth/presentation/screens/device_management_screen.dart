import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';
import '../../domain/entities/device_session.dart';
import '../providers/auth_providers.dart';

class DeviceManagementScreen extends ConsumerWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(deviceListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Devices'),
      ),
      body: devicesAsync.when(
        data: (devices) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              return _buildDeviceCard(context, ref, devices[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Failed to load devices', style: TextStyle(color: AppTheme.errorColor))),
      ),
    );
  }

  Widget _buildDeviceCard(BuildContext context, WidgetRef ref, DeviceSession device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Icon(
          Icons.smartphone,
          color: device.isActive ? AppTheme.primaryColor : Colors.white24,
          size: 32,
        ),
        title: Row(
          children: [
            Text(device.deviceName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            if (!device.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('REVOKED', style: TextStyle(color: AppTheme.errorColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${device.deviceModel} • ${device.osVersion}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 2),
              Text('Last Sync: ${device.lastSync.toLocal().toString().split('.')[0]}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
        trailing: device.isActive
            ? IconButton(
                icon: const Icon(Icons.block, color: AppTheme.errorColor),
                onPressed: () {
                  ref.read(authRepositoryProvider).revokeDevice(device.id);
                  ref.invalidate(deviceListProvider);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Revoked ${device.deviceName}')));
                },
              )
            : null,
      ),
    );
  }
}
