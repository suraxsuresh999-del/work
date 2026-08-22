import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignInEmailUseCase {
  final AuthRepository _repository;

  SignInEmailUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
  }) async {
    return await _repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}
