import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/sign_in_email.dart';
import '../../domain/usecases/auth/sign_in_google.dart';
import '../../domain/usecases/auth/sign_out.dart';
import '../../domain/usecases/auth/sign_up.dart';
import 'providers.dart';

// ─── Data Layer ─────────────────────────────────────────────────

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});

// ─── Domain Layer (Use Cases) ───────────────────────────────────

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

final authStateChangesUseCaseProvider = Provider<AuthStateChangesUseCase>((ref) {
  return AuthStateChangesUseCase(ref.watch(authRepositoryProvider));
});

final signInEmailUseCaseProvider = Provider<SignInEmailUseCase>((ref) {
  return SignInEmailUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final signInGoogleUseCaseProvider = Provider<SignInGoogleUseCase>((ref) {
  return SignInGoogleUseCase(ref.watch(authRepositoryProvider));
});

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});
