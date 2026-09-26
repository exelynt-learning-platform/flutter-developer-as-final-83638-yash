import 'package:bloc_test/bloc_test.dart';
import 'package:employee_management/features/auth/domain/entities/app_user.dart';
import 'package:employee_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:employee_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  const tUser = AppUser(
    id: '123',
    email: 'admin@company.com',
    displayName: 'Admin User',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc Unit Tests', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(AuthInitial()));
    });

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when AuthCheckRequested finds logged in user',
      build: () {
        when(() => mockAuthRepository.getCurrentUser())
            .thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        AuthLoading(),
        const Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Authenticated] when AuthLoginRequested succeeds',
      build: () {
        when(() => mockAuthRepository.loginWithEmailAndPassword(
              email: 'admin@company.com',
              password: 'password123',
            )).thenAnswer((_) async => tUser);
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthLoginRequested(
        email: 'admin@company.com',
        password: 'password123',
      )),
      expect: () => [
        AuthLoading(),
        const Authenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, PasswordResetSent] when AuthForgotPasswordRequested succeeds',
      build: () {
        when(() => mockAuthRepository.sendPasswordResetEmail('admin@company.com'))
            .thenAnswer((_) async => Future.value());
        return authBloc;
      },
      act: (bloc) => bloc.add(const AuthForgotPasswordRequested('admin@company.com')),
      expect: () => [
        AuthLoading(),
        const PasswordResetSent('Password reset link sent to admin@company.com'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, Unauthenticated] when AuthLogoutRequested is dispatched',
      build: () {
        when(() => mockAuthRepository.logout())
            .thenAnswer((_) async => Future.value());
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [
        AuthLoading(),
        Unauthenticated(),
      ],
    );
  });
}
