import 'package:flutter/material.dart';

import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/app_top_controls.dart';
import 'legal_widgets.dart';

/// Política de Privacidad y Tratamiento de Datos de EligeDriver.
///
/// El cuerpo legal se mantiene en español (idioma de origen, legislación
/// chilena); solo los rótulos de navegación se traducen.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PrivacyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('Política de Privacidad')),
        actions: const [AppTopControls(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
          children: const [
            LegalHeader(
              title: 'Política de Privacidad y Tratamiento de Datos',
              subtitle:
                  'Aplicable a pasajeros, conductores, visitantes y personas de contacto',
              icon: Icons.privacy_tip_rounded,
            ),
            SizedBox(height: 16),
            LegalSummaryBox(
              title: 'Resumen',
              body:
                  'EligeDriver utiliza datos personales para crear cuentas, coordinar viajes, procesar pagos, proteger a las personas, prevenir fraude y cumplir obligaciones legales. EligeDriver no vende datos personales.',
              icon: Icons.lock_rounded,
            ),
            SizedBox(height: 8),

            LegalSection(1, 'Responsable del tratamiento'),
            LegalParagraph(
                'El responsable del tratamiento es EligeDriver SpA, RUT 78.467.243-3, con domicilio en General Aldunate N° 620, departamento/local 704, comuna de Temuco, Región de La Araucanía, Chile. Las consultas y solicitudes sobre privacidad se reciben en eligedrive@gmail.com.'),

            LegalSection(2, 'Alcance'),
            LegalParagraph(
                'Esta Política se aplica a la aplicación móvil, sitio web, centro de ayuda, comunicaciones y demás servicios vinculados a EligeDriver. También se aplica a datos tratados durante el registro, conexión, solicitud, aceptación, ejecución y finalización de viajes.'),
            LegalParagraph(
                'La Política se interpreta conforme a la Ley N° 19.628 y sus modificaciones, incluida la Ley N° 21.719 desde su entrada en vigencia, además de las normas sectoriales aplicables.'),

            LegalSection(3, 'Datos que podemos tratar'),
            LegalBullets([
              'Identificación y contacto: nombre, documento de identidad, fecha de nacimiento, correo electrónico, número de contacto, fotografía e identificadores de cuenta.',
              'Datos del conductor: licencia, documentos habilitantes, antecedentes exigidos por ley, situación de verificación y datos necesarios para pagos o liquidaciones.',
              'Datos del vehículo: patente, marca, modelo, año, documentación, titularidad o autorización de uso.',
              'Ubicación: posición aproximada o precisa, rutas, puntos de recogida y destino, según permisos y estado del servicio.',
              'Viajes: solicitudes, ofertas, contrapropuestas, aceptación, horarios, distancia, tarifa, cancelaciones, incidencias y evaluaciones.',
              'Pagos: medio seleccionado, montos, comisiones, pases, devoluciones y referencias de transacción. EligeDriver procurará no almacenar datos completos de tarjetas cuando sean procesados por un proveedor especializado.',
              'Dispositivo y uso: dirección IP, sistema operativo, identificadores, versión de la aplicación, idioma, registros técnicos, fallas y eventos de seguridad.',
              'Soporte y seguridad: mensajes, fotografías, denuncias, reclamos, apelaciones y evidencia de incidentes.',
              'Contenido aportado: evaluaciones, comentarios y archivos enviados voluntariamente.',
            ]),

            LegalSection(4, 'Origen de los datos'),
            LegalParagraph(
                'Los datos pueden provenir directamente de la persona, de su dispositivo, del otro participante de un viaje, de proveedores de identidad, mapas, pagos o seguridad, de fuentes públicas o autorizadas y de autoridades cuando corresponda.'),
            LegalParagraph(
                'EligeDriver procurará recolectar únicamente datos necesarios, adecuados y pertinentes para las finalidades informadas.'),

            LegalSection(5, 'Finalidades'),
            LegalBullets([
              'Crear, autenticar, verificar y administrar cuentas.',
              'Coordinar solicitudes, ofertas, viajes, rutas y comunicaciones entre pasajero y conductor.',
              'Mostrar la información necesaria del conductor, vehículo, pasajero y servicio conforme a la ley.',
              'Calcular, informar y procesar tarifas, pagos, promociones, comisiones, pases, reembolsos y liquidaciones.',
              'Prevenir fraude, suplantación, violencia, acoso, discriminación, robos, uso ilícito y riesgos de seguridad.',
              'Permitir seguimiento, compartir viaje, soporte y reporte de incidentes.',
              'Atender consultas, reclamos, apelaciones y solicitudes de derechos.',
              'Evaluar calidad, diagnosticar fallas, mejorar funciones y generar estadísticas agregadas o anonimizadas.',
              'Cumplir obligaciones legales, tributarias, laborales, previsionales, regulatorias, judiciales y de transporte.',
              'Enviar comunicaciones operativas y, cuando corresponda, promociones autorizadas.',
            ]),

            LegalSection(6, 'Bases que permiten el tratamiento'),
            LegalParagraph(
                'EligeDriver tratará datos cuando sea necesario para ejecutar los Términos, coordinar un viaje o administrar la relación con el conductor; cuando exista consentimiento; cuando lo autorice o exija la ley; para formular, ejercer o defender derechos; y, cuando proceda, sobre la base de un interés legítimo debidamente ponderado.'),
            LegalParagraph(
                'Los datos sensibles o biométricos, si una función llegara a requerirlos, se tratarán únicamente con consentimiento expreso o con otra habilitación legal y medidas reforzadas de seguridad.'),

            LegalSection(7, 'Geolocalización'),
            LegalParagraph(
                'La ubicación es necesaria para mostrar conductores cercanos, calcular rutas y tarifas, coordinar recogidas, monitorear el viaje, prevenir fraude y responder a incidentes.'),
            LegalParagraph(
                'La aplicación podrá recopilar ubicación mientras se utiliza y, durante un viaje o conexión activa del conductor, en segundo plano si la persona otorgó el permiso correspondiente. Al desactivar la ubicación, algunas funciones dejarán de operar.'),

            LegalSection(8, 'Información compartida entre usuarios'),
            LegalParagraph(
                'Antes y durante un viaje, el pasajero podrá recibir nombre o identificador, fotografía, calificación, patente y datos del vehículo del conductor. El conductor podrá recibir el nombre o identificador del pasajero, origen, destino, instrucciones y medio de pago, según sea necesario.'),
            LegalParagraph(
                'Ninguna persona puede utilizar los datos recibidos para fines ajenos al viaje, marketing, hostigamiento o contacto posterior no autorizado.'),

            LegalSection(9, 'Proveedores y destinatarios'),
            LegalParagraph(
                'EligeDriver podrá contratar proveedores que traten datos bajo instrucciones y medidas de seguridad adecuadas. EligeDriver no vende datos personales.'),
            LegalBullets([
              'Servicios de nube, alojamiento, bases de datos, respaldo y ciberseguridad.',
              'Mapas, geocodificación, navegación y cálculo de rutas.',
              'Procesadores de pagos, bancos, billeteras y servicios antifraude.',
              'Mensajería, correo electrónico y notificaciones.',
              'Validación de identidad, documentos, antecedentes y vehículo, cuando sea legal.',
              'Aseguradoras, liquidadores, asistencia y servicios vinculados a incidentes.',
              'Asesores profesionales sujetos a confidencialidad.',
              'Autoridades, tribunales y organismos públicos cuando exista obligación, solicitud válida o base legal.',
            ]),

            LegalSection(10, 'Transferencias internacionales'),
            LegalParagraph(
                'Algunos proveedores tecnológicos pueden almacenar o procesar información fuera de Chile. EligeDriver procurará utilizar proveedores que ofrezcan garantías contractuales, organizativas y técnicas adecuadas y cumplirá las reglas legales aplicables a las transferencias internacionales.'),

            LegalSection(11, 'Conservación'),
            LegalParagraph(
                'Los datos se conservarán durante el tiempo necesario para mantener la cuenta, ejecutar viajes, atender reclamos, prevenir fraude, cumplir obligaciones y ejercer o defender derechos.'),
            LegalParagraph(
                'Después del cierre de la cuenta, determinados registros podrán mantenerse durante los plazos legales tributarios, laborales, regulatorios, de transporte, seguridad o prescripción. Cuando ya no sean necesarios, se eliminarán, bloquearán o anonimizarán de forma segura.'),

            LegalSection(12, 'Decisiones automatizadas, perfiles y evaluaciones'),
            LegalParagraph(
                'EligeDriver puede utilizar sistemas automatizados para detectar fraude, ordenar solicitudes, calcular rutas o precios, mostrar disponibilidad y apoyar evaluaciones de seguridad. Los criterios pueden incluir ubicación, disponibilidad, compatibilidad, cumplimiento documental y señales de riesgo.'),
            LegalParagraph(
                'Cuando una decisión automatizada produzca un efecto significativo sobre una cuenta, la persona podrá presentar antecedentes y solicitar revisión humana en los casos reconocidos por la ley.'),

            LegalSection(13, 'Seguridad de la información'),
            LegalParagraph(
                'EligeDriver aplicará medidas administrativas, técnicas y organizativas razonables, como controles de acceso, autenticación, cifrado cuando corresponda, registros de seguridad, respaldo y procedimientos de respuesta a incidentes.'),
            LegalParagraph(
                'Ningún sistema es completamente infalible. Si ocurre una vulneración que legalmente deba informarse, EligeDriver realizará las comunicaciones correspondientes a las personas y autoridades.'),

            LegalSection(14, 'Derechos de las personas'),
            LegalParagraph(
                'Las solicitudes deben enviarse a eligedrive@gmail.com, indicando el derecho ejercido y los antecedentes necesarios para verificar identidad. EligeDriver responderá dentro de los plazos legales.'),
            LegalBullets([
              'Acceso: conocer si EligeDriver trata datos y obtener información o copia.',
              'Rectificación: corregir datos inexactos, incompletos o desactualizados.',
              'Supresión o eliminación: solicitarla cuando se cumplan las causales legales.',
              'Oposición: pedir que cese un tratamiento en los casos permitidos.',
              'Bloqueo: suspender temporalmente determinadas operaciones cuando corresponda.',
              'Portabilidad: solicitar una copia estructurada y transferible cuando la ley lo reconozca y se cumplan sus requisitos.',
              'Revocación del consentimiento: retirarlo hacia el futuro cuando sea la base del tratamiento.',
              'Revisión humana: solicitarla frente a decisiones automatizadas relevantes, conforme a la ley.',
            ]),

            LegalSection(15, 'Comunicaciones comerciales'),
            LegalParagraph(
                'Las notificaciones necesarias para seguridad, cuenta, viajes, pagos o cambios contractuales son comunicaciones operativas. Los mensajes promocionales se enviarán con autorización cuando sea exigible y ofrecerán una forma simple de dejar de recibirlos.'),

            LegalSection(16, 'Niños, niñas y adolescentes'),
            LegalParagraph(
                'EligeDriver no permite que menores de 18 años creen cuentas propias. Si se detecta una cuenta creada por un menor, podrá suspenderse y eliminarse la información, salvo la que deba conservarse por seguridad o mandato legal.'),

            LegalSection(17, 'Permisos y tecnologías de la aplicación'),
            LegalParagraph(
                'La aplicación puede solicitar acceso a ubicación, cámara, fotografías, notificaciones o micrófono únicamente cuando una función lo requiera. La finalidad se informará al solicitar el permiso.'),
            LegalParagraph(
                'También pueden utilizarse tecnologías de medición o kits de desarrollo para funcionamiento, seguridad, diagnóstico y análisis, procurando limitar la información y configurar los servicios conforme a esta Política.'),

            LegalSection(18, 'Cierre de cuenta'),
            LegalParagraph(
                'La persona podrá solicitar el cierre desde la configuración, Ayuda y soporte o mediante eligedrive@gmail.com. El cierre desactiva el uso, pero no implica eliminación inmediata de datos sujetos a obligaciones legales, investigaciones, saldos, reclamos o prevención de fraude.'),

            LegalSection(19, 'Cambios a esta Política'),
            LegalParagraph(
                'EligeDriver podrá actualizar esta Política por cambios legales, tecnológicos, operativos o de seguridad. Las modificaciones relevantes se comunicarán mediante la aplicación, correo electrónico u otro canal registrado. La versión vigente permanecerá accesible de forma gratuita.'),

            LegalSection(20, 'Contacto'),
            LegalBullets([
              'Correo de privacidad: eligedrive@gmail.com',
              'Domicilio: General Aldunate N° 620, departamento/local 704, comuna de Temuco, Región de La Araucanía, Chile.',
              'Sección de la aplicación: Ayuda y soporte > Privacidad y datos personales.',
            ]),

            SizedBox(height: 20),
            LegalFooter(
                'Normativa de referencia: Ley N° 19.628 sobre protección de datos personales; Ley N° 21.719 y demás normas aplicables desde sus respectivas entradas en vigencia.\n\nEligeDriver SpA · RUT 78.467.243-3 · Versión 1.2'),
          ],
        ),
      ),
    );
  }
}
