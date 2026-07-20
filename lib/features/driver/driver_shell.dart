import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'driver_presence_reporter.dart';
import 'driver_requests_screen.dart';
import 'driver_trips_screen.dart';
import '../../core/i18n/i18n.dart';
import '../notifications/notification_listeners.dart';
import '../../shared/widgets/app_top_controls.dart';
import '../profile/profile_screen.dart';

/// Contenedor principal del conductor con navegación inferior.
class DriverShell extends ConsumerStatefulWidget {
  const DriverShell({super.key});

  @override
  ConsumerState<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends ConsumerState<DriverShell> {
  int _index = 0;

  static const _tabs = [
    DriverRequestsScreen(),
    DriverTripsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return DriverPresenceReporter(
      child: DriverNotifications(
      child: Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            IndexedStack(index: _index, children: _tabs),
            const Positioned(
              top: 4,
              right: 8,
              child: AppTopControls(floating: true),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        height: 68,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.notifications_none_rounded),
            selectedIcon: const Icon(Icons.notifications_rounded),
            label: context.tr('Solicitudes'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.route_outlined),
            selectedIcon: const Icon(Icons.route_rounded),
            label: context.tr('Mis viajes'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded),
            label: context.tr('Perfil'),
          ),
        ],
      ),
      ),
      ),
    );
  }
}
