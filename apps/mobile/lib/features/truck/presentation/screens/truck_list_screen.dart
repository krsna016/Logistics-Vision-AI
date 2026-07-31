import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/layout/responsive.dart';
import '../../domain/entities/truck.dart';
import '../providers/truck_providers.dart';
import '../widgets/truck_form_dialog.dart';
import '../../../../presentation/widgets/app_card.dart';
import '../../../../presentation/widgets/stats_card.dart';
import '../../../../presentation/widgets/status_chip.dart';
import '../../../../presentation/widgets/search_field.dart';
import '../../../../presentation/widgets/empty_state_widget.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';

class TruckListScreen extends ConsumerWidget {
  const TruckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listState = ref.watch(truckListProvider);
    final stats = ref.watch(truckStatsProvider);
    final notifier = ref.read(truckListProvider.notifier);

    final (loadingCount, completedCount, totalCartons) = stats;

    return Scaffold(
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
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: listState.isLoading && listState.trucks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              child: CustomScrollView(
                slivers: [
                  // Dashboard Greeting & Header Title
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
                            'Trucks',
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

                  // Section 1: Dashboard Statistics Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppResponsive.pagePadding(context),
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          StatsCard(
                            icon: Icons.local_shipping_outlined,
                            value: '$loadingCount',
                            title: 'Active Trucks',
                          ),
                          const SizedBox(width: 12),
                          StatsCard(
                            icon: Icons.check_circle_outline,
                            value: '$completedCount',
                            title: 'Completed',
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

                  // Section 2: Search & Filter Toolbar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppResponsive.pagePadding(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchField(
                            initialValue: listState.searchQuery,
                            onChanged: (val) => notifier.updateSearchQuery(val),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Sort selection Dropdown
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: listState.sortBy,
                                  icon: const Icon(Icons.arrow_drop_down,
                                      size: 20),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  onChanged: (val) {
                                    if (val != null)
                                      notifier.setSortOption(val);
                                  },
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'date',
                                        child: Text('Created Date')),
                                    DropdownMenuItem(
                                        value: 'number',
                                        child: Text('License Plate')),
                                    DropdownMenuItem(
                                        value: 'cartons',
                                        child: Text('Cartons Total')),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Filter Choice Chips
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  reverse: true,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ChoiceChip(
                                        label: const Text('All'),
                                        selected:
                                            listState.statusFilter == null,
                                        onSelected: (_) =>
                                            notifier.setStatusFilter(null),
                                      ),
                                      const SizedBox(width: 6),
                                      ChoiceChip(
                                        label: const Text('Active'),
                                        selected: listState.statusFilter ==
                                            TruckStatus.loading,
                                        onSelected: (_) =>
                                            notifier.setStatusFilter(
                                                TruckStatus.loading),
                                      ),
                                      const SizedBox(width: 6),
                                      ChoiceChip(
                                        label: const Text('Closed'),
                                        selected: listState.statusFilter ==
                                            TruckStatus.completed,
                                        onSelected: (_) =>
                                            notifier.setStatusFilter(
                                                TruckStatus.completed),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Section 3: Truck List / Empty States
                  if (listState.processedTrucks.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: EmptyStateWidget(
                          title: 'No Loading Activity',
                          subtitle:
                              'Register a truck or continue an active loading session.',
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
                            final truck = listState.processedTrucks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildTruckCard(context, truck),
                            );
                          },
                          childCount: listState.processedTrucks.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: 80)), // Space for FAB
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
            builder: (context) => const TruckFormDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Truck'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildTruckCard(BuildContext context, Truck truck) {
    final statusType = truck.status == TruckStatus.loading
        ? CustomStatusType.active
        : CustomStatusType.completed;

    return AppCard(
      elevation: 1,
      onTap: () => context.push('/trucks/${truck.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  truck.vehicleNumber,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(
                type: statusType,
                label: truck.status.displayName,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Driver: ${truck.driverName}${truck.driverMobile != null && truck.driverMobile!.isNotEmpty ? ' (${truck.driverMobile})' : ''}  •  Carrier: ${truck.company}',
            style: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(height: 1, color: Color(0xFF3A3A3A)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatLabel('Layers', '${truck.totalLayers}'),
              _buildStatLabel('Cartons', '${truck.totalCartons}'),
              _buildStatLabel(
                'Defects',
                '${truck.totalDefects}',
                isAlert: truck.totalDefects > 0,
              ),
              const Icon(Icons.chevron_right,
                  color: Color(0xFFBDBDBD), size: 20),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatLabel(String label, String val, {bool isAlert = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFBDBDBD),
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isAlert ? const Color(0xFFD32F2F) : Colors.white,
          ),
        ),
      ],
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
