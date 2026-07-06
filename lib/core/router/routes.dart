/// Rutas con nombre de la aplicación.
abstract class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const welcome = '/welcome';
  static const roleSelection = '/registro';
  static const login = '/ingresar';
  static const registerPassenger = '/registro/pasajero';
  static const registerDriver = '/registro/conductor';
  static const verifyEmail = '/verificar';

  // Pasajero
  static const passengerHome = '/pasajero';
  static const requestTrip = '/pasajero/solicitar';
  static const passengerTrip = '/pasajero/viaje'; // /:id

  // Conductor
  static const driverHome = '/conductor';

  // Común
  static const rate = '/calificar'; // /:tripId
}
