/// Método de pago que elige el pasajero al solicitar el viaje. El conductor lo
/// ve para saber cómo cobrará. La app NO procesa el cobro: es informativo, el
/// pago ocurre entre pasajero y conductor (efectivo o transferencia/app).
enum PaymentMethod {
  efectivo('cash', 'Efectivo', 'assets/cash.jpeg'),
  pagoRut('pago_rut', 'PagoRUT', 'assets/pagorut.jpeg'),
  mercadoPago('mercado_pago', 'Mercado Pago', 'assets/mercado.jpeg'),
  bancoSantander('banco_santander', 'Banco Santander', 'assets/banco.jpeg'),
  mach('mach', 'MACH', 'assets/mach.jpeg'),
  tenpo('tenpo', 'Tenpo', 'assets/tenpo.jpeg');

  const PaymentMethod(this.value, this.label, this.asset);

  /// Valor persistido en la base de datos (columna trips.payment_method).
  final String value;

  /// Nombre visible. Solo 'Efectivo' se traduce; el resto son marcas.
  final String label;

  /// Ruta del ícono en assets.
  final String asset;

  static PaymentMethod fromString(String? value) => PaymentMethod.values
      .firstWhere((m) => m.value == value, orElse: () => PaymentMethod.efectivo);
}
