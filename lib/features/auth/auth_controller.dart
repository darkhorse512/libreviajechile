import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/vehicle.dart';
import '../../data/providers.dart';
import '../../data/repositories/repositories.dart';

class AuthFormState {
  const AuthFormState({this.loading = false, this.error});
  final bool loading;
  final String? error;

  AuthFormState copyWith({bool? loading, String? error, bool clearError = false}) {
    return AuthFormState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Orquesta las acciones de autenticación exponiendo estado de carga/error.
class AuthFormController extends StateNotifier<AuthFormState> {
  AuthFormController(this._ref) : super(const AuthFormState());
  final Ref _ref;

  AuthRepository get _repo => _ref.read(authRepositoryProvider);

  Future<T?> _run<T>(Future<T> Function() action) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final result = await action();
      state = const AuthFormState();
      return result;
    } on AuthException catch (e) {
      state = AuthFormState(error: e.message);
      return null;
    } catch (_) {
      state = const AuthFormState(
          error: 'Ocurrió un error inesperado. Intenta nuevamente.');
      return null;
    }
  }

  Future<bool> signIn(String email, String password) async =>
      (await _run(() => _repo.signIn(email: email, password: password))) != null;

  Future<RegisterResult?> registerPassenger({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    String? city,
  }) =>
      _run(() => _repo.registerPassenger(
            fullName: fullName,
            email: email,
            phone: phone,
            city: city,
            password: password,
          ));

  Future<RegisterResult?> registerDriver({
    required String fullName,
    required String email,
    required String phone,
    required String city,
    required String password,
    required Vehicle vehicle,
  }) =>
      _run(() => _repo.registerDriver(
            fullName: fullName,
            email: email,
            phone: phone,
            city: city,
            password: password,
            vehicle: vehicle,
          ));

  Future<bool> verifyEmailOtp(String email, String token) async =>
      (await _run(() => _repo.verifyEmailOtp(email: email, token: token))) !=
      null;

  Future<bool> resendOtp(String email) async {
    try {
      await _repo.resendOtp(email: email);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(error: e.message);
      return false;
    } catch (_) {
      return false;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authFormControllerProvider =
    StateNotifierProvider<AuthFormController, AuthFormState>((ref) {
  return AuthFormController(ref);
});
