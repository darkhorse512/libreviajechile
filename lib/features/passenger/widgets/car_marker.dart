import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_colors.dart';

/// Genera un marcador personalizado de "auto" (círculo con ícono de vehículo)
/// como [BitmapDescriptor] para Google Maps. Se dibuja en un canvas para no
/// depender de assets externos.
Future<BitmapDescriptor> buildCarMarker({
  Color background = AppColors.brand,
  Color foreground = AppColors.onBrand,
  double logicalSize = 46,
  double pixelRatio = 3,
}) async {
  final size = logicalSize * pixelRatio;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final center = Offset(size / 2, size / 2);
  final radius = size / 2;

  // Sombra suave.
  canvas.drawCircle(
    center + Offset(0, size * 0.03),
    radius - size * 0.04,
    Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
  // Círculo de fondo.
  canvas.drawCircle(center, radius - size * 0.06, Paint()..color = background);
  // Borde blanco.
  canvas.drawCircle(
    center,
    radius - size * 0.06,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.06,
  );

  // Ícono de auto (fuente MaterialIcons).
  const icon = Icons.directions_car_rounded;
  final tp = TextPainter(textDirection: TextDirection.ltr);
  tp.text = TextSpan(
    text: String.fromCharCode(icon.codePoint),
    style: TextStyle(
      fontSize: size * 0.5,
      fontFamily: icon.fontFamily,
      package: icon.fontPackage,
      color: foreground,
    ),
  );
  tp.layout();
  tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));

  final image =
      await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return BitmapDescriptor.bytes(
    bytes!.buffer.asUint8List(),
    imagePixelRatio: pixelRatio,
    width: logicalSize,
    height: logicalSize,
  );
}
