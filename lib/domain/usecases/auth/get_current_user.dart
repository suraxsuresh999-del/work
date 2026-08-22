import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<UserEntity?> call() async {
    return await _repository.getCurrentUser();
  }
}

class AuthStateChangesUseCase {
  final AuthRepository _repository;

  AuthStateChangesUseCase(this._repository);

  Stream<UserEntity?> call() {
    return _repository.authStateChanges;
  }
}
