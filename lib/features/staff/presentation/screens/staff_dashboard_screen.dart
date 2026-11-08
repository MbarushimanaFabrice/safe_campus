import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../../core/widgets/avatar_with_fallback.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../incidents/presentation/providers/incident_providers.dart';
import '../../../incidents/presentation/widgets/stat_card.dart';
import '../../../incidents/presentation/widgets/incident_card.dart';

class StaffDashboardScreen extends ConsumerWidget {
  const StaffDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final incidentsAsync = ref.watch(allIncidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allIncidentsProvider);
        },
        child: userDataAsync.when(
          data: (userData) {
            if (userData == null) {
              return const Center(child: Text('User data not found'));
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${userData.firstName} 👋',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage and track campus incidents',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      AvatarWithFallback(
                        imageUrl: userData.photoUrl,
                        name: userData.fullName,
                        size: 40,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Overview
                  incidentsAsync.when(
                    data: (incidents) {
                      final totalCount = incidents.length;
                      final submittedCount = incidents
                          .where((i) => i.status == IncidentStatus.submitted)
                          .length;
                      final inProgressCount = incidents
                          .where((i) => i.status == IncidentStatus.inProgress)
                          .length;
                      final resolvedCount = incidents
                          .where((i) => i.status == IncidentStatus.resolved)
                          .length;

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.article,
                                  title: 'Total Reports',
                                  count: totalCount,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.pending,
                                  title: 'Submitted',
                                  count: submittedCount,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.schedule,
                                  title: 'In Progress',
                                  count: inProgressCount,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.check_circle,
                                  title: 'Resolved',
                                  count: resolvedCount,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => Column(
                      children: [
                        Row(
                          children: const [
                            Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
                            SizedBox(width: 12),
                            Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const [
                            Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
                            SizedBox(width: 12),
                            Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
                          ],
                        ),
                      ],
                    ),
                    error: (error, _) => ErrorState(
                      message: 'Failed to load statistics',
                      onRetry: () => ref.invalidate(allIncidentsProvider),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reports by Category Chart
                  incidentsAsync.when(
                    data: (incidents) {
                      if (incidents.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reports by Category',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: incidents.length.toDouble(),
                                    barTouchData: BarTouchData(enabled: false),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (value, meta) {
                                            final categories = IncidentCategory.values;
                                            if (value.toInt() >= 0 && value.toInt() < categories.length) {
                                              return Text(
                                                categories[value.toInt()].emoji,
                                                style: const TextStyle(fontSize: 16),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 30,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toInt().toString(),
                                              style: Theme.of(context).textTheme.bodySmall,
                                            );
                                          },
                                        ),
                                      ),
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: FlGridData(show: true, drawVerticalLine: false),
                                    borderData: FlBorderData(show: false),
                                    barGroups: IncidentCategory.values.asMap().entries.map((entry) {
                                      final count = incidents
                                          .where((i) => i.category == entry.value)
                                          .length;
                                      return BarChartGroupData(
                                        x: entry.key,
                                        barRods: [
                                          BarChartRodData(
                                            toY: count.toDouble(),
                                            color: Theme.of(context).colorScheme.primary,
                                            width: 20,
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const ShimmerLoader(width: double.infinity, height: 250),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // Urgent Reports
                  incidentsAsync.when(
                    data: (incidents) {
                      final urgentReports = incidents
                          .where((i) =>
                              i.priority == IncidentPriority.high &&
                              i.status != IncidentStatus.resolved)
                          .take(3)
                          .toList();

                      if (urgentReports.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Urgent Reports',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '${urgentReports.length}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...urgentReports.map((incident) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: IncidentCard(incident: incident),
                            );
                          }),
                        ],
                      );
                    },
                    loading: () => const ShimmerListLoader(itemCount: 2),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),

                  // Newest Unresolved
                  incidentsAsync.when(
                    data: (incidents) {
                      final unresolvedReports = incidents
                          .where((i) => i.status != IncidentStatus.resolved)
                          .take(5)
                          .toList();

                      if (unresolvedReports.isEmpty) {
                        return const EmptyState(
                          icon: Icons.check_circle_outline,
                          title: 'All Caught Up!',
                          message: 'No unresolved reports at the moment.',
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Newest Unresolved',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 12),
                          ...unresolvedReports.map((incident) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: IncidentCard(incident: incident),
                            );
                          }),
                        ],
                      );
                    },
                    loading: () => const ShimmerListLoader(itemCount: 3),
                    error: (error, _) => ErrorState(
                      message: 'Failed to load reports',
                      onRetry: () => ref.invalidate(allIncidentsProvider),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => ErrorState(
            message: 'Failed to load user data',
            onRetry: () => ref.invalidate(currentUserDataProvider),
          ),
        ),
      ),
    );
  }
}
