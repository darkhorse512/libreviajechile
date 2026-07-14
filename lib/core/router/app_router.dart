import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/enums.dart';
import '../../data/providers.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/passenger_register_screen.dart';
import '../../features/auth/driver_register_screen.dart';
import '../../features/auth/role_selection_screen.dart';
import '../../features/auth/verify_email_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/driver/driver_shell.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/passenger/passenger_shell.dart';
import '../../features/passenger/request_trip_screen.dart';
import '../../features/passenger/trip_detail_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../onboarding_controller.dart';
import 'routes.dart';

/// Escucha los providers relevantes y notifica a GoRouter para reevaluar
/// las redirecciones (auth / onboarding).
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(onboardingCompletedProvider, (_, __) => notifyListeners());
  }
  final Ref _ref;

  String? redirect(BuildContext context, GoRouterState state) {
    final authAsync = _ref.read(authStateProvider);
    final onboarded = _ref.read(onboardingCompletedProvider);
    final loc = state.matchedLocation;

    // La pantalla de recuperación se autogestiona: al verificar el código se
    // abre una sesión temporal, pero el usuario debe permanecer aquí para
    // definir la nueva contraseña. No redirigir mientras esté en ella.
    if (loc == Routes.resetPassword) return null;

    // Aún resolviendo la sesión inicial → splash.
    if (authAsync.isLoading) {
      return loc == Routes.splash ? null : Routes.splash;
    }

    final user = authAsync.valueOrNull;
    final loggedIn = user != null;

    // Rutas del flujo público (sin sesión).
    const publicRoutes = {
      Routes.welcome,
      Routes.roleSelection,
      Routes.login,
      Routes.registerPassenger,
      Routes.registerDriver,
      Routes.verifyEmail,
    };
    final onSplashOrOnboarding =
        loc == Routes.splash || loc == Routes.onboarding;

    if (!loggedIn) {
      if (!onboarded) {
        return loc == Routes.onboarding ? null : Routes.onboarding;
      }
      // Ya vio el onboarding: debe estar en una ruta pública.
      if (publicRoutes.contains(loc)) return null;
      return Routes.welcome;
    }

    // Con sesión: enviar a su home según rol si está en flujo público/splash.
    final home = user.role == UserRole.driver
        ? Routes.driverHome
        : Routes.passengerHome;

    if (onSplashOrOnboarding || publicRoutes.contains(loc)) {
      return home;
    }
    // Evita que un pasajero entre a rutas de conductor y viceversa.
    if (loc.startsWith('/conductor') && user.role != UserRole.driver) {
      return Routes.passengerHome;
    }
    if (loc.startsWith('/pasajero') && user.role == UserRole.driver) {
      return Routes.driverHome;
    }
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);
  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(path: Routes.welcome, builder: (_, __) => const WelcomeScreen()),
      GoRoute(
        path: Routes.roleSelection,
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: Routes.registerPassenger,
        builder: (_, __) => const PassengerRegisterScreen(),
      ),
      GoRoute(
        path: Routes.registerDriver,
        builder: (_, __) => const DriverRegisterScreen(),
      ),
      GoRoute(
        path: Routes.verifyEmail,
        builder: (_, state) => VerifyEmailScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, state) => ResetPasswordScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),

      // Pasajero
      GoRoute(
        path: Routes.passengerHome,
        builder: (_, __) => const PassengerShell(),
      ),
      GoRoute(
        path: Routes.requestTrip,
        builder: (_, __) => const RequestTripScreen(),
      ),
      GoRoute(
        path: '${Routes.passengerTrip}/:id',
        builder: (_, state) =>
            TripDetailScreen(tripId: state.pathParameters['id']!),
      ),

      // Conductor
      GoRoute(
        path: Routes.driverHome,
        builder: (_, __) => const DriverShell(),
      ),
    ],
  );
});
