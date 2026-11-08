import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/cloudinary_service.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/priority_chip.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/incident_providers.dart';
import '../../data/models/incident_model.dart';

class IncidentDetailsScreen extends ConsumerStatefulWidget {
  final String incidentId;

  const IncidentDetailsScreen({super.key, required this.incidentId});

  @override
  ConsumerState<IncidentDetailsScreen> createState() => _IncidentDetailsScreenState();
}

class _IncidentDetailsScreenState extends ConsumerState<IncidentDetailsScreen> {
  IncidentStatus? _selectedStatus;
  final _noteController = TextEditingController();
  bool _isUpdating = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(IncidentModel incident) async {
    if (_selectedStatus == null) return;
    if (_selectedStatus == incident.status) return;

    final userData = ref.read(currentUserDataProvider).value;
    if (userData == null || userData.role != UserRole.staff) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only staff can update incident status'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUpdating = true);

    try {
      await ref.read(incidentRepositoryProvider).updateStatus(
            incidentId: incident.id,
            newStatus: _selectedStatus!,
            updatedBy: userData,
            note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _noteController.clear();
        setState(() => _selectedStatus = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _deleteIncident(IncidentModel incident) async {
    final userData = ref.read(currentUserDataProvider).value;
    if (userData == null) return;

    if (incident.reporterId != userData.uid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only delete your own reports'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (incident.status != IncidentStatus.submitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only delete reports that are still submitted'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await ref.read(incidentRepositoryProvider).deleteIncident(incident.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _viewImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageViewer(
          imageUrl: CloudinaryService().getDisplayUrl(imageUrl),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidentAsync = ref.watch(incidentByIdProvider(widget.incidentId));
    final userDataAsync = ref.watch(currentUserDataProvider);
    final cloudinaryService = CloudinaryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        actions: [
          incidentAsync.when(
            data: (incident) {
              final userData = userDataAsync.value;
              final isOwner = userData?.uid == incident.reporterId;
              final canEdit = isOwner && incident.status == IncidentStatus.submitted;

              if (!canEdit) return const SizedBox.shrink();

              return PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    _deleteIncident(incident);
                  }
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: incidentAsync.when(
        data: (incident) {
          final additionalPhotoUrls = incident.photoUrls.skip(1).toList();
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Card
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (incident.photoUrls.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: GestureDetector(
                              onTap: () => _viewImage(incident.photoUrls.first),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: cloudinaryService.getThumbnailUrl(incident.photoUrls.first),
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.broken_image_outlined, size: 40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Text(
                          incident.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                incident.fullLocation,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        StatusChip(status: incident.status),
                        const SizedBox(height: 12),
                        Text(
                          'Submitted on ${DateFormat('MMM dd, yyyy \'at\' hh:mm a').format(incident.createdAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reported by ${incident.reporterName}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),

                // Status Timeline
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status Timeline',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildTimeline(incident),
                    ],
                  ),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        incident.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                // Info Chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text('${incident.category.emoji} ${incident.category.displayName}'),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                      PriorityChip(priority: incident.priority),
                      Chip(
                        avatar: const Icon(Icons.location_on, size: 16),
                        label: Text(incident.location),
                      ),
                    ],
                  ),
                ),

                // Attached Photos
                if (additionalPhotoUrls.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Photos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...additionalPhotoUrls.map((url) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GestureDetector(
                              onTap: () => _viewImage(url),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: cloudinaryService.getDisplayUrl(
                                    url,
                                    width: 1200,
                                  ),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorWidget: (context, url, error) => Container(
                                    height: 180,
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: const Icon(Icons.broken_image_outlined, size: 40),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                // Staff Updates
                if (incident.statusHistory.length > 1) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staff Updates',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        ...incident.statusHistory.skip(1).map((entry) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      StatusChip(status: entry.status),
                                      const Spacer(),
                                      Text(
                                        DateFormat('MMM dd, hh:mm a').format(entry.timestamp),
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'By ${entry.updatedByName}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                  if (entry.note != null && entry.note!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      entry.note!,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],

                // Staff-Only Update Status Section
                userDataAsync.when(
                  data: (userData) {
                    if (userData?.role != UserRole.staff) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Update Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<IncidentStatus>(
                            value: _selectedStatus ?? incident.status,
                            decoration: const InputDecoration(
                              labelText: 'New Status',
                              prefixIcon: Icon(Icons.update),
                            ),
                            items: IncidentStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(status.displayName),
                              );
                            }).toList(),
                            onChanged: _isUpdating
                                ? null
                                : (value) {
                                    setState(() {
                                      _selectedStatus = value;
                                    });
                                  },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: 'Note (Optional)',
                              hintText: 'Add a note about this status change...',
                              prefixIcon: Icon(Icons.note),
                            ),
                            maxLines: 3,
                            enabled: !_isUpdating,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isUpdating || _selectedStatus == incident.status
                                ? null
                                : () => _updateStatus(incident),
                            child: _isUpdating
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Save Update'),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState(
          message: kDebugMode
              ? 'Failed to load incident details: $error'
              : 'Failed to load incident details',
          onRetry: () => ref.invalidate(incidentByIdProvider(widget.incidentId)),
        ),
      ),
    );
  }

  Widget _buildTimeline(IncidentModel incident) {
    final steps = [
      _TimelineStep(
        status: IncidentStatus.submitted,
        entry: incident.submittedEntry,
        isActive: true,
      ),
      _TimelineStep(
        status: IncidentStatus.inProgress,
        entry: incident.inProgressEntry,
        isActive: incident.status == IncidentStatus.inProgress ||
            incident.status == IncidentStatus.resolved,
      ),
      _TimelineStep(
        status: IncidentStatus.resolved,
        entry: incident.resolvedEntry,
        isActive: incident.status == IncidentStatus.resolved,
      ),
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final step = steps[index ~/ 2];
          return Expanded(
            child: Container(
              height: 2,
              color: step.isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300],
            ),
          );
        } else {
          // Step circle
          final step = steps[index ~/ 2];
          return Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: step.isActive
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300],
                ),
                child: step.isActive
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(
                step.status.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: step.isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                step.entry != null
                    ? DateFormat('MMM dd').format(step.entry!.timestamp)
                    : '—',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        }
      }),
    );
  }
}

class _TimelineStep {
  final IncidentStatus status;
  final StatusHistoryEntry? entry;
  final bool isActive;

  _TimelineStep({
    required this.status,
    this.entry,
    required this.isActive,
  });
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
