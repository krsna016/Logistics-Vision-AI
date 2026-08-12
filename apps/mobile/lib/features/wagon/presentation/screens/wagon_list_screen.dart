import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/layout/responsive.dart';
import '../../../../presentation/widgets/stats_card.dart';
import '../../../../presentation/widgets/search_field.dart';
import '../../../../presentation/widgets/empty_state_widget.dart';
import '../../domain/entities/wagon.dart';
import '../providers/wagon_providers.dart';
import '../../../../core/presentation/widgets/root_back_guard.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
import '../../../session/presentation/providers/session_providers.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../widgets/wagon_card.dart';
import '../widgets/create_wagon_sheet.dart';

class WagonListScreen extends ConsumerWidget {
  const WagonListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wagonListProvider);
    final stats = ref.watch(wagonStatsProvider);
    final notifier = ref.read(wagonListProvider.notifier);
    final truckState = ref.watch(truckListProvider);

    ref.listen(activeSessionProvider, (previous, next) {
      if (previous?.isRecovering == true &&
          next.isRecovering == false &&
          next.activeSession != null) {
        // Find the vehicle number to show in the dialog if possible
        final truck = ref.read(truckListProvider).trucks.firstWhere(
              (t) => t.id == next.activeSession!.truckId,
              orElse: () => Truck(
                  id: '',
                  truckNumber: '',
                  vehicleNumber: 'Unknown Truck',
                  driverName: '',
                  company: '',
                  warehouse: '',
                  status: TruckStatus.loading,
                  createdDate: DateTime.now(),
                  updatedDate: DateTime.now()),
            );

        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Continue Loading?'),
            content: Text(
                'An unfinished loading session for truck ${truck.vehicleNumber} was found. Do you want to resume?'),
            actions: [
              TextButton(
                onPressed: () {
                  ref.read(activeSessionProvider.notifier).cancelSession();
                  Navigator.of(ctx).pop();
                },
                child:
                    const Text('Discard', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.push('/trucks/${next.activeSession!.truckId}');
                },
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      }
    });

    final (activeCount, completedCount, totalCartons, totalTrucks) = stats;

    return DoubleBackToExitGuard(
      child: Scaffold(
        drawerScrimColor: Colors.black.withValues(alpha: 0.86),
        endDrawer: const AppDrawer(),
        appBar: AppBar(
          leadingWidth: 52,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 10, bottom: 10),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Vinayak SmartLoad',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                'Powered by Vinayak Logistics',
                style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFBDBDBD),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
        body: state.isLoading && state.wagons.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await ref.read(truckListProvider.notifier).refresh();
                  await ref.read(wagonListProvider.notifier).refresh();
                },
                child: CustomScrollView(
                  slivers: [
                    // Operations Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: AppResponsive.pagePadding(context),
                          right: AppResponsive.pagePadding(context),
                          top: 20,
                          bottom: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Wagon Control Center',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getFormattedDate(),
                              style: const TextStyle(
                                  color: Color(0xFFBDBDBD), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section 1: Dashboard Stats Row
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.pagePadding(context),
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            StatsCard(
                              icon: Icons.train_outlined,
                              value: '$activeCount',
                              title: 'Active Wagons',
                            ),
                            const SizedBox(width: 12),
                            StatsCard(
                              icon: Icons.local_shipping_outlined,
                              value: '$totalTrucks',
                              title: 'Total Trucks',
                            ),
                            const SizedBox(width: 12),
                            StatsCard(
                              icon: Icons.inventory_2_outlined,
                              value: '$totalCartons',
                              title: 'Total Cartons',
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Section 2: Search and Filters
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.pagePadding(context),
                        ),
                        child: Column(
                          children: [
                            SearchField(
                              initialValue: state.searchQuery,
                              onChanged: (val) =>
                                  notifier.updateSearchQuery(val),
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ChoiceChip(
                                    label: const Text('All'),
                                    selected: state.statusFilter == null,
                                    onSelected: (_) =>
                                        notifier.setStatusFilter(null),
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    label: const Text('Planning'),
                                    selected: state.statusFilter ==
                                        WagonStatus.planning,
                                    onSelected: (_) => notifier
                                        .setStatusFilter(WagonStatus.planning),
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    label: const Text('Loading'),
                                    selected: state.statusFilter ==
                                        WagonStatus.loading,
                                    onSelected: (_) => notifier
                                        .setStatusFilter(WagonStatus.loading),
                                  ),
                                  const SizedBox(width: 6),
                                  ChoiceChip(
                                    label: const Text('Completed'),
                                    selected: state.statusFilter ==
                                        WagonStatus.completed,
                                    onSelected: (_) => notifier
                                        .setStatusFilter(WagonStatus.completed),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // Section 3: Wagon List
                    if (state.processedWagons.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: EmptyStateWidget(
                            title: 'No Wagon Activity',
                            subtitle:
                                'Create a new wagon to start cargo planning.',
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppResponsive.pagePadding(context),
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final wagon = state.processedWagons[index];

                              // Calculate computed metrics
                              final wagonTrucks = truckState.trucks.where(
                                  (t) => t.wagonId == wagon.id && !t.isDeleted);
                              final loadedCartons = wagonTrucks.fold(
                                  0, (sum, t) => sum + t.totalCartons);
                              final hasManifest = wagon.items.isNotEmpty;
                              final totalCartons = hasManifest
                                  ? wagon.items.fold<int>(
                                      0, (sum, item) => sum + item.quantity)
                                  : null;
                              final remainingCartons = totalCartons == null
                                  ? null
                                  : totalCartons - loadedCartons;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: WagonCard(
                                  wagon: wagon,
                                  totalCartons: totalCartons,
                                  loadedCartons: loadedCartons,
                                  remainingCartons: remainingCartons,
                                  truckCount: wagonTrucks.length,
                                  onTap: () =>
                                      context.push('/wagons/${wagon.id}'),
                                ),
                              );
                            },
                            childCount: state.processedWagons.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              isDismissible: false,
              enableDrag: false,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => const CreateWagonSheet(),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Create Wagon'),
          extendedPadding: const EdgeInsets.symmetric(horizontal: 20),
          extendedIconLabelSpacing: 8,
          materialTapTargetSize: MaterialTapTargetSize.padded,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
