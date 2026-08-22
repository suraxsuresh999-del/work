import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../app/di/auth_providers.dart';

// ─── Auth State View Model ──────────────────────────────────────

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final authStateChanges = ref.watch(authStateChangesUseCaseProvider);
  return authStateChanges();
});

final currentUserProvider = Provider<AsyncValue<UserEntity?>>((ref) {
  // BUG-05 FIX: Derive from the live auth stream so this stays in sync
  // after sign-in / sign-out, instead of being a stale one-shot future.
  return ref.watch(authStateProvider);
});

class AuthViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  AuthViewModel(this._ref) : super(const AsyncData(null));

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      final signOutUseCase = _ref.read(signOutUseCaseProvider);
      await signOutUseCase();
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AsyncValue<void>>((ref) {
  return AuthViewModel(ref);
});
