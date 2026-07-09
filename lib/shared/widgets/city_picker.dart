import 'package:flutter/material.dart';

import '../../core/constants/chilean_cities.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Muestra un selector de ciudad con búsqueda y devuelve el nombre elegido.
Future<String?> showCityPicker(BuildContext context, {String? current}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _CityPickerSheet(current: current),
  );
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({this.current});
  final String? current;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = kChileanCities
        .where((c) =>
            _query.isEmpty ||
            c.name.toLowerCase().contains(_query.toLowerCase()) ||
            c.region.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.palette.border,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('Selecciona tu ciudad'),
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: false,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: context.tr('Buscar ciudad o región…'),
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final city = results[i];
                    final selected = city.name == widget.current;
                    return ListTile(
                      onTap: () => Navigator.pop(context, city.name),
                      leading: Icon(
                        selected
                            ? Icons.location_on_rounded
                            : Icons.location_on_outlined,
                        color: selected ? AppColors.brand : context.palette.textMuted,
                      ),
                      title: Text(city.name),
                      subtitle: Text(city.region),
                      trailing: selected
                          ? const Icon(Icons.check_circle_rounded,
                              color: AppColors.brand)
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Campo tipo "selector" que abre el [showCityPicker].
class CitySelectorField extends StatelessWidget {
  const CitySelectorField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Ciudad',
  });

  final String? value;
  final ValueChanged<String> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr(label),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: context.palette.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () async {
            final result = await showCityPicker(context, current: value);
            if (result != null) onChanged(result);
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_city_rounded, size: 20),
            ),
            child: Text(
              value ?? 'Selecciona tu ciudad',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: value == null ? context.palette.textMuted : null,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}
