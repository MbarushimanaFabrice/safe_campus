import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../../core/widgets/avatar_with_fallback.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/incident_providers.dart';
import '../widgets/incident_card.dart';
import '../widgets/stat_card.dart';

class MyReportsScreen extends ConsumerStatefulWidget {
  const MyReportsScreen({super.key});

  @override
  ConsumerState<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends ConsumerState<MyReportsScreen> {
  IncidentStatus? _filterStatus;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final incidentsAsync = ref.watch(userIncidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SafeArea(
        child: userDataAsync.when(
          data: (userData) {
            if (userData == null) {
              return const Center(child: Text('User data not found'));
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            AvatarWithFallback(
                              imageUrl: userData.photoUrl,
                              name: userData.fullName,
                              size: 60,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userData.fullName,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Student',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.school,
                                        size: 14,
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        userData.department,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Kigali, Rwanda',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats
                    incidentsAsync.when(
                      data: (incidents) {
                        final totalCount = incidents.length;
                        final inProgressCount = incidents
                            .where((i) => i.status == IncidentStatus.inProgress)
                            .length;
                        final resolvedCount = incidents
                            .where((i) => i.status == IncidentStatus.resolved)
                            .length;

                        return Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.description,
                                title: 'Total',
                                count: totalCount,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
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
                        );
                      },
                      loading: () => const ShimmerLoader(width: double.infinity, height: 100),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All', null),
                          const SizedBox(width: 8),
                          _buildFilterChip('Submitted', IncidentStatus.submitted),
                          const SizedBox(width: 8),
                          _buildFilterChip('In Progress', IncidentStatus.inProgress),
                          const SizedBox(width: 8),
                          _buildFilterChip('Resolved', IncidentStatus.resolved),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Reports List
                    incidentsAsync.when(
                      data: (incidents) {
                        var filteredIncidents = incidents;

                        if (_filterStatus != null) {
                          filteredIncidents = filteredIncidents
                              .where((i) => i.status == _filterStatus)
                              .toList();
                        }

                        if (filteredIncidents.isEmpty) {
                          return EmptyState(
                            icon: Icons.article_outlined,
                            title: 'No reports found',
                            message: _filterStatus != null
                                ? 'No reports with ${_filterStatus!.displayName} status'
                                : 'You haven\'t submitted any reports yet',
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredIncidents.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: IncidentCard(incident: filteredIncidents[index]),
                            );
                          },
                        );
                      },
                      loading: () => const ShimmerListLoader(itemCount: 5),
                      error: (error, _) => ErrorState(
                        message: 'Failed to load reports',
                        onRetry: () => ref.invalidate(userIncidentsProvider),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const ErrorState(message: 'Failed to load user data'),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IncidentStatus? status) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? status : null;
        });
      },
      backgroundColor: Theme.of(context).cardColor,
      selectedColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }
}
