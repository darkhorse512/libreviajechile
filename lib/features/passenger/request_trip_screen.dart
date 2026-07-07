import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../core/config/app_config.dart';
import '../../core/constants/chilean_cities.dart';
import '../../core/router/routes.dart';
import '../../core/services/geo_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers.dart';
import '../../shared/widgets/app_feedback.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/widgets/city_picker.dart';
import '../../shared/widgets/map/location_picker_screen.dart';
import '../../shared/widgets/map/route_map.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/surface_card.dart';
import '../trips/trip_controller.dart';

class RequestTripScreen extends ConsumerStatefulWidget {
  const RequestTripScreen({super.key});

  @override
  ConsumerState<RequestTripScreen> createState() => _RequestTripScreenState();
}

class _RequestTripScreenState extends ConsumerState<RequestTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();

  String? _city;
  GeoPlace? _origin;
  GeoPlace? _destination;
  int _fare = 2500;
  int _passengers = 1;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _city = ref.read(currentUserProvider)?.city;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _bump(int delta) {
    setState(() {
      _fare = (_fare + delta).clamp(AppConfig.minFareClp, AppConfig.maxFareClp);
    });
  }

  LatLng get _cityCenter {
    final c = cityByName(_city);
    return LatLng(c.lat, c.lng);
  }

  Future<void> _pickOrigin() async {
    final place = await LocationPickerScreen.show(
      context,
      title: 'punto de partida',
      accentColor: AppColors.brand,
      initialCenter: _origin?.latLng ?? _cityCenter,
      initialPlace: _origin,
      confirmLabel: 'Confirmar origen',
    );
    if (place != null) setState(() => _origin = place);
  }

  Future<void> _pickDestination() async {
    final place = await LocationPickerScreen.show(
      context,
      title: 'destino',
      accentColor: AppColors.danger,
      initialCenter: _destination?.latLng ?? _origin?.latLng ?? _cityCenter,
      initialPlace: _destination,
      confirmLabel: 'Confirmar destino',
    );
    if (place != null) setState(() => _destination = place);
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_city == null) {
      AppFeedback.error(context, 'Selecciona la ciudad del viaje');
      return;
    }
    if (_origin == null || _destination == null) {
      AppFeedback.error(context, 'Marca el origen y el destino en el mapa');
      return;
    }
    setState(() => _submitting = true);
    try {
      final trip = await ref.read(tripActionsProvider).createTrip(
            city: _city!,
            originAddress: _origin!.shortName ?? _origin!.address,
            destinationAddress:
                _destination!.shortName ?? _destination!.address,
            originLat: _origin!.lat,
            originLng: _origin!.lng,
            destinationLat: _destination!.lat,
            destinationLng: _destination!.lng,
            offeredFare: _fare,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            passengers: _passengers,
          );
      if (!mounted) return;
      context.pushReplacement('${Routes.passengerTrip}/${trip.id}');
    } catch (_) {
      if (mounted) {
        AppFeedback.error(context, 'No se pudo publicar el viaje');
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar viaje')),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl, 8, AppSpacing.xl, 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CitySelectorField(
                              label: 'Ciudad',
                              value: _city,
                              onChanged: (v) => setState(() => _city = v),
                            ),
                            const SizedBox(height: 18),
                            _LocationField(
                              label: 'Punto de partida',
                              hint: 'Toca para elegir en el mapa',
                              icon: Icons.trip_origin_rounded,
                              iconColor: AppColors.brand,
                              place: _origin,
                              onTap: _pickOrigin,
                            ),
                            const SizedBox(height: 12),
                            _LocationField(
                              label: 'Destino',
                              hint: 'Toca para elegir en el mapa',
                              icon: Icons.location_on_rounded,
                              iconColor: AppColors.danger,
                              place: _destination,
                              onTap: _pickDestination,
                            ),
                          ],
                        ),
                      ),
                      if (_origin != null && _destination != null) ...[
                        const SizedBox(height: 16),
                        RouteMap(
                          origin: _origin!.latLng,
                          destination: _destination!.latLng,
                          onTap: _pickDestination,
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text('Tu oferta',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Propón cuánto quieres pagar. Mínimo ${Formatters.clp(AppConfig.minFareClp)}.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.palette.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 14),
                      _FareSelector(
                        fare: _fare,
                        onMinus: () => _bump(-AppConfig.fareStepClp),
                        onPlus: () => _bump(AppConfig.fareStepClp),
                        onQuick: (v) => setState(() => _fare = v),
                      ),
                      const SizedBox(height: 20),
                      Text('Pasajeros',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: [
                          for (final n in [1, 2, 3, 4])
                            ChoiceChip(
                              label: Text(n == 4 ? '4+' : '$n'),
                              selected: _passengers == n,
                              onSelected: (_) =>
                                  setState(() => _passengers = n),
                              labelStyle: TextStyle(
                                color: _passengers == n ? Colors.white : null,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: 'Nota para el conductor (opcional)',
                        hint: 'Ej: Llevo una maleta, voy con un niño…',
                        controller: _note,
                        icon: Icons.notes_rounded,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 140,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                    top: BorderSide(color: context.palette.border)),
              ),
              child: PrimaryButton(
                label: 'Publicar viaje · ${Formatters.clp(_fare)}',
                icon: Icons.wifi_tethering_rounded,
                loading: _submitting,
                onPressed: _publish,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Campo tipo selector que abre el mapa para elegir una ubicación.
class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.iconColor,
    required this.place,
    required this.onTap,
  });

  final String label;
  final String hint;
  final IconData icon;
  final Color iconColor;
  final GeoPlace? place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = place != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.palette.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Material(
          color: context.palette.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 18, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selected
                              ? (place!.shortName ??
                                  place!.address.split(',').first)
                              : hint,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: selected
                                    ? null
                                    : context.palette.textMuted,
                                fontWeight:
                                    selected ? FontWeight.w600 : FontWeight.w400,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (selected)
                          Text(
                            place!.address,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: context.palette.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    selected ? Icons.edit_location_alt_rounded : Icons.map_rounded,
                    size: 20,
                    color: context.palette.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FareSelector extends StatelessWidget {
  const _FareSelector({
    required this.fare,
    required this.onMinus,
    required this.onPlus,
    required this.onQuick,
  });

  final int fare;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final ValueChanged<int> onQuick;

  @override
  Widget build(BuildContext context) {
    const quick = [2000, 3000, 4500, 6000, 8000];
    return SurfaceCard(
      child: Column(
        children: [
          Row(
            children: [
              _RoundButton(icon: Icons.remove_rounded, onTap: onMinus),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      Formatters.clp(fare),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: AppColors.price,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text('CLP',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: context.palette.textMuted,
                              letterSpacing: 2,
                            )),
                  ],
                ),
              ),
              _RoundButton(icon: Icons.add_rounded, onTap: onPlus),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (final q in quick)
                ActionChip(
                  label: Text(Formatters.clp(q)),
                  onPressed: () => onQuick(q),
                  backgroundColor: fare == q
                      ? AppColors.price.withValues(alpha: 0.15)
                      : null,
                  labelStyle: TextStyle(
                    color: fare == q ? AppColors.price : null,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: fare == q
                        ? AppColors.price
                        : context.palette.border,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.price.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Icon(icon, color: AppColors.price, size: 24),
        ),
      ),
    );
  }
}
