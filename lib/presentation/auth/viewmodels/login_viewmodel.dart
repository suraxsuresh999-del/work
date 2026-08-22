import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/di/auth_providers.dart';

class LoginViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  LoginViewModel(this._ref) : super(const AsyncData(null));

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      final signInEmail = _ref.read(signInEmailUseCaseProvider);
      await signInEmail(email: email, password: password);
      state = const AsyncData(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    state = const AsyncLoading();
    try {
      final signUp = _ref.read(signUpUseCaseProvider);
      await signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final signInGoogle = _ref.read(signInGoogleUseCaseProvider);
      await signInGoogle();
      state = const AsyncData(null);
      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }
}

final loginViewModelProvider = StateNotifierProvider.autoDispose<LoginViewModel, AsyncValue<void>>((ref) {
  return LoginViewModel(ref);
});
