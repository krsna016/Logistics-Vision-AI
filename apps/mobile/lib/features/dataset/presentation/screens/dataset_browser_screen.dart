import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/dataset_providers.dart';


class DatasetBrowserScreen extends ConsumerWidget {
  const DatasetBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(datasetListProvider);
    final notifier = ref.read(datasetListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/wagons'),
          tooltip: 'Return to Cargo Hub',
        ),
        title: const Text('Dataset Browser'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () => context.go('/dataset/collect'),
            tooltip: 'Launch Dataset Collector',
          ),
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () async {
              await notifier.triggerZipExport();
              if (context.mounted && ref.read(datasetListProvider).exportZipPath != null) {
                final path = ref.read(datasetListProvider).exportZipPath!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ZIP Export generated at: $path'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            tooltip: 'Export selected items to ZIP',
          ),

        ],
      ),

      body: Column(
        children: [
          // Filter panels
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Filter Warehouse',
                      prefixIcon: const Icon(Icons.business, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (val) => notifier.setFilters(warehouse: val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Filter Truck ID',
                      prefixIcon: const Icon(Icons.local_shipping, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onChanged: (val) => notifier.setFilters(truck: val),
                  ),
                ),
              ],
            ),
          ),

          if (state.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),

          if (!state.isLoading && state.filteredItems.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No dataset items match active filters.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),

          if (!state.isLoading && state.filteredItems.isNotEmpty)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: state.filteredItems.length,
                itemBuilder: (context, index) {
                  final item = state.filteredItems[index];
                  final scorePct = (item.qualityScore * 100).toStringAsFixed(0);

                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : Colors.grey.shade200,
                            width: double.infinity,
                            child: const Icon(Icons.image, size: 40, color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Quality: $scorePct%',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  GestureDetector(
                                    onTap: () => notifier.deleteItem(item.id),
                                    child: const Icon(Icons.delete, size: 16, color: Colors.redAccent),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Model: ${item.phoneModel}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Notes: ${item.notes ?? "No details"}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
