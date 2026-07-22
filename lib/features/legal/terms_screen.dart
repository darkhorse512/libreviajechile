import 'package:flutter/material.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_top_controls.dart';
import 'legal_widgets.dart';

/// Términos y Condiciones Generales de Uso de EligeDriver.
///
/// El cuerpo legal se mantiene en español (idioma de origen, legislación
/// chilena); solo los rótulos de navegación se traducen.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TermsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Términos y Condiciones')),
        actions: const [AppTopControls(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
          children: const [
            LegalHeader(
              title: 'Términos y Condiciones Generales de Uso',
              subtitle: 'Para pasajeros, usuarios y visitantes de la plataforma',
              icon: Icons.gavel_rounded,
            ),
            SizedBox(height: 16),
            LegalSummaryBox(
              title: 'Aceptación electrónica',
              body:
                  'Al crear una cuenta, solicitar un viaje, marcar la casilla de aceptación o utilizar la plataforma, la persona declara haber leído y aceptado estos Términos y la Política de Privacidad vigente.',
            ),
            SizedBox(height: 8),

            LegalSection(1, 'Identificación, objeto y alcance'),
            LegalParagraph(
                'Estos Términos regulan el acceso y uso de la aplicación móvil, plataforma digital, sitio web y servicios asociados administrados por EligeDriver SpA.'),
            LegalParagraph(
                'EligeDriver administra una plataforma tecnológica que facilita y coordina el contacto entre pasajeros y conductores disponibles para solicitar, ofrecer, aceptar y gestionar servicios de transporte remunerado de pasajeros en Temuco y en las demás zonas habilitadas. La prestación de los servicios se sujetará a la legislación chilena, a las autorizaciones sectoriales y a las condiciones vigentes de la plataforma.'),
            LegalParagraph(
                'EligeDriver no conduce materialmente los vehículos ni reemplaza al conductor en la ejecución del traslado. Cada conductor es responsable de su conducción, conducta, vehículo, documentación y cumplimiento de las normas aplicables; cada pasajero es responsable de la veracidad de la información que entrega, de su conducta y del pago aceptado.'),
            LegalParagraph(
                'La delimitación anterior no excluye ni limita las obligaciones y responsabilidades que legalmente correspondan a EligeDriver SpA como proveedor, empresa de plataforma digital o empresa de aplicación de transportes. Las condiciones específicas aplicables a los conductores se contienen en un documento separado.'),

            LegalSection(2, 'Requisitos para utilizar la plataforma'),
            LegalParagraph(
                'Para crear una cuenta, la persona debe tener al menos 18 años, capacidad legal para contratar, proporcionar información verdadera y mantener actualizados sus antecedentes.'),
            LegalParagraph(
                'La cuenta es personal e intransferible. Está prohibido crear cuentas falsas, suplantar a terceros, compartir credenciales, utilizar la plataforma con fines ilícitos o interferir con su funcionamiento.'),
            LegalParagraph(
                'Los menores de edad no pueden crear una cuenta propia. Su traslado deberá ser solicitado y supervisado por una persona adulta responsable, conforme a la normativa y condiciones de seguridad aplicables.'),

            LegalSection(3, 'Registro, autenticación y seguridad de la cuenta'),
            LegalParagraph(
                'EligeDriver podrá solicitar datos de identidad, contacto, fotografía, método de pago y otros antecedentes necesarios para crear la cuenta, autenticar accesos, prevenir fraudes y cumplir obligaciones legales.'),
            LegalParagraph(
                'La persona usuaria debe proteger su contraseña, códigos de verificación y dispositivo. Cualquier uso realizado desde la cuenta se presumirá autorizado mientras no se informe oportunamente un acceso no reconocido.'),
            LegalParagraph(
                'EligeDriver podrá solicitar una nueva verificación cuando detecte señales de riesgo, cambios relevantes, documentos vencidos o un requerimiento válido de autoridad.'),

            LegalSection(4, 'Solicitud, propuesta y confirmación de viajes'),
            LegalParagraph(
                'El pasajero debe indicar correctamente el punto de recogida, destino, cantidad de pasajeros e instrucciones relevantes. La aplicación podrá mostrar un precio sugerido o permitir que el pasajero proponga un valor.'),
            LegalParagraph(
                'Los conductores podrán aceptar, rechazar o formular una contrapropuesta cuando la función esté habilitada. El viaje queda confirmado cuando ambas partes aceptan las condiciones mostradas en la aplicación.'),
            LegalParagraph(
                'Antes del inicio del viaje, la aplicación mostrará la información disponible y legalmente exigible del conductor y del vehículo, como nombre o identificador, fotografía, placa patente, marca, modelo, calificación y medio de pago.'),
            LegalParagraph(
                'Los tiempos de llegada, duración y recorrido son estimaciones y pueden variar por tránsito, clima, cortes de calles, ubicación GPS, eventos o hechos ajenos al control razonable de EligeDriver.'),

            LegalSection(5, 'Tarifa, peajes y modificaciones del recorrido'),
            LegalParagraph(
                'La tarifa o valor aceptado se informará antes de iniciar el viaje. El conductor no podrá exigir pagos adicionales que no hayan sido previamente informados y aceptados.'),
            LegalParagraph(
                'La tarifa podrá ajustarse cuando el pasajero cambie el destino, agregue una parada o solicite una modificación relevante, o cuando un desvío obligatorio o imprevisto altere sustancialmente el recorrido. El cambio deberá informarse por la aplicación o ser aceptado por las partes.'),
            LegalParagraph(
                'Cuando el recorrido incluya peajes u otros cobros externos, su tratamiento será informado antes de confirmar o durante la modificación del viaje.'),

            LegalSection(6, 'Medios de pago y comprobantes'),
            LegalParagraph(
                'Los medios de pago disponibles serán los que la aplicación muestre al confirmar el viaje y podrán incluir efectivo, transferencia, tarjetas, saldo digital u otros medios habilitados.'),
            LegalParagraph(
                'El pasajero debe mantener fondos suficientes y pagar el valor aceptado. Si el pago es procesado por un proveedor externo, también podrán aplicarse sus condiciones de seguridad y operación, sin perjuicio de los derechos irrenunciables del consumidor.'),
            LegalParagraph(
                'EligeDriver podrá emitir o facilitar comprobantes electrónicos, registros de viaje, ajustes, devoluciones o liquidaciones cuando corresponda.'),

            LegalSection(7, 'Cancelaciones, espera y ausencia'),
            LegalParagraph(
                'El pasajero y el conductor pueden cancelar antes del inicio del viaje. Cualquier cargo por cancelación o espera deberá informarse claramente antes de resultar aplicable.'),
            LegalParagraph(
                'Podrá existir un cargo razonable si el conductor ya se encuentra en camino, llegó al punto acordado o el pasajero no se presenta dentro del tiempo informado. No procederá cuando la cancelación se deba a información incorrecta del conductor o vehículo, una situación de seguridad, una falla relevante de la plataforma o una causa atribuible al conductor.'),
            LegalParagraph(
                'Las cancelaciones reiteradas, fraudulentas o abusivas podrán originar advertencias o restricciones, previa revisión del caso.'),

            LegalSection(8, 'Obligaciones del pasajero'),
            LegalBullets([
              'Tratar con respeto al conductor y a terceros.',
              'Usar cinturón de seguridad y cumplir las normas aplicables.',
              'No distraer al conductor ni solicitar infracciones de tránsito.',
              'No fumar, consumir drogas, portar armas ni trasladar elementos peligrosos o ilícitos.',
              'No causar daños, suciedad extraordinaria ni deterioro intencional al vehículo.',
              'No exceder la capacidad legal del vehículo.',
              'Informar previamente equipaje voluminoso, animales, necesidades de accesibilidad o condiciones especiales, cuando sea posible.',
              'Verificar que el conductor y la patente coincidan con la información mostrada.',
              'Pagar la tarifa aceptada y los cargos previamente informados.',
            ]),

            LegalSubsection('8.1. Alcance de la intermediación y conductas externas'),
            LegalParagraph(
                'EligeDriver proporciona herramientas de registro, coordinación, información, soporte, pagos cuando estén habilitados, prevención de fraude y gestión de incidentes. La verificación de antecedentes y documentos reduce riesgos, pero no constituye una garantía absoluta sobre la conducta futura de una persona ni sobre la inexistencia de hechos ilícitos.'),
            LegalParagraph(
                'Los acuerdos, cambios de tarifa, pagos, desvíos, servicios o comunicaciones realizados fuera de la aplicación, sin registro verificable o después de finalizar el viaje pueden quedar fuera de las funciones de soporte de EligeDriver. Ello no afecta los derechos que la ley reconozca a las personas ni las responsabilidades que sean legalmente exigibles.'),
            LegalParagraph(
                'EligeDriver no actúa como policía, tribunal, aseguradora, servicio médico, custodio de bienes ni representante legal de pasajeros o conductores. La asistencia prestada por soporte no constituye admisión de responsabilidad, reconocimiento de hechos ni garantía de compensación.'),

            LegalSubsection('8.2. Denuncias falsas, fraude y abuso de la plataforma'),
            LegalParagraph(
                'Toda denuncia, solicitud de devolución, reclamo o antecedente debe presentarse de buena fe y con información verdadera. Se prohíbe fabricar pruebas, manipular registros, simular incidentes, realizar contracargos fraudulentos, amenazar, extorsionar, coludirse o utilizar el soporte para obtener beneficios indebidos.'),
            LegalParagraph(
                'Cuando existan indicios razonables de fraude o abuso, EligeDriver podrá verificar identidad, solicitar antecedentes, preservar registros, suspender preventivamente funciones, rechazar beneficios improcedentes, recuperar montos indebidamente obtenidos por las vías legales y remitir antecedentes a autoridades competentes. No se sancionará a quien formule de buena fe un reclamo que finalmente no pueda comprobarse.'),

            LegalSection(9, 'Daños, limpieza y objetos olvidados'),
            LegalParagraph(
                'Cuando existan antecedentes suficientes de daños o suciedad extraordinaria atribuibles al pasajero, EligeDriver podrá solicitar fotografías, presupuestos y descargos, y aplicar un cobro razonable previamente informado. La persona podrá reclamar y aportar antecedentes.'),
            LegalParagraph(
                'El pasajero debe revisar sus pertenencias al finalizar. EligeDriver podrá facilitar la comunicación para coordinar la devolución de objetos encontrados, pero no actúa como depositario ni garantiza su recuperación.'),

            LegalSection(10, 'Seguridad, seguimiento y emergencias'),
            LegalParagraph(
                'La aplicación podrá permitir compartir o monitorear el viaje, contactar soporte, reportar incidentes y acceder a funciones de seguridad. Estas herramientas dependen de la conexión, los permisos del dispositivo y la disponibilidad técnica.'),
            LegalParagraph(
                'Ante un peligro inmediato, accidente, agresión o emergencia médica, la persona debe contactar directamente a los servicios públicos de emergencia. EligeDriver no reemplaza a dichos servicios.'),
            LegalParagraph(
                'No se debe abordar un vehículo si la identidad del conductor o la patente no coinciden con la información mostrada en la aplicación.'),

            LegalSection(11, 'Evaluaciones y contenido de usuarios'),
            LegalParagraph(
                'Pasajeros y conductores podrán evaluarse después del viaje. Las evaluaciones deben relacionarse con el servicio y no pueden contener amenazas, insultos, discriminación, datos personales de terceros, contenido ilícito ni acusaciones deliberadamente falsas.'),
            LegalParagraph(
                'EligeDriver podrá moderar o retirar contenido que infrinja estas reglas. Las evaluaciones podrán utilizarse para seguridad, calidad, prevención de fraude y revisión de cuentas. Una calificación aislada no originará por sí sola una expulsión automática.'),

            LegalSection(12, 'Promociones y beneficios'),
            LegalParagraph(
                'Cada promoción indicará su vigencia, personas beneficiarias, zona, condiciones, restricciones y responsable del beneficio. Los códigos son personales, no canjeables por dinero y pueden anularse en caso de fraude, duplicidad de cuentas o manipulación.'),
            LegalCallout(
              title: 'Promoción para conductores: 0% de comisión por seis meses',
              body:
                  'Podrán acceder los conductores cuyo registro sea completado, aprobado y activado entre el 1 de septiembre de 2026 y el 1 de febrero de 2027, ambas fechas inclusive. El beneficio dura seis meses corridos desde la activación de cada cuenta. Al finalizar, se aplicará la modalidad elegida entre las opciones vigentes e informadas en la aplicación.',
            ),

            LegalSection(13, 'Suspensión, restricción y cierre de cuentas'),
            LegalParagraph(
                'EligeDriver podrá advertir, restringir, suspender preventivamente o cerrar una cuenta por fraude, suplantación, agresiones, amenazas, discriminación, cobros no autorizados, uso ilícito, daños, riesgos graves de seguridad, incumplimientos relevantes o requerimiento de autoridad competente.'),
            LegalParagraph(
                'Salvo que exista riesgo grave o urgencia, se informará el motivo y se permitirá presentar antecedentes. Las medidas preventivas podrán mantenerse mientras se revisa el incidente.'),
            LegalParagraph(
                'La persona puede solicitar el cierre de su cuenta desde la aplicación o escribiendo a eligedrive@gmail.com. El cierre no elimina de inmediato los datos que deban conservarse por obligaciones legales, reclamos, fraude, seguridad o defensa de derechos.'),

            LegalSection(14, 'Disponibilidad y funcionamiento tecnológico'),
            LegalParagraph(
                'EligeDriver procurará mantener la plataforma disponible y segura, pero pueden existir interrupciones por mantenimiento, conexión a internet, GPS, servicios de mapas, sistemas de pago, fallas del dispositivo, fuerza mayor o proveedores externos.'),
            LegalParagraph(
                'En la medida permitida por la ley, EligeDriver no responde por hechos exclusivamente atribuibles a pasajeros, conductores o terceros; acuerdos realizados fuera de la aplicación; información falsa entregada por una persona; fallas del dispositivo o de la conexión del usuario; ni eventos de fuerza mayor. Esta regla no se aplica cuando el daño derive de una obligación legal incumplida, negligencia, falla de seguridad o conducta imputable a EligeDriver.'),
            LegalParagraph(
                'Ninguna disposición de estos Términos constituye una exención absoluta de responsabilidad, una inversión de la carga de la prueba en perjuicio del consumidor ni una renuncia a derechos irrenunciables.'),

            LegalSection(15, 'Reclamos, devoluciones y soporte'),
            LegalParagraph(
                'Las consultas, reclamos, solicitudes de devolución y reportes pueden presentarse desde la sección Ayuda y soporte o por correo a eligedrive@gmail.com. Se recomienda indicar el identificador del viaje, fecha, monto y antecedentes disponibles.'),
            LegalParagraph(
                'EligeDriver revisará cada caso y podrá solicitar información adicional. Las personas consumidoras conservan su derecho a acudir al Servicio Nacional del Consumidor y a los tribunales competentes.'),

            LegalSection(16, 'Privacidad y datos personales'),
            LegalParagraph(
                'El tratamiento de datos se rige por la Política de Privacidad de EligeDriver, disponible permanentemente dentro de la aplicación. La plataforma puede tratar datos de identidad, contacto, ubicación, viajes, pagos, dispositivo, soporte y seguridad para operar el servicio y cumplir la ley.'),
            LegalParagraph(
                'EligeDriver no vende datos personales y aplicará medidas razonables de seguridad. Las solicitudes de acceso, rectificación, eliminación, oposición y demás derechos aplicables pueden enviarse a eligedrive@gmail.com.'),

            LegalSection(17, 'Propiedad intelectual y uso permitido'),
            LegalParagraph(
                'La aplicación, nombre, logotipo, diseños, software, bases de datos y contenidos de EligeDriver pertenecen a EligeDriver SpA o se utilizan con autorización. Está prohibido copiar, modificar, descompilar, explotar, interferir o suplantar la plataforma, salvo autorización legal o escrita.'),

            LegalSection(18, 'Modificaciones'),
            LegalParagraph(
                'EligeDriver podrá actualizar estos Términos por cambios legales, regulatorios, tecnológicos, de seguridad o comerciales. Los cambios relevantes se comunicarán mediante la aplicación, correo electrónico u otro canal registrado y no se aplicarán retroactivamente a viajes ya confirmados.'),
            LegalParagraph(
                'Cuando una modificación afecte de manera significativa derechos u obligaciones, se solicitará una nueva aceptación antes de que sea aplicable.'),

            LegalSection(19, 'Legislación y solución de controversias'),
            LegalParagraph(
                'Estos Términos se rigen por las leyes de la República de Chile. Son especialmente aplicables las normas de protección de consumidores, datos personales, trabajo mediante plataformas digitales y transporte remunerado de pasajeros, en la medida que correspondan y se encuentren vigentes.'),
            LegalParagraph(
                'Las personas podrán ejercer sus derechos ante las autoridades y tribunales competentes. Ninguna cláusula se interpretará como renuncia anticipada a derechos irrenunciables.'),

            LegalSection(20, 'Contacto oficial'),
            LegalParagraph('EligeDriver SpA recibe consultas, reclamos y solicitudes en:'),
            LegalBullets([
              'Correo: eligedrive@gmail.com',
              'Domicilio: General Aldunate N° 620, departamento/local 704, comuna de Temuco, Región de La Araucanía, Chile.',
              'Sección de la aplicación: Ayuda y soporte.',
            ]),

            SizedBox(height: 20),
            LegalFooter(
                'Normativa de referencia: Ley N° 19.496; Ley N° 19.628 y sus modificaciones; Ley N° 21.431; Ley N° 21.553 cuando resulte exigible conforme a su entrada en vigencia y reglamentación; y demás normas aplicables.\n\nEligeDriver SpA · RUT 78.467.243-3 · Versión 1.2'),
          ],
        ),
      ),
    );
  }
}
