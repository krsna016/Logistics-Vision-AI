import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/widgets/stats_card.dart';
import '../../../../presentation/widgets/search_field.dart';
import '../../../../presentation/widgets/empty_state_widget.dart';
import '../../domain/entities/wagon.dart';
import '../providers/wagon_providers.dart';
import '../../../truck/domain/entities/truck.dart';
import '../../../truck/presentation/providers/truck_providers.dart';
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

    final (activeCount, completedCount, totalCartons, totalTrucks) = stats;

    return Scaffold(
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
              style: TextStyle(fontSize: 10, color: Color(0xFFBDBDBD), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.description_outlined),
            onPressed: () => context.push('/registers'),
            tooltip: 'Digital Registers',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refresh list',
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: () => context.push('/dataset'),
            tooltip: 'Dataset Developer Mode',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              child: CustomScrollView(
                slivers: [
                  // Operations Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Wagon Control Center',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getFormattedDate(),
                            style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Section 1: Dashboard Stats Row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          StatsCard(
                            icon: '🚋',
                            value: '$activeCount',
                            title: 'Active Wagons',
                          ),
                          const SizedBox(width: 12),
                          StatsCard(
                            icon: '🚚',
                            value: '$totalTrucks',
                            title: 'Total Trucks',
                          ),
                          const SizedBox(width: 12),
                          StatsCard(
                            icon: '📦',
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
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          SearchField(
                            initialValue: state.searchQuery,
                            onChanged: (val) => notifier.updateSearchQuery(val),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ChoiceChip(
                                label: const Text('All'),
                                selected: state.statusFilter == null,
                                onSelected: (_) => notifier.setStatusFilter(null),
                              ),
                              const SizedBox(width: 6),
                              ChoiceChip(
                                label: const Text('Planning'),
                                selected: state.statusFilter == WagonStatus.planning,
                                onSelected: (_) => notifier.setStatusFilter(WagonStatus.planning),
                              ),
                              const SizedBox(width: 6),
                              ChoiceChip(
                                label: const Text('Loading'),
                                selected: state.statusFilter == WagonStatus.loading,
                                onSelected: (_) => notifier.setStatusFilter(WagonStatus.loading),
                              ),
                              const SizedBox(width: 6),
                              ChoiceChip(
                                label: const Text('Completed'),
                                selected: state.statusFilter == WagonStatus.completed,
                                onSelected: (_) => notifier.setStatusFilter(WagonStatus.completed),
                              ),
                            ],
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
                          subtitle: 'Create a new wagon to start cargo planning.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final wagon = state.processedWagons[index];
                            
                            // Calculate computed metrics
                            final wagonTrucks = truckState.trucks.where((t) => t.wagonId == wagon.id && !t.isDeleted);
                            final cartons = wagonTrucks.fold(0, (sum, t) => sum + t.totalCartons);
                            final defects = wagonTrucks.fold(0, (sum, t) => sum + t.totalDefects);
                            final completedCount = wagonTrucks.where((t) => t.status == TruckStatus.completed).length;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: WagonCard(
                                wagon: wagon,
                                totalCartons: cartons,
                                totalDefects: defects,
                                completedTrucks: completedCount,
                                totalTrucks: wagon.expectedTruckCount,
                                onTap: () => context.push('/wagons/${wagon.id}'),
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
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const CreateWagonSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Wagon'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }
}
