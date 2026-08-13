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

class WagonListScreen extends ConsumerStatefulWidget {
  const WagonListScreen({super.key});

  @override
  ConsumerState<WagonListScreen> createState() => _WagonListScreenState();
}

class _WagonListScreenState extends ConsumerState<WagonListScreen> {
  String? _selectedWagonId;
  bool _selectorExpanded = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wagonListProvider);
    final stats = ref.watch(wagonStatsProvider);
    final notifier = ref.read(wagonListProvider.notifier);
    final truckState = ref.watch(truckListProvider);

    // Keep the selector stable while the operator works. If a wagon is
    // created/deleted, gracefully move selection to the first available one.
    // The quick selector must show every active wagon, independent of the
    // search/status filters used by the report list above.
    final activeWagons = state.wagons
        .where((wagon) =>
            wagon.status != WagonStatus.archived &&
            wagon.status != WagonStatus.completed &&
            truckState.trucks.any((truck) =>
                truck.wagonId == wagon.id &&
                !truck.isDeleted &&
                !truck.isArchived &&
                truck.status != TruckStatus.completed))
        .toList();
    final selectedWagon = activeWagons.cast<Wagon?>().firstWhere(
          (wagon) => wagon?.id == _selectedWagonId,
          orElse: () => activeWagons.isEmpty ? null : activeWagons.first,
        );
    if (selectedWagon != null && _selectedWagonId != selectedWagon.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedWagonId = selectedWagon.id);
      });
    }

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
        bottomNavigationBar: activeWagons.isEmpty || selectedWagon == null
            ? null
            : _LoadingSelectorBar(
                wagons: activeWagons,
                trucks: truckState.trucks,
                selectedWagon: selectedWagon,
                expanded: _selectorExpanded,
                onToggle: () =>
                    setState(() => _selectorExpanded = !_selectorExpanded),
                onWagonSelected: (wagon) =>
                    setState(() => _selectedWagonId = wagon.id),
                onTruckSelected: (truck) async {
                  await context.push('/trucks/${truck.id}/camera');
                  if (mounted) {
                    await ref.read(truckListProvider.notifier).refresh();
                    await ref.read(wagonListProvider.notifier).refresh();
                  }
                },
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

/// Persistent, fast-switching selector used while loading is in progress.
/// Wagons stay in the lower bar; selecting one immediately refreshes the truck
/// bar above it. This avoids returning through multiple detail screens.
class _LoadingSelectorBar extends StatelessWidget {
  final List<Wagon> wagons;
  final List<Truck> trucks;
  final Wagon selectedWagon;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<Wagon> onWagonSelected;
  final ValueChanged<Truck> onTruckSelected;

  const _LoadingSelectorBar({
    required this.wagons,
    required this.trucks,
    required this.selectedWagon,
    required this.expanded,
    required this.onToggle,
    required this.onWagonSelected,
    required this.onTruckSelected,
  });

  @override
  Widget build(BuildContext context) {
    final wagonTrucks = trucks
        .where((truck) =>
            truck.wagonId == selectedWagon.id &&
            !truck.isDeleted &&
            truck.status != TruckStatus.completed)
        .toList()
      ..sort((a, b) => a.createdDate.compareTo(b.createdDate));
    final colors = Theme.of(context).colorScheme;

    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Padding(
        // viewPadding includes the permanent three-button navigation area.
        // Using it explicitly keeps this persistent selector above the bar on
        // edge-to-edge Android devices, while remaining zero on gesture-only
        // devices.
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom + 8,
        ),
        child: GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.deferToChild,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
                bottom: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B2B42), Color(0xFF142238)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 7),
                GestureDetector(
                  onTap: onToggle,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
                    child: Container(
                      width: 34,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0x668DB7EA),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: expanded
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TRUCKS IN WAGON: ${selectedWagon.wagonNumber}',
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () {},
                                behavior: HitTestBehavior.opaque,
                                child: SizedBox(
                                  height: 64,
                                  child: wagonTrucks.isEmpty
                                      ? const Center(
                                          child: Text(
                                              'No trucks created for this wagon'))
                                      : ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          clipBehavior: Clip.none,
                                          itemCount: wagonTrucks.length,
                                          separatorBuilder: (_, __) =>
                                              const SizedBox(width: 8),
                                          itemBuilder: (context, index) {
                                            final truck = wagonTrucks[index];
                                            return _TruckSelectorChip(
                                              truck: truck,
                                              onTap: () =>
                                                  onTruckSelected(truck),
                                            );
                                          },
                                        ),
                                ),
                              ),
                              if (wagons.length > 1) ...[
                                const SizedBox(height: 10),
                                const Text(
                                  'WAGONS',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () {},
                                  behavior: HitTestBehavior.opaque,
                                  child: SizedBox(
                                    height: 42,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: wagons.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (context, index) {
                                        final wagon = wagons[index];
                                        final selected =
                                            wagon.id == selectedWagon.id;
                                        return ChoiceChip(
                                          selected: selected,
                                          label: Text(wagon.wagonNumber),
                                          avatar: Icon(Icons.train_outlined,
                                              size: 17,
                                              color: selected
                                                  ? colors.onPrimary
                                                  : colors.primary),
                                          showCheckmark: false,
                                          side: BorderSide.none,
                                          color:
                                              WidgetStateProperty.resolveWith(
                                                  (states) {
                                            // ChoiceChip's default pressed overlay uses
                                            // the theme secondary (yellow) color. Keep
                                            // every interaction state on the same soft
                                            // wagon surface or selected blue surface.
                                            return states.contains(
                                                    WidgetState.selected)
                                                ? colors.primary
                                                : const Color(0xFF24344D);
                                          }),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          backgroundColor:
                                              const Color(0xFF24344D),
                                          selectedColor: colors.primary,
                                          labelStyle: TextStyle(
                                            color: selected
                                                ? colors.onPrimary
                                                : colors.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 6),
                                          onSelected: (_) =>
                                              onWagonSelected(wagon),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TruckSelectorChip extends StatelessWidget {
  final Truck truck;
  final VoidCallback onTap;

  const _TruckSelectorChip({required this.truck, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final completed = truck.status == TruckStatus.completed;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 116),
            padding: const EdgeInsets.fromLTRB(12, 7, 22, 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF2B3B55),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .16),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 22, color: colors.primaryFixed),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      truck.vehicleNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      completed ? 'Completed' : '${truck.totalLayers} layers',
                      style: TextStyle(
                        fontSize: 11,
                        color: completed
                            ? const Color(0xFF66E18A)
                            : const Color(0xFFD3DCEB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: -7,
            bottom: -8,
            child: IgnorePointer(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4D9BFF), Color(0xFF0965D8)],
                  ),
                  border: Border.all(
                    color: const Color(0xFF162A46),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x55000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
