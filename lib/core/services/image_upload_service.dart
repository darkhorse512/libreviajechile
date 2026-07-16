import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Un archivo elegido por el usuario, listo para subir (imagen o PDF).
class PickedFileData {
  const PickedFileData({
    required this.bytes,
    required this.contentType,
    this.fileName,
  });

  final Uint8List bytes;
  final String contentType;
  final String? fileName;

  bool get isPdf => contentType.contains('pdf');
}

/// Selecciona imágenes/PDF y los sube a Cloudflare R2 mediante la Edge Function
/// `upload-image`. Las credenciales de R2 viven en el servidor (nunca en la app).
abstract class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();

  /// Selecciona una imagen y la sube directamente. [kind]: 'avatar' o 'car'.
  /// Devuelve la URL pública o `null` si se cancela o falla.
  static Future<String?> pickAndUpload({
    required String kind,
    required ImageSource source,
  }) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80, // recomprime a JPEG
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return uploadBytes(
      bytes: bytes,
      contentType: 'image/jpeg',
      kind: kind,
    );
  }

  /// Toma una foto (cámara/galería) para un documento. Devuelve los bytes sin
  /// subir todavía, para poder previsualizarlos.
  static Future<PickedFileData?> capturePhoto(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 82,
    );
    if (file == null) return null;
    return PickedFileData(
      bytes: await file.readAsBytes(),
      contentType: 'image/jpeg',
      fileName: file.name,
    );
  }

  /// Selecciona un archivo (imagen o PDF) del dispositivo para un documento.
  static Future<PickedFileData?> pickDocumentFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    final file = res?.files.firstOrNull;
    if (file == null || file.bytes == null) return null;
    final ext = (file.extension ?? '').toLowerCase();
    final ct = ext == 'pdf'
        ? 'application/pdf'
        : ext == 'png'
            ? 'image/png'
            : 'image/jpeg';
    return PickedFileData(
      bytes: file.bytes!,
      contentType: ct,
      fileName: file.name,
    );
  }

  /// Sube bytes arbitrarios (imagen o PDF) a R2. Devuelve la URL pública.
  ///
  /// Lanza [ImageUploadException] con un mensaje legible si la Edge Function
  /// no está desplegada, faltan secretos de R2, o la subida falla.
  static Future<String> uploadBytes({
    required Uint8List bytes,
    required String contentType,
    required String kind,
  }) async {
    try {
      final res = await Supabase.instance.client.functions.invoke(
        'upload-image',
        body: {
          'data': base64Encode(bytes),
          'contentType': contentType,
          'kind': kind,
        },
      );
      final data = res.data;
      if (data is Map && data['url'] is String) {
        return data['url'] as String;
      }
      throw ImageUploadException(
          'Respuesta inesperada del servidor de subida (${res.status}).');
    } on FunctionException catch (e) {
      // La Edge Function devolvió un error (no desplegada, secretos de R2
      // faltantes, fallo de R2, etc.). Extrae el detalle si existe.
      final detail = e.details ?? e.reasonPhrase ?? '';
      throw ImageUploadException(
          'Error del servidor de subida (${e.status}). $detail'.trim());
    }
  }
}

/// Error legible al subir un archivo (para mostrar al usuario / depurar).
class ImageUploadException implements Exception {
  ImageUploadException(this.message);
  final String message;
  @override
  String toString() => message;
}
