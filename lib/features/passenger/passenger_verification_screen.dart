import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_user.dart';
import '../../data/providers.dart';
import '../verification/verification_flow.dart';

/// Documentos requeridos para verificar a un pasajero: cédula/documento de
/// identidad por ambas caras.
const _passengerDocs = <VerifDoc>[
  VerifDoc(
    column: 'doc_id_front',
    kind: 'id_front',
    icon: Icons.badge_rounded,
    title: 'Cédula de identidad (frente)',
    instructions: [
      'Sube una foto del frente de tu cédula de identidad o pasaporte.',
      'Asegúrate de que la foto, el nombre y el número se vean completos y legibles.',
    ],
  ),
  VerifDoc(
    column: 'doc_id_back',
    kind: 'id_back',
    icon: Icons.badge_outlined,
    title: 'Cédula de identidad (reverso)',
    instructions: [
      'Sube una foto del reverso de tu cédula de identidad.',
      'Sin filtros y con buena iluminación. Si tu documento tiene una sola cara, sube la misma foto.',
    ],
  ),
];

String _passengerExisting(AppUser u, VerifDoc d) => switch (d.column) {
      'doc_id_front' => u.idFront ?? '',
      'doc_id_back' => u.idBack ?? '',
      _ => '',
    };

/// Pantalla mostrada al pasajero mientras NO está aprobado: le pide subir su
/// documento de identidad y luego muestra el estado de revisión.
class PassengerVerificationScreen extends ConsumerWidget {
  const PassengerVerificationScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VerificationFlow(
      user: user,
      docs: _passengerDocs,
      existingUrl: _passengerExisting,
      title: 'Verifica tu identidad',
      subtitle: 'Sube tu documento de identidad para empezar a viajar.',
      pendingMessage:
          'Recibimos tu documento de identidad. Un administrador revisará tu cuenta y te avisaremos cuando puedas empezar a solicitar viajes.',
      onSubmit: (docs, _) =>
          ref.read(authRepositoryProvider).setPassengerDocuments(user.id, docs),
    );
  }
}
