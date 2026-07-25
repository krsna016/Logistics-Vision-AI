import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/widgets/search_field.dart';
import '../../../../presentation/widgets/empty_state_widget.dart';
import '../providers/register_providers.dart';
import '../../../wagon/domain/entities/wagon.dart';
import '../widgets/register_card.dart';

class RegisterListScreen extends ConsumerWidget {
  const RegisterListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerListProvider);
    final notifier = ref.read(registerListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 52,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 10, bottom: 10),
          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vinayak SmartLoad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Digital Wagon Registers', style: TextStyle(fontSize: 10, color: Color(0xFFBDBDBD), fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.refresh(),
            tooltip: 'Refresh Registers',
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
                  // Section Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 20.0, bottom: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Digital Registers',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Official operational loading logs & manifest archives',
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Search and Filters
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SearchField(
                            initialValue: state.searchQuery,
                            onChanged: (val) => notifier.updateSearchQuery(val),
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                // Date Filters
                                ChoiceChip(
                                  label: const Text('All Dates'),
                                  selected: state.dateFilter == RegisterDateFilter.all,
                                  onSelected: (_) => notifier.setDateFilter(RegisterDateFilter.all),
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  label: const Text('Today'),
                                  selected: state.dateFilter == RegisterDateFilter.today,
                                  onSelected: (_) => notifier.setDateFilter(RegisterDateFilter.today),
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  label: const Text('This Week'),
                                  selected: state.dateFilter == RegisterDateFilter.thisWeek,
                                  onSelected: (_) => notifier.setDateFilter(RegisterDateFilter.thisWeek),
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  label: const Text('This Month'),
                                  selected: state.dateFilter == RegisterDateFilter.thisMonth,
                                  onSelected: (_) => notifier.setDateFilter(RegisterDateFilter.thisMonth),
                                ),
                                const SizedBox(width: 12),
                                Container(width: 1, height: 20, color: Colors.grey.shade700),
                                const SizedBox(width: 12),
                                // Status Filters
                                FilterChip(
                                  label: const Text('Completed'),
                                  selected: state.statusFilter == WagonStatus.completed,
                                  onSelected: (val) => notifier.setStatusFilter(val ? WagonStatus.completed : null),
                                ),
                                const SizedBox(width: 6),
                                FilterChip(
                                  label: const Text('Archived'),
                                  selected: state.statusFilter == WagonStatus.archived,
                                  onSelected: (val) => notifier.setStatusFilter(val ? WagonStatus.archived : null),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Registers List / Empty State
                  if (state.processedRegisters.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: EmptyStateWidget(
                          title: 'No Registers Yet',
                          subtitle: 'Complete a wagon loading session to generate your first digital register.',
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final reg = state.processedRegisters[index];
                            return RegisterCard(
                              register: reg,
                              onTap: () {
                                notifier.recordOpen(reg.id);
                                context.push('/registers/${reg.id}');
                              },
                            );
                          },
                          childCount: state.processedRegisters.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
            ),
    );
  }
}
