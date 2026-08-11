import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../navigation/app_shell.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/phone_input_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/marketplace/presentation/screens/home_screen.dart';
import '../../features/marketplace/presentation/screens/listing_detail_screen.dart';
import '../../features/marketplace/presentation/screens/post_listing_screen.dart';
import '../../features/rentals/presentation/screens/rental_browse_screen.dart';
import '../../features/rentals/presentation/screens/rental_detail_screen.dart';
import '../../features/rentals/presentation/screens/list_for_rent_screen.dart';
import '../../features/rentals/presentation/screens/my_bookings_screen.dart';
import '../../features/rentals/presentation/screens/booking_summary_screen.dart';
import '../../features/rentals/presentation/screens/booking_confirmation_screen.dart';
import '../../features/rentals/domain/rental_models.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/my_listings_screen.dart';

const _publicRoutes = {
  '/',
  '/phone',
  '/otp',
  '/login',
  '/signup',
  '/forgot-password',
  '/reset-password',
};

/// Wraps a screen in a smooth fade + slide-up transition, giving every
/// navigation a premium "reveal" feel instead of the default platform
/// slide. Modeled after the reference video: sections crossfade in
/// rather than snapping.
CustomTransitionPage<void> _fadeSlidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.04),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Notifies GoRouter to re-evaluate `redirect` whenever auth state changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final loggingIn = _publicRoutes.contains(state.matchedLocation);

      if (authState.status == AuthStatus.unknown) return null; // splash/loading
      final loggedIn = authState.status == AuthStatus.authenticated;

      if (!loggedIn && !loggingIn) return '/';
      if (loggedIn && loggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => _fadeSlidePage(const WelcomeScreen(), state),
      ),
      GoRoute(
        path: '/phone',
        pageBuilder: (context, state) => _fadeSlidePage(const PhoneInputScreen(), state),
      ),
      GoRoute(
        path: '/otp',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _fadeSlidePage(
            OtpScreen(
              phone: extra['phone'] as String? ?? '',
              devCode: extra['devCode'] as String?,
            ),
            state,
          );
        },
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadeSlidePage(const LoginScreen(), state),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => _fadeSlidePage(const SignupScreen(), state),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) => _fadeSlidePage(const ForgotPasswordScreen(), state),
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _fadeSlidePage(
            ResetPasswordScreen(
              email: extra['email'] as String? ?? '',
              devCode: extra['devCode'] as String?,
            ),
            state,
          );
        },
      ),

      // --- Main app, behind the persistent bottom nav ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/rentals', builder: (context, state) => const RentalBrowseScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/my-bookings', builder: (context, state) => const MyBookingsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),

      // --- Full-screen routes reached by pushing from within the tabs ---
      GoRoute(
        path: '/listing/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePage(
          ListingDetailScreen(listingId: state.pathParameters['id']!),
          state,
        ),
      ),
      GoRoute(
        path: '/post-listing',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePage(const PostListingScreen(), state),
      ),
      GoRoute(
        path: '/rental/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePage(
          RentalDetailScreen(vehicleId: state.pathParameters['id']!),
          state,
        ),
      ),
      GoRoute(
        path: '/list-for-rent',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePage(const ListForRentScreen(), state),
      ),
      GoRoute(
        path: '/booking-summary',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return _fadeSlidePage(
            BookingSummaryScreen(
              vehicle: extra['vehicle'] as RentalVehicle,
              range: extra['range'] as DateTimeRange,
              withDriver: extra['withDriver'] as bool? ?? false,
            ),
            state,
          );
        },
      ),
      GoRoute(
        path: '/booking-confirmation/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePage(
          BookingConfirmationScreen(bookingId: state.pathParameters['id']!),
          state,
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePage(const EditProfileScreen(), state),
      ),
      GoRoute(
        path: '/my-listings',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => _fadeSlidePage(const MyListingsScreen(), state),
      ),
    ],
  );
});
