import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository _repository;

  SignUpUseCase(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    return await _repository.signUpWithEmail(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }
}
