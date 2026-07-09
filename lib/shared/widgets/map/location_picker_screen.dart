import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/i18n/i18n.dart';
import '../../../core/services/geo_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../primary_button.dart';
import 'map_common.dart';

/// Pantalla de selección de ubicación sobre un mapa de OpenStreetMap.
///
/// El usuario arrastra el mapa (el pin permanece fijo en el centro, estilo
/// Uber), busca una dirección o usa su ubicación GPS. Devuelve un [GeoPlace]
/// con coordenadas + dirección legible.
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.title,
    required this.accentColor,
    required this.initialCenter,
    this.initialPlace,
    this.confirmLabel = 'Confirmar ubicación',
  });

  final String title;
  final Color accentColor;
  final LatLng initialCenter;
  final GeoPlace? initialPlace;
  final String confirmLabel;

  static Future<GeoPlace?> show(
    BuildContext context, {
    required String title,
    required Color accentColor,
    required LatLng initialCenter,
    GeoPlace? initialPlace,
    String confirmLabel = 'Confirmar ubicación',
  }) {
    return Navigator.of(context).push<GeoPlace>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LocationPickerScreen(
          title: title,
          accentColor: accentColor,
          initialCenter: initialCenter,
          initialPlace: initialPlace,
          confirmLabel: confirmLabel,
        ),
      ),
    );
  }

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _mapController = MapController();
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  GeoPlace? _selected;
  bool _reverseLoading = false;
  bool _locating = false;

  List<GeoPlace> _results = const [];
  bool _searching = false;

  Timer? _reverseDebounce;
  Timer? _searchDebounce;
  int _reverseToken = 0;

  GeoService get _geo => ref.read(geoServiceProvider);

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPlace;
    if (_selected == null) {
      // Resuelve la dirección del centro inicial.
      _reverseGeocode(widget.initialCenter);
    }
  }

  @override
  void dispose() {
    _reverseDebounce?.cancel();
    _searchDebounce?.cancel();
    _mapController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    if (!hasGesture) return;
    _reverseDebounce?.cancel();
    setState(() => _reverseLoading = true);
    _reverseDebounce = Timer(const Duration(milliseconds: 550), () {
      _reverseGeocode(camera.center);
    });
  }

  Future<void> _reverseGeocode(LatLng point) async {
    final token = ++_reverseToken;
    setState(() => _reverseLoading = true);
    final place = await _geo.reverse(point);
    if (!mounted || token != _reverseToken) return;
    setState(() {
      _selected = place ??
          GeoPlace(
            lat: point.latitude,
            lng: point.longitude,
            address: context.tr('Ubicación seleccionada'),
          );
      _reverseLoading = false;
    });
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    if (value.trim().length < 3) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _searching = true);
    _searchDebounce = Timer(const Duration(milliseconds: 450), () async {
      final results =
          await _geo.search(value, near: _mapController.camera.center);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    });
  }

  void _selectResult(GeoPlace place) {
    _searchFocus.unfocus();
    _searchController.clear();
    setState(() {
      _results = const [];
      _selected = place;
    });
    _mapController.move(place.latLng, 16.5);
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    final pos = await LocationService.current();
    if (!mounted) return;
    setState(() => _locating = false);
    if (pos == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context
              .tr('No pudimos obtener tu ubicación. Revisa los permisos.')),
        ),
      );
      return;
    }
    _mapController.move(pos, 16.5);
    _reverseGeocode(pos);
  }

  void _confirm() {
    if (_selected == null) return;
    Navigator.of(context).pop(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // ---- Mapa ----------------------------------------------------
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: widget.initialPlace?.latLng ??
                    widget.initialCenter,
                initialZoom: 15,
                minZoom: 4,
                maxZoom: 19,
                onPositionChanged: _onPositionChanged,
                onTap: (_, __) => _searchFocus.unfocus(),
              ),
              children: [
                osmTileLayer(),
                const OsmAttribution(alignment: Alignment.bottomLeft),
              ],
            ),

            // ---- Pin fijo en el centro ----------------------------------
            IgnorePointer(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -22),
                  child: _CenterPin(
                    color: widget.accentColor,
                    lifted: _reverseLoading,
                  ),
                ),
              ),
            ),

            // ---- Barra de búsqueda + resultados -------------------------
            Positioned(
              top: 8,
              left: 12,
              right: 12,
              child: _SearchPanel(
                controller: _searchController,
                focusNode: _searchFocus,
                title: widget.title,
                searching: _searching,
                results: _results,
                onChanged: _onSearchChanged,
                onSelect: _selectResult,
                onBack: () => Navigator.of(context).maybePop(),
                // Al elegir por primera vez, abrimos con el teclado listo para
                // escribir. Al reeditar un punto ya elegido, no molestamos.
                autofocus: widget.initialPlace == null,
              ),
            ),

            // ---- Botón "mi ubicación" -----------------------------------
            Positioned(
              right: 16,
              bottom: 180,
              child: FloatingActionButton.small(
                heroTag: 'loc',
                onPressed: _locating ? null : _useMyLocation,
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: widget.accentColor,
                child: _locating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2.4),
                      )
                    : const Icon(Icons.my_location_rounded),
              ),
            ),

            // ---- Tarjeta inferior de confirmación -----------------------
            Align(
              alignment: Alignment.bottomCenter,
              child: _ConfirmCard(
                place: _selected,
                loading: _reverseLoading && _selected == null,
                accentColor: widget.accentColor,
                confirmLabel: widget.confirmLabel,
                onConfirm: _selected == null ? null : _confirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterPin extends StatelessWidget {
  const _CenterPin({required this.color, required this.lifted});
  final Color color;
  final bool lifted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, lifted ? -6 : 0, 0),
          child: Icon(Icons.location_on, size: 46, color: color),
        ),
        // Sombra en el punto exacto.
        Container(
          width: 10,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ],
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({
    required this.controller,
    required this.focusNode,
    required this.title,
    required this.searching,
    required this.results,
    required this.onChanged,
    required this.onSelect,
    required this.onBack,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String title;
  final bool searching;
  final List<GeoPlace> results;
  final ValueChanged<String> onChanged;
  final ValueChanged<GeoPlace> onSelect;
  final VoidCallback onBack;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: onBack,
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: autofocus,
                    onChanged: onChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: context.tr('Busca una dirección, calle o lugar…'),
                    ),
                  ),
                ),
                if (searching)
                  const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
              ],
            ),
          ),
        ),
        if (results.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: const BoxConstraints(maxHeight: 280),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: results.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: context.palette.border),
              itemBuilder: (_, i) {
                final place = results[i];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.place_outlined, size: 20),
                  title: Text(
                    place.shortName ?? place.address.split(',').first,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    place.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onSelect(place),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.place,
    required this.loading,
    required this.accentColor,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final GeoPlace? place;
  final bool loading;
  final Color accentColor;
  final String confirmLabel;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.place_rounded, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: loading
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(context.tr('Buscando dirección…'),
                            style: Theme.of(context).textTheme.bodyMedium),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place?.shortName ??
                                place?.address.split(',').first ??
                                context.tr('Mueve el mapa para elegir'),
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (place != null)
                            Text(
                              place!.address,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: context.palette.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: context.tr(confirmLabel),
            icon: Icons.check_rounded,
            onPressed: onConfirm,
          ),
        ],
      ),
    );
  }
}
