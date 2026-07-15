import 'dart:convert';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Selecciona una imagen y la sube a Cloudflare R2 mediante la Edge Function
/// `upload-image`. Las credenciales de R2 viven en el servidor (nunca en la app).
abstract class ImageUploadService {
  static final ImagePicker _picker = ImagePicker();

  /// [kind]: 'avatar' o 'car'. Devuelve la URL pública o `null` si se cancela
  /// o falla.
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
    final res = await Supabase.instance.client.functions.invoke(
      'upload-image',
      body: {
        'data': base64Encode(bytes),
        'contentType': 'image/jpeg',
        'kind': kind,
      },
    );
    final data = res.data;
    if (data is Map && data['url'] is String) {
      return data['url'] as String;
    }
    return null;
  }
}
