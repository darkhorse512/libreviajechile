import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/widgets/app_feedback.dart';
import '../i18n/i18n.dart';

/// Lanza navegación externa hacia un punto. Por ahora: Waze (gratis, deep link).
abstract class NavigationService {
  /// Abre Waze navegando hacia [target]. Si la app no está instalada, usa el
  /// enlace universal (que abre la web/tienda de Waze).
  static Future<void> openWaze(BuildContext context, LatLng target) async {
    final ll = '${target.latitude},${target.longitude}';
    final appUri = Uri.parse('waze://?ll=$ll&navigate=yes');
    final webUri = Uri.parse('https://waze.com/ul?ll=$ll&navigate=yes');
    try {
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        AppFeedback.error(context, context.tr('No se pudo abrir Waze'));
      }
    }
  }
}
