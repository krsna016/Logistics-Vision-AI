import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_theme.dart';
import '../../../../core/presentation/widgets/app_drawer.dart';
import '../../domain/entities/time_filter.dart';
import '../../domain/entities/performance_metrics.dart';
import '../providers/analytics_providers.dart';
import '../widgets/summary_grid.dart';
import '../widgets/trend_chart.dart';
import '../widgets/alert_banner.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../reports/presentation/providers/report_providers.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(timeFilterProvider);

    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final aiAsync = ref.watch(aiPerformanceProvider);
    final loadAsync = ref.watch(loadingPerformanceProvider);
    final healthAsync = ref.watch(datasetHealthProvider);
    final prodAsync = ref.watch(productivityProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/wagons');
            }
          },
        ),
        title: const Text('Analytics & Operations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Export PDF Report',
            onPressed: () => _exportReport(context, ref, 'PDF'),
          ),
          IconButton(
            icon: const Icon(Icons.table_chart, color: Colors.green),
            tooltip: 'Export Excel Report',
            onPressed: () => _exportReport(context, ref, 'Excel'),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(analyticsSummaryProvider);
          ref.invalidate(aiPerformanceProvider);
          ref.invalidate(loadingPerformanceProvider);
          ref.invalidate(datasetHealthProvider);
          ref.invalidate(productivityProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Time Filter Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TimeFilter.values.map((filter) {
                  final isSelected = selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter.displayName),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) ref.read(timeFilterProvider.notifier).state = filter;
                      },
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      backgroundColor: AppTheme.surfaceColor,
                      labelStyle: TextStyle(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryColor : Colors.white10,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Active Alerts
            healthAsync.when(
              data: (health) {
                if (health.storageUsedMB > 4500) {
                  return const AlertBanner(
                    title: 'Storage Capacity Warning',
                    message: 'Device storage is almost full. Please run a synchronization cycle.',
                    icon: Icons.storage,
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            aiAsync.when(
              data: (ai) {
                if (ai.averageConfidence < 0.75) {
                  return const AlertBanner(
                    title: 'Low AI Confidence',
                    message: 'The model confidence is dropping. A manual review is recommended.',
                    icon: Icons.warning_amber,
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const Text('OVERVIEW', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            // Summary Grid
            summaryAsync.when(
              data: (summary) => SummaryGrid(
                totalWagons: summary.totalWagons,
                totalTrucks: summary.totalTrucks,
                totalLayers: summary.totalLayers,
                totalCartons: summary.totalCartons,
                avgConfidence: summary.averageConfidence,
                avgLoadingTime: summary.averageLoadingTime,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
            
            const SizedBox(height: 32),
            const Text('LOADING TRENDS', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            loadAsync.when(
              data: (load) => TrendChart(
                title: 'Cartons Loaded Per Hour',
                yAxisTitle: 'Cartons',
                dataPoints: load.hourlyCartonTrend,
                lineColor: Colors.green,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),
            const Text('DATASET CAPTURE', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            healthAsync.when(
              data: (health) => TrendChart(
                title: 'Images Captured',
                yAxisTitle: 'Images',
                dataPoints: health.dailyCaptureTrend,
                lineColor: Colors.purple,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 32),
            const Text('PRODUCTIVITY', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            prodAsync.when(
              data: (prod) => _buildProductivityCard(prod),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 60), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildProductivityCard(ProductivityMetrics prod) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _ProdRow('Average Operator Score', '${(prod.averageOperatorPerformance * 100).toStringAsFixed(1)}%'),
          const Divider(color: Colors.white10, height: 24),
          _ProdRow('Truck Throughput', '${prod.truckThroughput.toStringAsFixed(1)} / day'),
          const Divider(color: Colors.white10, height: 24),
          _ProdRow('Layers Per Hour', prod.averageLayersPerHour.toStringAsFixed(1)),
          const Divider(color: Colors.white10, height: 24),
          _ProdRow('Cartons Per Hour', prod.averageCartonsPerHour.toStringAsFixed(1)),
        ],
      ),
    );
  }

  void _exportReport(BuildContext context, WidgetRef ref, String type) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generating $type report...')),
    );
    
    try {
      if (type == 'PDF') {
        final file = await ref.read(pdfReportServiceProvider).generateAnalyticsReport();
        await ref.read(shareServiceProvider).shareFile(file, subject: 'Analytics PDF Report');
      } else {
        final file = await ref.read(excelReportServiceProvider).generateAnalyticsReport();
        await ref.read(shareServiceProvider).shareFile(file, subject: 'Analytics Excel Report');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _ProdRow extends StatelessWidget {
  final String label;
  final String value;
  const _ProdRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
