import '../entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<void> sendPasswordResetEmail(String email);

  Future<AppUser> signInWithGoogle();

  Future<void> logout();

  Future<AppUser?> getCurrentUser();
}
