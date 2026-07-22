import 'package:flutter/material.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/contact.dart';
import '../../shared/widgets/app_top_controls.dart';
import '../safety/emergency_screen.dart';
import 'legal_widgets.dart';

/// Ayuda y Soporte de EligeDriver: canales y procedimientos.
///
/// El cuerpo se mantiene en español; solo los rótulos de navegación y el botón
/// de contacto se traducen.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const supportEmail = LegalInfo.email;

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SupportScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Ayuda y soporte')),
        actions: const [AppTopControls(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
          children: [
            const LegalHeader(
              title: 'Ayuda y Soporte',
              subtitle: 'Canales y procedimientos para pasajeros y conductores',
              icon: Icons.support_agent_rounded,
            ),
            const SizedBox(height: 16),

            // Acción principal: escribir al correo oficial.
            _ContactCard(
              onEmail: () => Contact.email(
                context,
                supportEmail,
                subject: 'Ayuda y soporte · EligeDriver',
              ),
            ),
            const SizedBox(height: 16),

            const LegalSummaryBox(
              title: 'Canal oficial y alcance',
              body:
                  'El correo oficial de ayuda y soporte es eligedrive@gmail.com. EligeDriver es una plataforma tecnológica de coordinación y este canal recibe, registra y revisa solicitudes relacionadas con la aplicación. No es un servicio de emergencia, policía, tribunal, aseguradora ni asesoría jurídica. EligeDriver no solicitará contraseñas, códigos de acceso ni datos completos de tarjetas por correo.',
              icon: Icons.mark_email_read_rounded,
            ),
            const SizedBox(height: 8),

            const LegalSection(1, 'Naturaleza de la plataforma y responsabilidades'),
            const LegalParagraph(
                'EligeDriver facilita y coordina el contacto entre pasajeros y conductores mediante herramientas tecnológicas. EligeDriver no conduce materialmente los vehículos, no controla en tiempo real todas las decisiones del conductor y, salvo que se informe expresamente lo contrario, no es propietario ni administrador del vehículo utilizado en cada viaje.'),
            const LegalParagraph(
                'Cada conductor responde por sus actos personales, conducción, cumplimiento de las normas de tránsito, estado y documentación del vehículo, seguridad operacional y cobros que efectúe. Cada pasajero responde por la veracidad de sus datos, su conducta, instrucciones, bienes y pago del viaje. EligeDriver responde por las obligaciones legales y contractuales que le correspondan respecto de la plataforma, la información, el soporte, la seguridad tecnológica, los datos personales y las demás materias que la ley le atribuya.'),
            const LegalParagraph(
                'La recepción de un reporte, la entrega de orientación, la suspensión preventiva de una cuenta o la facilitación de contacto no implica que EligeDriver reconozca responsabilidad, confirme la versión de una parte ni garantice una compensación. Nada de este documento limita derechos irrenunciables ni responsabilidades legalmente exigibles.'),

            const LegalSection(2, 'Cómo solicitar ayuda'),
            const LegalParagraph(
                'Puedes solicitar ayuda desde la sección Ayuda y soporte de la aplicación o escribiendo al correo oficial. Para facilitar la revisión, incluye sólo la información necesaria.'),
            const LegalBullets([
              'Correo asociado a la cuenta o identificador de usuario.',
              'Fecha y hora aproximada del viaje o incidente.',
              'Identificador del viaje, cuando esté disponible.',
              'Descripción clara del problema y solución esperada.',
              'Monto involucrado, si corresponde.',
              'Capturas, comprobantes o fotografías pertinentes.',
            ]),
            const LegalParagraph(
                'No envíes contraseñas, códigos de autenticación, claves bancarias ni datos completos de tarjetas. EligeDriver podrá pedir antecedentes adicionales para verificar identidad y evitar accesos no autorizados.'),

            const LegalSection(3, 'Tipos de solicitudes'),
            const LegalBullets([
              'Problemas para registrarse, iniciar sesión o verificar la cuenta.',
              'Corrección de datos personales o documentos.',
              'Consultas sobre solicitudes, ofertas, contrapropuestas o viajes.',
              'Revisión de cobros, pagos, devoluciones, comisiones o pases.',
              'Cancelaciones, tiempos de espera o pasajero ausente.',
              'Objetos olvidados.',
              'Problemas de seguridad, acoso, discriminación, fraude o suplantación.',
              'Actualización o revisión de documentos de conductores y vehículos.',
              'Suspensión, bloqueo, cierre o apelación de cuentas.',
              'Ejercicio de derechos de privacidad y eliminación de cuenta.',
              'Fallas técnicas, GPS, mapas, notificaciones o funcionamiento de la aplicación.',
            ]),

            const LegalSection(4, 'Emergencias y seguridad inmediata'),
            const LegalParagraph(
                'EligeDriver no es un servicio de emergencia y el correo no se monitorea como canal de respuesta inmediata. Ante peligro, accidente, agresión, delito o urgencia médica, contacta directamente a los servicios públicos de emergencia o a la autoridad competente y ubícate en un lugar seguro.'),
            const SizedBox(height: 4),
            OutlinedButton.icon(
              onPressed: () => EmergencyScreen.show(context),
              icon: const Icon(Icons.emergency_rounded, color: AppColors.danger),
              label: Text(context.tr('Números de emergencia')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 12),
            const LegalParagraph(
                'Después de controlar la situación, reporta el incidente desde la aplicación o por correo, indicando el viaje y los antecedentes disponibles. EligeDriver podrá preservar registros y cooperar con autoridades cuando exista una solicitud válida o base legal.'),

            const LegalSection(5, 'Cobros, pagos y devoluciones'),
            const LegalParagraph(
                'Para solicitar revisión de un cobro, indica el viaje, monto, medio de pago y motivo. EligeDriver contrastará la información de la plataforma y podrá solicitar antecedentes al pasajero, conductor o proveedor de pago.'),
            const LegalParagraph(
                'Cuando corresponda una devolución, se realizará mediante el mismo medio de pago o mediante otra alternativa informada. Los tiempos bancarios o del proveedor externo pueden variar y no dependen completamente de EligeDriver.'),

            const LegalSection(6, 'Objetos olvidados'),
            const LegalOrderedList([
              'Reporta el objeto y el viaje desde Ayuda y soporte o por correo.',
              'Describe el objeto sin incluir información sensible innecesaria.',
              'EligeDriver podrá facilitar la comunicación entre las partes, procurando proteger los datos personales.',
              'La entrega se coordinará en un lugar y horario seguro. EligeDriver no garantiza la recuperación y no actúa como depositario.',
            ]),

            const LegalSection(7, 'Soporte para conductores'),
            const LegalParagraph(
                'Los conductores pueden solicitar revisión de documentos, activación, liquidaciones, comisiones, pases, promociones, evaluaciones, incidentes y funcionamiento de la cuenta.'),
            const LegalCallout(
              title: '0% de comisión por seis meses',
              body:
                  'Se aplica a conductores cuyo registro sea completado, aprobado y activado entre el 1 de septiembre de 2026 y el 1 de febrero de 2027, ambas fechas inclusive. La duración se cuenta desde la activación individual de la cuenta.',
            ),

            const LegalSection(8, 'Apelación de suspensión o cierre'),
            const LegalParagraph(
                'El conductor o usuario afectado puede solicitar revisión escribiendo a eligedrive@gmail.com. Debe indicar la cuenta, fecha de la medida, motivo de desacuerdo y antecedentes de respaldo.'),
            const LegalParagraph(
                'EligeDriver revisará los antecedentes dentro de un plazo razonable según la complejidad y el riesgo. Cuando corresponda, la persona podrá solicitar que una decisión relevante sea revisada por una persona y no únicamente por mecanismos automatizados.'),
            const LegalParagraph(
                'Las suspensiones preventivas por seguridad podrán mantenerse mientras se investigan los hechos.'),

            const LegalSection(9, 'Privacidad y datos personales'),
            const LegalParagraph(
                'Las solicitudes de acceso, rectificación, eliminación, oposición, bloqueo, portabilidad o revisión humana deben enviarse a eligedrive@gmail.com. Para proteger la cuenta, EligeDriver podrá solicitar verificación de identidad.'),
            const LegalParagraph(
                'La eliminación de una cuenta no implica borrar de inmediato información que deba conservarse por ley, reclamos pendientes, prevención de fraude, seguridad o defensa de derechos.'),

            const LegalSection(10, 'Problemas técnicos'),
            const LegalBullets([
              'Comprueba la conexión a internet y que la aplicación esté actualizada.',
              'Revisa que la ubicación y notificaciones estén habilitadas cuando la función las requiera.',
              'Cierra y vuelve a abrir la aplicación.',
              'Reinicia el dispositivo si el problema continúa.',
              'Envía una captura, modelo del dispositivo, versión del sistema y descripción del error, evitando incluir datos sensibles.',
            ]),

            const LegalSection(11, 'Fraudes y comunicaciones falsas'),
            const LegalParagraph(
                'Desconfía de mensajes que soliciten contraseñas, códigos de acceso, transferencias a cuentas no informadas en la aplicación o instalación de programas externos. EligeDriver no solicitará claves bancarias ni datos completos de tarjetas por correo.'),
            const LegalParagraph(
                'Reporta cualquier intento de suplantación a eligedrive@gmail.com y no respondas al remitente sospechoso.'),

            const LegalSection(12, 'Investigación de incidentes y conservación de evidencia'),
            const LegalParagraph(
                'EligeDriver podrá revisar registros de cuenta, geolocalización, comunicaciones dentro de la plataforma, pagos, fotografías, calificaciones y demás antecedentes pertinentes; solicitar la versión de las partes; adoptar medidas preventivas; y conservar evidencia durante el tiempo necesario para seguridad, reclamos, seguros, defensa de derechos o cumplimiento legal.'),
            const LegalParagraph(
                'Los registros tecnológicos pueden contener errores por falta de señal, GPS, dispositivo o proveedor externo y serán evaluados junto con los demás antecedentes. Las personas deben conservar comprobantes, fotografías, mensajes y denuncias oficiales que puedan respaldar su versión.'),
            const LegalParagraph(
                'Cuando exista una solicitud válida o una base legal, EligeDriver podrá cooperar con Carabineros, Policía de Investigaciones, Ministerio Público, tribunales, autoridades administrativas, aseguradoras y asesores legales, entregando únicamente la información pertinente y permitida.'),

            const LegalSection(13, 'Denuncias falsas, aprovechamiento y fraude'),
            const LegalParagraph(
                'Está prohibido formular denuncias deliberadamente falsas, presentar documentos o imágenes manipuladas, simular accidentes o daños, coordinar reclamos ficticios, realizar contracargos fraudulentos, amenazar, extorsionar o exigir pagos o beneficios sin fundamento.'),
            const LegalParagraph(
                'Si existen indicios razonables, EligeDriver podrá verificar identidad, pedir antecedentes adicionales, suspender preventivamente la cuenta, rechazar devoluciones o beneficios no acreditados, preservar registros, recuperar montos obtenidos indebidamente por las vías legales y denunciar hechos a las autoridades. Un reclamo formulado honestamente no será sancionado sólo porque no haya podido comprobarse.'),

            const LegalSection(14, 'Servicios de terceros y situaciones fuera de la aplicación'),
            const LegalParagraph(
                'Mapas, geolocalización, pagos, comunicaciones, almacenamiento, seguros u otras funciones pueden depender de proveedores externos. EligeDriver gestionará los incidentes que le correspondan, pero los tiempos y resultados de esos terceros pueden escapar a su control razonable.'),
            const LegalParagraph(
                'El soporte puede no disponer de antecedentes suficientes sobre acuerdos, pagos, desvíos, servicios o comunicaciones realizados fuera de la aplicación. Se recomienda mantener toda coordinación y pago dentro de los canales habilitados. Esta regla no elimina derechos legales ni responsabilidades que correspondan.'),

            const LegalSection(15, 'Contacto oficial'),
            const LegalBullets([
              'Correo de ayuda y soporte: eligedrive@gmail.com',
              'Domicilio: General Aldunate N° 620, departamento/local 704, comuna de Temuco, Región de La Araucanía, Chile.',
              'Canal dentro de la aplicación: Ayuda y soporte.',
            ]),

            const SizedBox(height: 20),
            const LegalFooter(
                'Para mantener un historial verificable, las solicitudes deben presentarse por los canales oficiales indicados en este documento.\n\nEligeDriver SpA · RUT 78.467.243-3 · Versión 1.2'),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta de acción para escribir al soporte por correo.
class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.onEmail});
  final VoidCallback onEmail;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brand,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onEmail,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.mail_rounded, color: AppColors.onBrand),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('Escribir a soporte'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.onBrand,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      SupportScreen.supportEmail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onBrand.withValues(alpha: 0.85),
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.onBrand),
            ],
          ),
        ),
      ),
    );
  }
}
