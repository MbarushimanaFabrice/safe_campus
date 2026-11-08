import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/avatar_with_fallback.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../providers/incident_providers.dart';
import '../widgets/stat_card.dart';
import '../widgets/incident_card.dart';
import '../widgets/hero_card.dart';
import 'report_incident_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDataAsync = ref.watch(currentUserDataProvider);
    final incidentsAsync = ref.watch(userIncidentsProvider);
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userIncidentsProvider);
            ref.invalidate(unreadNotificationCountProvider);
          },
          child: userDataAsync.when(
            data: (userData) {
              if (userData == null) {
                return const Center(child: Text('User data not found'));
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
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
                                  AppConstants.appTagline,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          // Notification Bell
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const NotificationsScreen(),
                                    ),
                                  );
                                },
                              ),
                              unreadCountAsync.when(
                                data: (count) {
                                  if (count == 0) return const SizedBox.shrink();
                                  return Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          AvatarWithFallback(
                            imageUrl: userData.photoUrl,
                            name: userData.fullName,
                            size: 40,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Hero Card
                      HeroCard(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ReportIncidentScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      // Report Summary
                      SectionHeader(
                        title: 'Report Summary',
                        actionText: 'See all',
                        onActionPressed: () {
                          // Already on home, could navigate to my reports
                        },
                      ),
                      const SizedBox(height: 8),

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

                          return Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.description,
                                  title: 'My Reports',
                                  count: totalCount,
                                  color: Colors.blue,
                                  onTap: () {
                                    // Navigate to my reports
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.schedule,
                                  title: 'In Progress',
                                  count: inProgressCount,
                                  color: Colors.orange,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => Row(
                          children: const [
                            Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
                            SizedBox(width: 12),
                            Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
                          ],
                        ),
                        error: (error, _) => ErrorState(
                          message: 'Failed to load statistics',
                          onRetry: () => ref.invalidate(userIncidentsProvider),
                        ),
                      ),
                      const SizedBox(height: 12),

                      incidentsAsync.when(
                        data: (incidents) {
                          final submittedCount = incidents
                              .where((i) => i.status == IncidentStatus.submitted)
                              .length;
                          final resolvedCount = incidents
                              .where((i) => i.status == IncidentStatus.resolved)
                              .length;

                          return Row(
                            children: [
                              Expanded(
                                child: StatCard(
                                  icon: Icons.pending,
                                  title: 'Submitted',
                                  count: submittedCount,
                                  color: Colors.amber,
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: StatCard(
                                  icon: Icons.check_circle,
                                  title: 'Resolved',
                                  count: resolvedCount,
                                  color: Colors.green,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => Row(
                          children: const [
                            Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
                            SizedBox(width: 12),
                            Expanded(child: ShimmerLoader(width: double.infinity, height: 100)),
                          ],
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),

                      // Recent Reports
                      SectionHeader(
                        title: 'Recent Reports',
                        actionText: 'See all',
                        onActionPressed: () {
                          // Navigate to my reports screen
                        },
                      ),
                      const SizedBox(height: 8),

                      incidentsAsync.when(
                        data: (incidents) {
                          if (incidents.isEmpty) {
                            return EmptyState(
                              icon: Icons.article_outlined,
                              title: 'No reports yet',
                              message:
                                  'Tap the + button to submit your first report.',
                            );
                          }

                          final recentIncidents = incidents.take(3).toList();

                          return Column(
                            children: recentIncidents.map((incident) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: IncidentCard(incident: incident),
                              );
                            }).toList(),
                          );
                        },
                        loading: () => const ShimmerListLoader(itemCount: 3),
                        error: (error, stackTrace) => ErrorState(
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
            error: (error, _) => ErrorState(
              message: 'Failed to load user data',
              onRetry: () => ref.invalidate(currentUserDataProvider),
            ),
          ),
        ),
      ),
    );
  }
}
