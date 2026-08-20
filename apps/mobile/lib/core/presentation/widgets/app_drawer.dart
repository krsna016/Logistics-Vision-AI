import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../features/wagon/presentation/providers/wagon_providers.dart';
import '../../../features/truck/presentation/providers/truck_providers.dart';
import '../../../features/layer/presentation/providers/layer_providers.dart';
import '../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../features/auth/domain/entities/user.dart';
import '../../../features/auth/domain/entities/role.dart';
import '../../../features/reports/presentation/providers/report_providers.dart'
    hide databaseProvider;
import '../../providers/database_provider.dart';
import '../../storage/local_data_archive_service.dart';
import 'action_warning_dialog.dart';
import '../../../utils/logger.dart';

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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  _buildTile(
                    icon: Icons.description_outlined,
                    title: 'Digital Registers',
                    subtitle: 'Wagon history and loading records',
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/wagons');
                      context.push('/registers');
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildTile(
                    icon: Icons.menu_book_rounded,
                    title: 'Documentation',
                    subtitle: 'User manuals and workflow guides',
                    iconColor: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/wagons');
                      context.push('/manual');
                    },
                  ),
                  if (user?.role == Role.administrator) ...[
                    const SizedBox(height: 8),
                    _buildTile(
                      icon: Icons.backup_outlined,
                      title: 'Backup & Restore',
                      subtitle: 'Create, import or restore local data',
                      iconColor: AppTheme.primaryColor,
                      onTap: () => _showBackupAndRestore(context, ref),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'Adjust carton-counting behavior locally',
                    iconColor: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  if (user?.role == Role.administrator) ...[
                    const SizedBox(height: 8),
                    _buildTile(
                      icon: Icons.storage_rounded,
                      title: 'Manage App Data',
                      subtitle: 'Load demo data or wipe screen',
                      iconColor: Colors.redAccent,
                      textColor: Colors.redAccent,
                      onTap: () => _showDemoAndClear(context, ref),
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildTile(
                    icon: Icons.logout_rounded,
                    title: 'Logout',
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Footer
          Container(
            color: const Color(0xFF1E2126), // Slightly lighter than background
            padding: EdgeInsets.only(
              top: 18,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 10
                  : 24,
            ),
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                context.push('/legal');
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28.0, vertical: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.blueAccent,
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Legal & Privacy',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBackupAndRestore(
      BuildContext context, WidgetRef ref) async {
    AppLogger.info('ADMIN ACTION: Opened Backup & Restore menu');
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Backup & Restore'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'create'),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.ios_share_rounded),
              title: Text('Create & share protected backup'),
              subtitle: Text('Password-protected database, photos and records'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'zip'),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.archive_outlined),
              title: Text('Import protected backup'),
              subtitle: Text('Choose a password-protected SmartLoad ZIP'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'previous'),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.history_rounded),
              title: Text('Restore previous local data'),
              subtitle: Text('Undo an earlier import or restore'),
            ),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case 'create':
        AppLogger.info('ADMIN ACTION: Selected "Create & share backup"');
        _confirmLocalDataArchive(context, ref);
        return;
      case 'zip':
        AppLogger.info('ADMIN ACTION: Selected "Import ZIP backup"');
        await _selectAuditArchive(context, choice: choice);
        return;
      case 'previous':
        AppLogger.info('ADMIN ACTION: Selected "Restore previous local data"');
        await _restorePreviousLocalData(context);
        return;
    }
  }

  Widget _buildHeader(BuildContext context, User? user) {
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
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
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
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor:
                        AppTheme.primaryColor.withValues(alpha: 0.2),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                        ),
                        Text(
                          user.role.displayName.toUpperCase(),
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10),
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

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon,
            color: iconColor ?? Colors.white.withValues(alpha: 0.7), size: 22),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: TextStyle(
                    color: textColor?.withValues(alpha: 0.7) ??
                        Colors.white.withValues(alpha: 0.5),
                    fontSize: 11))
            : null,
        trailing: const Icon(Icons.chevron_right_rounded,
            color: Colors.white24, size: 18),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        visualDensity: const VisualDensity(horizontal: 0, vertical: -1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showDemoAndClear(BuildContext context, WidgetRef ref) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Data Management'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'demo'),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.bug_report_rounded, color: Colors.orangeAccent),
              title: Text('Load Demo Data'),
              subtitle: Text('Replace local records with test data'),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'clear'),
            child: const ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
              title: Text('Clear Screen / Wipe Data'),
              subtitle:
                  Text('Wipe all local operational records (clean slate)'),
            ),
          ),
        ],
      ),
    );
    if (choice == null || !context.mounted) return;
    if (choice == 'demo') {
      _confirmDemoDataLoad(context, ref);
    } else if (choice == 'clear') {
      _confirmClearData(context, ref);
    }
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    final wagonRepo = ref.read(wagonRepositoryProvider);
    final truckRepo = ref.read(truckRepositoryProvider);
    final layerRepo = ref.read(layerRepositoryProvider);
    final database = ref.read(databaseProvider);
    final wagonNotifier = ref.read(wagonListProvider.notifier);
    final truckNotifier = ref.read(truckListProvider.notifier);
    final rootContext = context;

    showDialog<void>(
      context: context,
      builder: (_) => ActionWarningDialog(
        title: 'Clear Screen / Wipe Data?',
        content:
            'This completely deletes all operational records: wagons, trucks, layers, sessions, registers, reports, and audit history. User accounts and app settings remain safe. This gives you a completely clean, fresh app state.',
        actionLabel: 'Wipe All Data',
        actionColor: Colors.redAccent,
        icon: Icons.delete_forever_rounded,
        onConfirm: () async {
          Navigator.of(context).pop(); // close drawer

          showDialog<void>(
            context: rootContext,
            barrierDismissible: false,
            builder: (_) => const PopScope(
              canPop: false,
              child: AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Expanded(child: Text('Wiping all local data...')),
                  ],
                ),
              ),
            ),
          );

          try {
            await database.transaction(() async {
              await database.delete(database.detections).go();
              await database.delete(database.loadingSessions).go();
              await database.delete(database.digitalRegisters).go();
              await database.delete(database.auditLogs).go();
              await database.delete(database.reportExports).go();
            });
            await layerRepo.clearAllData();
            await truckRepo.clearAllData();
            await wagonRepo.clearAllData();

            wagonNotifier.refresh();
            truckNotifier.refresh();
            if (rootContext.mounted) {
              Navigator.of(rootContext, rootNavigator: true)
                  .pop(); // remove spinner
              ScaffoldMessenger.of(rootContext).showSnackBar(const SnackBar(
                content: Text('Screen cleared. App state is now empty.'),
              ));
            }
          } catch (e) {
            if (rootContext.mounted) {
              Navigator.of(rootContext, rootNavigator: true).pop();
              ScaffoldMessenger.of(rootContext).showSnackBar(SnackBar(
                content: Text('Failed to clear data: $e'),
                backgroundColor: AppTheme.errorColor,
              ));
            }
          }
        },
      ),
    );
  }

  void _confirmDemoDataLoad(BuildContext context, WidgetRef ref) {
    // Capture provider references before showing dialog, since the drawer
    // (and its ConsumerElement) will be disposed by the time onConfirm runs.
    final wagonRepo = ref.read(wagonRepositoryProvider);
    final truckRepo = ref.read(truckRepositoryProvider);
    final layerRepo = ref.read(layerRepositoryProvider);
    final database = ref.read(databaseProvider);
    final wagonNotifier = ref.read(wagonListProvider.notifier);
    final truckNotifier = ref.read(truckListProvider.notifier);
    final operatorName = ref.read(authProvider)?.name.trim();

    showDialog<void>(
      context: context,
      builder: (_) => ActionWarningDialog(
        title: 'Load Demo Data?',
        content:
            'This replaces all operational records with a fresh enterprise demo dataset: wagons, trucks, layers, sessions, registers, reports, and audit history. User accounts, login and app settings remain safe.',
        actionLabel: 'Load Demo Data',
        actionColor: Colors.redAccent,
        icon: Icons.bug_report_rounded,
        onConfirm: () async {
          Navigator.of(context).pop(); // close drawer

          // Clear operational data only. Accounts, device sessions, warehouses,
          // and settings are intentionally preserved.
          await database.transaction(() async {
            await database.delete(database.detections).go();
            await database.delete(database.loadingSessions).go();
            await database.delete(database.digitalRegisters).go();
            await database.delete(database.auditLogs).go();
            await database.delete(database.reportExports).go();
          });

          // Delete children before parents to satisfy foreign keys.
          await layerRepo.clearAllData();
          await truckRepo.clearAllData();
          await wagonRepo.clearAllData();

          // Load data (must insert parents before children)
          await wagonRepo.loadDemoData(operatorName: operatorName);
          await truckRepo.loadDemoData(operatorName: operatorName);
          await layerRepo.loadDemoData(operatorName: operatorName);

          final activeLayers = (await database.select(database.layers).get())
              .where((layer) => !layer.isDeleted)
              .toList();
          final activeTrucks = (await database.select(database.trucks).get())
              .where((truck) => !truck.isDeleted)
              .toList();
          if (operatorName != null && operatorName.isNotEmpty) {
            if (activeLayers.any((layer) => layer.operatorId != operatorName) ||
                (await database.select(database.auditLogs).get())
                    .any((audit) => audit.userId != operatorName)) {
              throw StateError('Demo operator identity failed validation.');
            }
          }
          for (final truck in activeTrucks) {
            final truckLayers = activeLayers
                .where((layer) => layer.truckId == truck.id)
                .toList();
            final cartons = truckLayers.fold<int>(
                0, (sum, layer) => sum + layer.cartonCount);
            final defects = truckLayers.fold<int>(
                0, (sum, layer) => sum + layer.defectCount);
            if (truck.totalLayers != truckLayers.length ||
                truck.totalCartons != cartons ||
                truck.totalDefects != defects) {
              throw StateError('Demo truck totals failed validation.');
            }
          }
          final wagons = (await database.select(database.wagons).get())
              .where((wagon) => !wagon.isDeleted);
          for (final wagon in wagons) {
            final manifest = <String, int>{};
            for (final item
                in (jsonDecode(wagon.itemManifestJson) as List<dynamic>)) {
              final value = item as Map<String, dynamic>;
              manifest[value['name'] as String] = value['quantity'] as int;
            }
            final wagonTruckIds = activeTrucks
                .where((truck) => truck.wagonId == wagon.id)
                .map((truck) => truck.id)
                .toSet();
            final loaded = <String, int>{};
            for (final layer in activeLayers
                .where((layer) => wagonTruckIds.contains(layer.truckId))) {
              final allocations =
                  jsonDecode(layer.itemAllocationsJson) as List<dynamic>;
              var allocated = 0;
              for (final item in allocations) {
                final value = item as Map<String, dynamic>;
                final name = value['itemName'] as String;
                final quantity = value['quantity'] as int;
                allocated += quantity;
                loaded[name] = (loaded[name] ?? 0) + quantity;
              }
              if (allocations.isNotEmpty && allocated != layer.cartonCount) {
                throw StateError('Demo layer item totals failed validation.');
              }
            }
            for (final entry in loaded.entries) {
              if (!manifest.containsKey(entry.key) ||
                  entry.value > manifest[entry.key]!) {
                throw StateError('Demo wagon inventory failed validation.');
              }
            }
          }

          wagonNotifier.refresh();
          truckNotifier.refresh();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          'Enterprise demo data loaded. Accounts and settings preserved.')),
                ],
              ),
            ));
          }
        },
      ),
    );
  }

  Future<void> _confirmLocalDataArchive(
      BuildContext context, WidgetRef ref) async {
    final database = ref.read(databaseProvider);
    final shareService = ref.read(shareServiceProvider);
    final password = await _requestBackupPassword(
      context,
      title: 'Protect Backup',
      message: 'Choose a password. It cannot be recovered, so store it safely.',
      confirmation: true,
    );
    if (password == null || !context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => ActionWarningDialog(
        title: 'Share Protected Backup?',
        content:
            'This creates one AES-256 encrypted ZIP containing all local operational data: the database, audit records, saved images, backups, and locally generated exports. Login tokens and password hashes are excluded. The receiving device will need the password to restore it.',
        actionLabel: 'Create & Share Protected ZIP',
        actionColor: AppTheme.primaryColor,
        icon: Icons.inventory_2_outlined,
        onConfirm: () async {
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => const PopScope(
              canPop: false,
              child: AlertDialog(
                content: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        'Preparing archive in the background…\n'
                        'Your phone will stay responsive.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          try {
            final archive =
                await LocalDataArchiveService(database).createArchive(
              password: password,
            );
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop();
            await shareService.shareFile(
              archive,
              subject: 'SmartLoad Password-Protected Local Backup',
              text:
                  'Password-protected SmartLoad local backup. Share the password only through a separate approved channel.',
            );
          } catch (error) {
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Could not create audit archive: $error'),
              backgroundColor: AppTheme.errorColor,
            ));
          }
        },
      ),
    );
  }

  Future<void> _selectAuditArchive(
    BuildContext context, {
    required String choice,
  }) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    // The drawer is deliberately closed while import runs. Keep the app-level
    // provider container instead of using this drawer widget's Ref afterward.
    final providerContainer = ProviderScope.containerOf(
      rootContext,
      listen: false,
    );
    File? zipFile;
    showDialog<void>(
      context: rootContext,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Preparing selected archive…')),
            ],
          ),
        ),
      ),
    );
    // Give Flutter one frame to register the progress route before Android's
    // external picker covers the app.
    await Future<void>.delayed(const Duration(milliseconds: 80));
    try {
      final path = await const MethodChannel('com.vinayak.smartload/import')
          .invokeMethod<String>('pickZip');
      if (path == null || path.isEmpty) return;
      zipFile = File(path);
    } on PlatformException catch (error) {
      if (rootContext.mounted) {
        ScaffoldMessenger.of(rootContext).showSnackBar(SnackBar(
          content:
              Text('Could not select archive: ${error.message ?? error.code}'),
          backgroundColor: AppTheme.errorColor,
        ));
      }
      return;
    } finally {
      if (rootContext.mounted) {
        Navigator.of(rootContext, rootNavigator: true).pop();
      }
    }
    if (!rootContext.mounted) return;

    var confirmed = false;
    await showDialog<void>(
      context: rootContext,
      useRootNavigator: true,
      builder: (_) => ActionWarningDialog(
        title: 'Import Audit Archive?',
        content:
            'This will replace operational records (wagons, trucks, layers, reports, and audit history) with the selected archive. Your account, login, secure credentials and app settings will stay on this phone. A backup of the current database will be created first.',
        actionLabel: 'Import and Replace',
        actionColor: AppTheme.primaryColor,
        icon: Icons.file_download_outlined,
        onConfirm: () async {
          confirmed = true;
          return null;
        },
      ),
    );
    if (!confirmed || !rootContext.mounted) {
      await _deletePickerCopy(zipFile, null);
      return;
    }

    final password = await _requestBackupPassword(
      rootContext,
      title: 'Backup Password',
      message:
          'Enter the password for a protected backup. Leave it blank only for an older unprotected SmartLoad ZIP.',
      allowEmpty: true,
    );
    if (password == null || !rootContext.mounted) {
      await _deletePickerCopy(zipFile, null);
      return;
    }

    // Close the drawer before displaying progress on the root navigator. This
    // avoids popping the progress route accidentally and leaving a black UI.
    if (context.mounted) Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!rootContext.mounted) {
      await _deletePickerCopy(zipFile, null);
      return;
    }
    showDialog<void>(
      context: rootContext,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Importing archive safely…')),
            ],
          ),
        ),
      ),
    );

    final database = providerContainer.read(databaseProvider);
    try {
      final service = LocalDataArchiveService(database);
      final summary = await service.importArchive(zipFile, password: password);
      providerContainer.invalidate(wagonListProvider);
      providerContainer.invalidate(truckListProvider);
      providerContainer.invalidate(layerListProvider);

      AppLogger.info(
          'ADMIN IMPORT: Imported ${summary.copiedFiles} files from archive.');

      if (!rootContext.mounted) return;
      Navigator.of(rootContext, rootNavigator: true).pop();
      ScaffoldMessenger.of(rootContext).showSnackBar(SnackBar(
        content: Text(
            'Imported operational data and ${summary.copiedFiles} local files successfully.'),
      ));
    } catch (error, stackTrace) {
      AppLogger.error('ADMIN IMPORT FAILED', error, stackTrace);
      if (!rootContext.mounted) return;
      Navigator.of(rootContext, rootNavigator: true).pop();
      ScaffoldMessenger.of(rootContext).showSnackBar(SnackBar(
        content: Text('Could not import archive: $error'),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 12),
      ));
    } finally {
      await _deletePickerCopy(zipFile, null);
    }
  }

  Future<String?> _requestBackupPassword(
    BuildContext context, {
    required String title,
    required String message,
    bool confirmation = false,
    bool allowEmpty = false,
  }) async {
    final passwordController = TextEditingController();
    final confirmationController = TextEditingController();
    var obscure = true;
    var errorMessage = '';
    try {
      return await showDialog<String>(
        context: context,
        useRootNavigator: true,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: obscure,
                    autocorrect: false,
                    enableSuggestions: false,
                    autofillHints: confirmation
                        ? const [AutofillHints.newPassword]
                        : const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: 'Backup password',
                      suffixIcon: IconButton(
                        tooltip: obscure ? 'Show password' : 'Hide password',
                        onPressed: () => setState(() => obscure = !obscure),
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  if (confirmation) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmationController,
                      obscureText: obscure,
                      autocorrect: false,
                      enableSuggestions: false,
                      decoration: const InputDecoration(
                        labelText: 'Confirm backup password',
                      ),
                    ),
                  ],
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(errorMessage,
                        style: const TextStyle(color: AppTheme.errorColor)),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final password = passwordController.text;
                  if (password.isEmpty && !allowEmpty) {
                    setState(() {
                      errorMessage = 'Enter a backup password.';
                    });
                    return;
                  }
                  if (confirmation && password != confirmationController.text) {
                    setState(() {
                      errorMessage = 'The two passwords do not match.';
                    });
                    return;
                  }
                  Navigator.of(dialogContext).pop(password);
                },
                child: Text(confirmation ? 'Protect Backup' : 'Continue'),
              ),
            ],
          ),
        ),
      );
    } finally {
      passwordController.clear();
      confirmationController.clear();
      passwordController.dispose();
      confirmationController.dispose();
    }
  }

  Future<void> _restorePreviousLocalData(BuildContext context) async {
    final rootContext = Navigator.of(context, rootNavigator: true).context;
    final providerContainer =
        ProviderScope.containerOf(rootContext, listen: false);
    final database = providerContainer.read(databaseProvider);
    final service = LocalDataArchiveService(database);

    late List<LocalDatabaseBackup> backups;
    try {
      backups = await service.listLocalBackups();
    } catch (error) {
      if (!rootContext.mounted) return;
      ScaffoldMessenger.of(rootContext).showSnackBar(SnackBar(
        content: Text('Could not read local backups: $error'),
        backgroundColor: AppTheme.errorColor,
      ));
      return;
    }
    if (!rootContext.mounted) return;
    if (backups.isEmpty) {
      ScaffoldMessenger.of(rootContext).showSnackBar(const SnackBar(
        content: Text(
            'No previous local backup exists yet. One is created automatically before every import.'),
      ));
      return;
    }

    final selected = await showDialog<LocalDatabaseBackup>(
      context: rootContext,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Restore Previous Local Data'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: backups.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final backup = backups[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.storage_rounded),
                title: Text(_formatBackupDate(backup.createdAt)),
                subtitle: Text(_formatBackupSize(backup.sizeBytes)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(dialogContext, backup),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selected == null || !rootContext.mounted) return;

    var confirmed = false;
    await showDialog<void>(
      context: rootContext,
      useRootNavigator: true,
      builder: (_) => ActionWarningDialog(
        title: 'Restore This Backup?',
        content:
            'This replaces current operational records with the selected local snapshot. Your login and settings stay unchanged. Another safety backup will be created first, so this action can also be reversed.',
        actionLabel: 'Restore Backup',
        actionColor: AppTheme.primaryColor,
        icon: Icons.restore_rounded,
        onConfirm: () async {
          confirmed = true;
          return null;
        },
      ),
    );
    if (!confirmed || !rootContext.mounted) return;

    if (context.mounted) Navigator.of(context).pop();
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (!rootContext.mounted) return;
    showDialog<void>(
      context: rootContext,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(child: Text('Restoring local backup safely…')),
            ],
          ),
        ),
      ),
    );

    try {
      await service.restoreLocalBackup(selected);
      providerContainer.invalidate(wagonListProvider);
      providerContainer.invalidate(truckListProvider);
      providerContainer.invalidate(layerListProvider);
      if (!rootContext.mounted) return;
      Navigator.of(rootContext, rootNavigator: true).pop();
      ScaffoldMessenger.of(rootContext).showSnackBar(const SnackBar(
        content: Text('Previous local data restored successfully.'),
      ));
    } catch (error, stackTrace) {
      debugPrint('Local backup restore failed: $error\n$stackTrace');
      if (!rootContext.mounted) return;
      Navigator.of(rootContext, rootNavigator: true).pop();
      ScaffoldMessenger.of(rootContext).showSnackBar(SnackBar(
        content: Text('Could not restore backup: $error'),
        backgroundColor: AppTheme.errorColor,
        duration: const Duration(seconds: 12),
      ));
    }
  }

  String _formatBackupDate(DateTime value) {
    final local = value.toLocal();
    String two(int number) => number.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year}  '
        '${two(local.hour)}:${two(local.minute)}';
  }

  String _formatBackupSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }

  Future<void> _deletePickerCopy(File? zip, Directory? folder) async {
    try {
      if (zip != null && await zip.exists()) await zip.delete();
      if (folder != null && await folder.exists()) {
        await folder.delete(recursive: true);
      }
    } catch (_) {
      // Import already completed (or produced its own useful error). Cleanup
      // failure must not replace that result with another user-facing error.
    }
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => ActionWarningDialog(
        title: 'Log out of SmartLoad?',
        content:
            'You will return to the login screen. Your wagons, trucks, layers, reports, and saved local data will stay on this device. Choose Cancel to remain signed in.',
        actionLabel: 'Log out',
        actionColor: Colors.redAccent,
        icon: Icons.logout_rounded,
        onConfirm: () async {
          await ref.read(authProvider.notifier).logout();
          if (context.mounted) {
            Navigator.pop(context); // close the navigation drawer
            context.go('/login');
          }
          return null;
        },
      ),
    );
  }
}
