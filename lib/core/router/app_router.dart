import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../core/providers/firebase_providers.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/incidents/presentation/screens/student_shell.dart';
import '../../features/staff/presentation/screens/staff_shell.dart';
import '../constants/app_constants.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshListenable();
  ref.listen(authStateChangesProvider, (_, __) => refreshListenable.refresh());
  ref.listen(currentUserDataProvider, (_, __) => refreshListenable.refresh());

  final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authStateAsync = ref.read(authStateChangesProvider);
      final currentUserDataAsync = ref.read(currentUserDataProvider);
      final location = state.matchedLocation;
      final isOnSplash = location == '/splash';
      final isOnAuth = location.startsWith('/auth');

      if (authStateAsync.isLoading) {
        return isOnSplash ? null : '/splash';
      }

      if (authStateAsync.hasError) {
        return location == '/startup-error' ? null : '/startup-error';
      }

      final isAuthenticated = authStateAsync.valueOrNull != null;
      if (!isAuthenticated) {
        if (isOnSplash || (!isOnAuth && location != '/startup-error')) {
          return '/auth/login';
        }
        return null;
      }

      if (currentUserDataAsync.isLoading) {
        return isOnSplash ? null : '/splash';
      }

      if (currentUserDataAsync.hasError || currentUserDataAsync.valueOrNull == null) {
        return location == '/startup-error' ? null : '/startup-error';
      }

      final userData = currentUserDataAsync.valueOrNull!;

      if (isOnAuth || isOnSplash || location == '/startup-error') {
        if (userData.role == UserRole.staff) {
          return '/staff';
        } else {
          return '/student';
        }
      }

      // Role-based guards
      if (isAuthenticated) {
        final isOnStudent = location.startsWith('/student');
        final isOnStaff = location.startsWith('/staff');

        if (userData.role == UserRole.student && isOnStaff) {
          return '/student';
        }

        if (userData.role == UserRole.staff && isOnStudent) {
          return '/staff';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/startup-error',
        builder: (context, state) => StartupErrorScreen(
          error: ref.read(authStateChangesProvider).error ??
              ref.read(currentUserDataProvider).error,
        ),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentShell(),
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffShell(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refreshListenable.dispose();
  });

  return router;
});

class _RouterRefreshListenable extends ChangeNotifier {
  void refresh() => notifyListeners();
}

class StartupErrorScreen extends ConsumerWidget {
  const StartupErrorScreen({super.key, this.error});

  final Object? error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Could not load your account',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error?.toString() ?? 'Check your connection and Firebase setup.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      ref.invalidate(authStateChangesProvider);
                      ref.invalidate(currentUserDataProvider);
                      context.go('/splash');
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
