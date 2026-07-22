import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/widgets/app_feedback.dart';

/// Utilidades para contactar a otro usuario (llamada / WhatsApp).
abstract class Contact {
  static String _digits(String phone) => phone.replaceAll(RegExp(r'\D'), '');

  static Future<void> call(BuildContext context, String? phone) async {
    if (phone == null || phone.trim().isEmpty) {
      AppFeedback.info(context, 'No hay teléfono disponible');
      return;
    }
    final uri = Uri.parse('tel:${phone.replaceAll(RegExp(r'[^\d+]'), '')}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) AppFeedback.error(context, 'No se pudo iniciar la llamada');
    }
  }

  /// Abre el cliente de correo con el destinatario (y asunto opcional).
  static Future<void> email(
    BuildContext context,
    String address, {
    String? subject,
  }) async {
    final query =
        subject != null ? '?subject=${Uri.encodeComponent(subject)}' : '';
    final uri = Uri.parse('mailto:$address$query');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        AppFeedback.error(context, 'No se pudo abrir el correo');
      }
    }
  }

  static Future<void> whatsapp(
    BuildContext context,
    String? phone, {
    String? message,
  }) async {
    if (phone == null || phone.trim().isEmpty) {
      AppFeedback.info(context, 'No hay teléfono disponible');
      return;
    }
    var number = _digits(phone);
    // Chile: si viene sin código país (9 dígitos), anteponer 56.
    if (number.length == 9 && number.startsWith('9')) number = '56$number';
    final text = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
    final uri = Uri.parse('https://wa.me/$number$text');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) AppFeedback.error(context, 'No se pudo abrir WhatsApp');
    }
  }
}
