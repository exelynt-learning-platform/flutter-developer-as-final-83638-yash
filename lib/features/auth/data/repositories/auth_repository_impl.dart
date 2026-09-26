import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AppUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return remoteDataSource.loginWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) {
    return remoteDataSource.registerWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<AppUser> signInWithGoogle() {
    return remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  Future<AppUser?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }
}
