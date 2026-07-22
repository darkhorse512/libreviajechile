import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/app_user.dart';
import '../../data/providers.dart';
import '../verification/verification_flow.dart';

/// Documentos requeridos para verificar a un conductor (KYC).
const _driverDocs = <VerifDoc>[
  VerifDoc(
    column: 'doc_driver_photo',
    kind: 'avatar', // también será su avatar
    icon: Icons.person_rounded,
    title: 'Foto del conductor',
    instructions: [
      'Sube una foto tuya de frente, con buena iluminación y sin lentes de sol ni gorro.',
      'Esta será la foto que verán los pasajeros cuando aceptes sus viajes.',
    ],
  ),
  VerifDoc(
    column: 'doc_license',
    kind: 'doc_license',
    icon: Icons.badge_rounded,
    title: 'Licencia de conducir',
    instructions: [
      'Sube una foto de tu licencia de conducir vigente.',
      'Todos los datos deben verse completos y legibles.',
    ],
  ),
  VerifDoc(
    column: 'doc_vehicle_reg',
    kind: 'doc_vehicle_reg',
    icon: Icons.description_rounded,
    title: 'Permiso de circulación',
    instructions: [
      'Sube la foto del permiso de circulación donde se vea la placa, año y modelo del vehículo.',
      'El permiso de circulación debe estar vigente.',
    ],
  ),
  VerifDoc(
    column: 'doc_antecedentes',
    kind: 'doc_antecedentes',
    icon: Icons.fact_check_rounded,
    title: 'Certificado de antecedentes',
    instructions: [
      'Sube tu certificado de antecedentes vigente.',
      'Puede ser una imagen o un archivo PDF.',
    ],
  ),
  VerifDoc(
    column: 'doc_soap',
    kind: 'doc_soap',
    icon: Icons.health_and_safety_rounded,
    title: 'Seguro Obligatorio (SOAP)',
    instructions: [
      'Sube tu Seguro Obligatorio de Accidentes Personales (SOAP) vigente.',
      'Deben verse la patente y la fecha de vencimiento.',
    ],
  ),
  VerifDoc(
    column: 'doc_car_front',
    kind: 'doc_car_front',
    icon: Icons.directions_car_rounded,
    title: 'Foto del auto — parte delantera',
    instructions: [
      'Toma una foto del auto desde el frente. Asegúrate de que el auto se vea por completo y que la placa sea fácil de leer.',
    ],
  ),
  VerifDoc(
    column: 'doc_car_back',
    kind: 'doc_car_back',
    icon: Icons.time_to_leave_rounded,
    title: 'Foto del auto — parte trasera',
    instructions: [
      'Toma una foto del auto desde atrás. Asegúrate de que el auto se vea por completo y que la placa sea fácil de leer.',
    ],
  ),
];

String _driverExisting(AppUser u, VerifDoc d) {
  final v = u.vehicle;
  if (v == null) return '';
  return switch (d.column) {
        'doc_driver_photo' => v.docDriverPhoto,
        'doc_license' => v.docLicense,
        'doc_vehicle_reg' => v.docVehicleReg,
        'doc_antecedentes' => v.docAntecedentes,
        'doc_soap' => v.docSoap,
        'doc_car_front' => v.docCarFront,
        'doc_car_back' => v.docCarBack,
        _ => null,
      } ??
      '';
}

/// Pantalla mostrada al conductor mientras NO está aprobado.
class DriverVerificationScreen extends ConsumerWidget {
  const DriverVerificationScreen({super.key, required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VerificationFlow(
      user: user,
      docs: _driverDocs,
      existingUrl: _driverExisting,
      avatarColumn: 'doc_driver_photo',
      title: 'Verifica tu cuenta',
      subtitle: 'Sube estos documentos para empezar a recibir viajes.',
      pendingMessage:
          'Recibimos tus documentos. Un administrador revisará tu cuenta y te avisaremos cuando puedas empezar a recibir viajes.',
      onSubmit: (docs, avatarUrl) => ref
          .read(authRepositoryProvider)
          .setDriverDocuments(user.id, docs, avatarUrl: avatarUrl),
    );
  }
}
