import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/services/location_service.dart';
import '../../data/providers.dart';

/// Mientras el conductor está EN LÍNEA, reporta su ubicación GPS al backend
/// cada [AppConfig.presenceIntervalSeconds] segundos. Esto alimenta:
///   · la distribución de solicitudes por cercanía (feed del conductor), y
///   · el mapa de conductores disponibles del pasajero.
///
/// Se monta en el shell del conductor para funcionar en todas las pestañas.
class DriverPresenceReporter extends ConsumerStatefulWidget {
  const DriverPresenceReporter({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<DriverPresenceReporter> createState() =>
      _DriverPresenceReporterState();
}

class _DriverPresenceReporterState
    extends ConsumerState<DriverPresenceReporter> with WidgetsBindingObserver {
  Timer? _timer;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reporta al volver a primer plano para refrescar la posición al instante.
    if (state == AppLifecycleState.resumed && _online) _report();
  }

  void _start() {
    if (_timer != null) return;
    _report(); // reporte inmediato al ponerse en línea
    _timer = Timer.periodic(
      const Duration(seconds: AppConfig.presenceIntervalSeconds),
      (_) => _report(),
    );
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _report() async {
    final user = ref.read(currentUserProvider);
    if (user == null || !user.isOnline) return;
    final pos = await LocationService.current();
    if (pos == null || !mounted) return;
    ref.read(driverLiveLocationProvider.notifier).state = pos;
    try {
      await ref
          .read(authRepositoryProvider)
          .updateDriverPresence(user.id, pos.latitude, pos.longitude);
    } catch (_) {
      // Silencioso: se reintenta en el próximo ciclo.
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(currentUserProvider)?.isOnline ?? false;
    if (online != _online) {
      _online = online;
      // Difiere para no llamar setState/timer durante el build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        online ? _start() : _stop();
      });
    }
    return widget.child;
  }
}
