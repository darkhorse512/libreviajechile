import 'package:flutter/material.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_top_controls.dart';
import 'legal_widgets.dart';

/// Condiciones de Incorporación y Uso para Conductores de EligeDriver.
///
/// Documento específico que complementa los Términos Generales y la Política de
/// Privacidad. El cuerpo legal se mantiene en español; solo los rótulos de
/// navegación se traducen.
class DriverTermsScreen extends StatelessWidget {
  const DriverTermsScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DriverTermsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Condiciones para conductores')),
        actions: const [AppTopControls(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
          children: const [
            LegalHeader(
              title: 'Condiciones de Incorporación y Uso para Conductores',
              subtitle:
                  'Documento específico para registro, conexión y prestación de servicios',
              icon: Icons.directions_car_filled_rounded,
            ),
            SizedBox(height: 16),
            LegalSummaryBox(
              title: 'Importante',
              body:
                  'Estas condiciones complementan los Términos Generales y la Política de Privacidad. No reemplazan el contrato individual que deba celebrarse conforme a la legislación laboral y de plataformas digitales aplicable.',
              icon: Icons.info_rounded,
            ),
            SizedBox(height: 8),

            LegalSection(1, 'Alcance, rol de la plataforma y aceptación'),
            LegalParagraph(
                'Estas condiciones regulan el registro, verificación, conexión, aceptación de viajes, cobros, promociones, seguridad y uso de la plataforma por parte de conductores.'),
            LegalParagraph(
                'EligeDriver proporciona una plataforma de coordinación, información, soporte y gestión tecnológica. El conductor ejecuta personalmente el traslado y responde por sus actos, conducción, vehículo, documentación, seguros exigibles, infracciones, multas, cobros y cumplimiento de la normativa. Esta distribución no excluye las obligaciones legales que correspondan a EligeDriver.'),
            LegalParagraph(
                'El conductor sólo podrá ser habilitado después de aceptar expresamente la versión vigente de estas condiciones y de los demás documentos aplicables. Cualquier modificación relevante será informada y requerirá aceptación cuando la ley lo exija.'),

            LegalSection(2, 'Requisitos y documentación'),
            LegalParagraph(
                'El conductor debe cumplir los requisitos legales y reglamentarios vigentes para prestar transporte remunerado de pasajeros y mantener actualizada la información entregada.'),
            LegalBullets([
              'Ser mayor de edad y tener capacidad legal para contratar.',
              'Acreditar identidad y mantener una cuenta personal e intransferible.',
              'Contar con licencia de conducir y habilitaciones exigidas por la normativa vigente.',
              'Presentar los certificados y antecedentes que resulten legalmente exigibles.',
              'Registrar un vehículo autorizado, con documentación vigente, revisión técnica, permiso de circulación, seguros y demás requisitos aplicables.',
              'Entregar información tributaria y de pago necesaria para liquidaciones y cumplimiento legal.',
              'Actualizar los documentos antes de su vencimiento.',
            ]),
            LegalParagraph(
                'EligeDriver podrá rechazar, pausar o suspender la activación mientras los antecedentes estén incompletos, vencidos, inconsistentes o pendientes de verificación.'),

            LegalSection(3, 'Cuenta y uso personal'),
            LegalParagraph(
                'La cuenta sólo puede ser utilizada por el conductor verificado y con el vehículo registrado. Está prohibido prestar, vender, arrendar o compartir la cuenta, suplantar identidades o permitir que otra persona realice viajes utilizando sus credenciales.'),
            LegalParagraph(
                'El conductor debe informar inmediatamente accesos no reconocidos, pérdida del dispositivo o uso indebido de la cuenta.'),

            LegalSection(4, 'Conexión, disponibilidad y aceptación de viajes'),
            LegalParagraph(
                'El conductor decide cuándo conectarse, desconectarse y qué solicitudes aceptar, salvo que exista un régimen contractual distinto expresamente acordado y permitido por la ley.'),
            LegalParagraph(
                'Las ofertas podrán incluir origen aproximado, destino, distancia, tiempo estimado, tarifa propuesta, medio de pago y otros antecedentes relevantes. El conductor puede aceptar, rechazar o realizar una contrapropuesta cuando la función esté habilitada.'),
            LegalParagraph(
                'La aceptación debe realizarse con el vehículo detenido y en condiciones seguras. Una vez confirmado el viaje, el conductor debe cumplirlo responsablemente o cancelar por una causa justificada.'),

            LegalSection(5, 'Obligaciones durante el servicio'),
            LegalBullets([
              'Conducir personalmente el vehículo registrado y mantenerlo limpio, seguro y en buen estado.',
              'Respetar las normas de tránsito y utilizar el dispositivo únicamente de forma permitida y segura.',
              'No conducir bajo efectos de alcohol, drogas o sustancias incompatibles con la conducción.',
              'Tratar respetuosamente a pasajeros y terceros y no discriminar por ninguna causa protegida por la ley.',
              'Verificar razonablemente la identidad o solicitud antes de iniciar el viaje.',
              'Seguir una ruta razonable, salvo instrucciones del pasajero o desvíos necesarios.',
              'No exigir pagos adicionales no informados ni alterar fraudulentamente tiempo, ruta o tarifa.',
              'Respetar la privacidad y no utilizar datos del pasajero para contacto posterior no autorizado.',
              'Reportar accidentes, agresiones, amenazas, fraude o incidentes graves.',
              'Prestar colaboración razonable en la devolución de objetos encontrados.',
            ]),

            LegalSection(6, 'Tarifas, pagos y liquidaciones'),
            LegalParagraph(
                'La tarifa será la aceptada en la aplicación, incluyendo los ajustes informados por cambios de destino, paradas o desvíos relevantes. El conductor no podrá cobrar valores distintos por fuera de la plataforma, salvo conceptos previamente informados y permitidos.'),
            LegalParagraph(
                'Los pagos y liquidaciones se realizarán según el medio habilitado, los registros de la plataforma y los plazos informados. Podrán descontarse comisiones, pases, devoluciones, retenciones, impuestos, cargos de proveedores externos o ajustes debidamente informados y legalmente procedentes.'),
            LegalParagraph(
                'El conductor debe revisar sus liquidaciones y reportar discrepancias por Ayuda y soporte o mediante eligedrive@gmail.com.'),

            LegalSection(7, 'Comisión estándar y pases'),
            LegalParagraph(
                'A contar del término de cualquier promoción aplicable, EligeDriver podrá ofrecer las siguientes modalidades iniciales, sujetas a disponibilidad y aceptación en la aplicación:'),
            LegalBullets([
              'Comisión estándar: 3% por viaje.',
              'Pase diario: \$1.500.',
              'Pase semanal: \$7.000.',
              'Pase mensual: \$25.000.',
            ]),
            LegalParagraph(
                'Antes de contratar una modalidad, la aplicación informará precio, duración, alcance, renovación, restricciones y forma de cancelación. No habrá renovación automática salvo autorización previa. Los cambios futuros no se aplicarán retroactivamente y se informarán antes de su aceptación.'),

            LegalSection(8, 'Promoción 0% de comisión por seis meses'),
            LegalSubsection('Período de incorporación'),
            LegalParagraph(
                'Podrán acceder los conductores cuyo registro sea completado, aprobado y activado entre el 1 de septiembre de 2026 y el 1 de febrero de 2027, ambas fechas inclusive.'),
            LegalBullets([
              'El beneficio dura seis meses corridos desde la fecha de activación individual.',
              'Durante el beneficio no se cobrará comisión por los viajes ni se exigirá contratar un pase para mantener el 0%.',
              'No se incluyen impuestos, retenciones, cargos bancarios ni costos de proveedores externos que legalmente correspondan.',
              'El beneficio es personal, intransferible y puede perderse por fraude, suplantación o incumplimiento grave.',
              'Al finalizar, el conductor podrá elegir entre las modalidades vigentes. Si no elige otra opción, podrá aplicarse la comisión estándar informada, previa aceptación cuando corresponda.',
            ]),

            LegalSection(9, 'Evaluaciones y transparencia'),
            LegalParagraph(
                'El conductor podrá conocer las reglas generales que influyen en la asignación de solicitudes, tarifas, incentivos, evaluaciones y medidas de cuenta, con el nivel de detalle permitido por la seguridad y prevención de fraude.'),
            LegalParagraph(
                'Las evaluaciones deben referirse al servicio. El conductor puede solicitar revisión de comentarios falsos, discriminatorios, amenazantes o manifiestamente ajenos al viaje.'),

            LegalSubsection('9.1. Veracidad, fraude y colaboración'),
            LegalParagraph(
                'El conductor debe entregar información verdadera y conservar antecedentes de los viajes. Está prohibido manipular ubicación, tarifas, cuentas, identidad, evaluaciones, viajes, incidentes o documentos; coordinar reclamos ficticios; cobrar fuera de lo aceptado; o utilizar datos de pasajeros para fines ajenos al servicio.'),
            LegalParagraph(
                'El conductor deberá colaborar de buena fe en investigaciones de seguridad, reclamos y requerimientos de autoridad. EligeDriver podrá preservar registros, suspender preventivamente funciones, rechazar beneficios indebidos y remitir antecedentes a las autoridades cuando existan indicios razonables de fraude o delito.'),

            LegalSection(10, 'Seguridad y emergencias'),
            LegalParagraph(
                'El conductor debe priorizar la seguridad. Ante peligro inmediato, accidente grave, agresión o urgencia médica, debe contactar directamente a los servicios públicos de emergencia y luego reportar el incidente a EligeDriver.'),
            LegalParagraph(
                'EligeDriver podrá suspender preventivamente una cuenta mientras investiga un riesgo grave, preserva registros o coopera con una autoridad, aseguradora o entidad competente.'),

            LegalSection(11, 'Suspensión, bloqueo y eliminación'),
            LegalParagraph(
                'EligeDriver podrá aplicar advertencias, restricciones, suspensión preventiva o cierre por documentos vencidos, información falsa, suplantación, uso de vehículo distinto, conducción peligrosa, alcohol o drogas, cobros indebidos, fraude, agresión, acoso, discriminación, incumplimiento grave o requerimiento de autoridad.'),
            LegalParagraph(
                'Salvo riesgo grave o urgencia, se informará la causa y se permitirá presentar antecedentes. Una calificación aislada no provocará por sí sola la eliminación automática de la cuenta.'),

            LegalSection(12, 'Apelación y revisión humana'),
            LegalParagraph(
                'El conductor puede apelar mediante eligedrive@gmail.com, indicando la cuenta, fecha de la medida, razones de la solicitud y antecedentes disponibles.'),
            LegalParagraph(
                'EligeDriver revisará la apelación dentro de un plazo razonable según la complejidad y podrá mantener medidas preventivas mientras exista un riesgo de seguridad. Cuando corresponda, el conductor podrá solicitar revisión por una persona de una decisión automatizada relevante.'),

            LegalSection(13, 'Relación contractual, tributaria y previsional'),
            LegalParagraph(
                'La relación del conductor con EligeDriver se determinará por la forma real de prestación de servicios y la legislación aplicable. El conductor podrá ser dependiente o independiente según concurran o no los elementos legales correspondientes.'),
            LegalParagraph(
                'Cuando corresponda, las partes celebrarán un contrato escrito que establecerá derechos, obligaciones, forma de pago, acceso a la plataforma, tratamiento de datos, jornada o conexión, terminación y demás materias exigidas por la ley.'),
            LegalParagraph(
                'El conductor deberá cumplir sus obligaciones tributarias y previsionales en la medida que le correspondan, sin perjuicio de las obligaciones legales de EligeDriver.'),

            LegalSection(14, 'Datos personales y geolocalización'),
            LegalParagraph(
                'EligeDriver tratará datos de identidad, documentos, vehículo, ubicación, viajes, pagos, evaluaciones, dispositivo y soporte para administrar la plataforma, cumplir la ley, prevenir fraude y proteger a pasajeros y conductores.'),
            LegalParagraph(
                'Mientras el conductor esté conectado o realizando un viaje, la aplicación podrá utilizar ubicación en segundo plano si cuenta con el permiso correspondiente. El detalle se encuentra en la Política de Privacidad.'),

            LegalSection(15, 'Terminación y cierre de cuenta'),
            LegalParagraph(
                'El conductor puede solicitar el cierre desde la aplicación o por correo. Debe completar viajes activos, regularizar saldos y atender incidentes pendientes. El cierre no elimina de inmediato información que deba conservarse por ley o para resolver reclamos y ejercer derechos.'),

            LegalSection(16, 'Contacto'),
            LegalBullets([
              'Correo para soporte, reclamos y apelaciones: eligedrive@gmail.com',
              'Domicilio: General Aldunate N° 620, departamento/local 704, comuna de Temuco, Región de La Araucanía, Chile.',
              'Sección de la aplicación: Ayuda y soporte.',
            ]),

            SizedBox(height: 20),
            LegalFooter(
                'Normativa de referencia: Código del Trabajo y Ley N° 21.431; Ley N° 21.553 cuando resulte exigible conforme a su entrada en vigencia y reglamentación; Ley N° 19.628 y sus modificaciones; Ley N° 19.496; y demás normas aplicables.\n\nEligeDriver SpA · RUT 78.467.243-3 · Versión 1.2'),
          ],
        ),
      ),
    );
  }
}
