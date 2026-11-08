import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../incidents/presentation/providers/incident_providers.dart';
import '../../../incidents/presentation/widgets/incident_card.dart';

class StaffAllReportsScreen extends ConsumerStatefulWidget {
  const StaffAllReportsScreen({super.key});

  @override
  ConsumerState<StaffAllReportsScreen> createState() => _StaffAllReportsScreenState();
}

class _StaffAllReportsScreenState extends ConsumerState<StaffAllReportsScreen> {
  IncidentStatus? _filterStatus;
  IncidentCategory? _filterCategory;
  IncidentPriority? _filterPriority;
  String _searchQuery = '';
  bool _sortNewest = true;

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filter & Sort',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Sort
                    Text(
                      'Sort By',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: true, label: Text('Newest')),
                        ButtonSegment(value: false, label: Text('Oldest')),
                      ],
                      selected: {_sortNewest},
                      onSelectionChanged: (Set<bool> selected) {
                        setModalState(() {
                          _sortNewest = selected.first;
                        });
                        setState(() {
                          _sortNewest = selected.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Filter
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _filterCategory == null,
                          onSelected: (selected) {
                            setModalState(() {
                              _filterCategory = null;
                            });
                            setState(() {
                              _filterCategory = null;
                            });
                          },
                        ),
                        ...IncidentCategory.values.map((category) {
                          return FilterChip(
                            label: Text('${category.emoji} ${category.displayName}'),
                            selected: _filterCategory == category,
                            onSelected: (selected) {
                              setModalState(() {
                                _filterCategory = selected ? category : null;
                              });
                              setState(() {
                                _filterCategory = selected ? category : null;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Priority Filter
                    Text(
                      'Priority',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: _filterPriority == null,
                          onSelected: (selected) {
                            setModalState(() {
                              _filterPriority = null;
                            });
                            setState(() {
                              _filterPriority = null;
                            });
                          },
                        ),
                        ...IncidentPriority.values.map((priority) {
                          return FilterChip(
                            label: Text(priority.displayName),
                            selected: _filterPriority == priority,
                            onSelected: (selected) {
                              setModalState(() {
                                _filterPriority = selected ? priority : null;
                              });
                              setState(() {
                                _filterPriority = selected ? priority : null;
                              });
                            },
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidentsAsync = ref.watch(allIncidentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search reports...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Status Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterStatus == null,
                  onSelected: (selected) {
                    setState(() {
                      _filterStatus = null;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ...IncidentStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(status.displayName),
                      selected: _filterStatus == status,
                      onSelected: (selected) {
                        setState(() {
                          _filterStatus = selected ? status : null;
                        });
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reports List
          Expanded(
            child: incidentsAsync.when(
              data: (incidents) {
                var filteredIncidents = incidents;

                // Apply filters
                if (_filterStatus != null) {
                  filteredIncidents = filteredIncidents
                      .where((i) => i.status == _filterStatus)
                      .toList();
                }

                if (_filterCategory != null) {
                  filteredIncidents = filteredIncidents
                      .where((i) => i.category == _filterCategory)
                      .toList();
                }

                if (_filterPriority != null) {
                  filteredIncidents = filteredIncidents
                      .where((i) => i.priority == _filterPriority)
                      .toList();
                }

                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  filteredIncidents = filteredIncidents.where((i) {
                    return i.title.toLowerCase().contains(query) ||
                        i.description.toLowerCase().contains(query) ||
                        i.location.toLowerCase().contains(query) ||
                        i.reporterName.toLowerCase().contains(query);
                  }).toList();
                }

                // Sort
                filteredIncidents.sort((a, b) {
                  return _sortNewest
                      ? b.createdAt.compareTo(a.createdAt)
                      : a.createdAt.compareTo(b.createdAt);
                });

                if (filteredIncidents.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: 'No reports found',
                    message: _searchQuery.isNotEmpty
                        ? 'No reports match your search'
                        : 'No reports match your filters',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allIncidentsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredIncidents.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: IncidentCard(incident: filteredIncidents[index]),
                      );
                    },
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16.0),
                child: ShimmerListLoader(itemCount: 5),
              ),
              error: (error, _) => ErrorState(
                message: 'Failed to load reports',
                onRetry: () => ref.invalidate(allIncidentsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
