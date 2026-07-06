import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/theme_controller.dart';

/// Indica si el usuario ya vio la introducción (persistido localmente).
class OnboardingController extends StateNotifier<bool> {
  OnboardingController(this._ref)
      : super(_ref.read(sharedPreferencesProvider).getBool(_key) ?? false);

  static const _key = 'onboarding_seen';
  final Ref _ref;

  Future<void> complete() async {
    state = true;
    await _ref.read(sharedPreferencesProvider).setBool(_key, true);
  }
}

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingController, bool>((ref) {
  return OnboardingController(ref);
});
