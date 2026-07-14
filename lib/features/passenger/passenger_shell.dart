import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/i18n.dart';
import '../notifications/notification_listeners.dart';
import '../../shared/widgets/app_top_controls.dart';
import 'passenger_home_screen.dart';
import 'passenger_trips_screen.dart';
import '../profile/profile_screen.dart';

/// Contenedor principal del pasajero con navegación inferior.
class PassengerShell extends ConsumerStatefulWidget {
  const PassengerShell({super.key});

  @override
  ConsumerState<PassengerShell> createState() => _PassengerShellState();
}

class _PassengerShellState extends ConsumerState<PassengerShell> {
  int _index = 0;

  static const _tabs = [
    PassengerHomeScreen(),
    PassengerTripsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PassengerNotifications(
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
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: context.tr('Inicio'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
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
    );
  }
}
