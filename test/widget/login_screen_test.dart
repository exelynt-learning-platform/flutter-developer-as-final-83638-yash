import 'package:employee_management/core/theme/app_theme.dart';
import 'package:employee_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:employee_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:employee_management/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders email and password fields and submit button', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
      expect(find.text('LOG IN'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('shows validation errors when submitting empty form', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      final loginBtn = find.text('LOG IN');
      await tester.tap(loginBtn);
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email format', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));

      final emailField = find.byType(TextFormField).at(0);
      await tester.enterText(emailField, 'invalid-email');
      await tester.tap(find.text('LOG IN'));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('switches to register mode when Sign Up is tapped', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();

      final signUpBtn = find.text('Sign Up');
      await tester.ensureVisible(signUpBtn);
      await tester.tap(signUpBtn);
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3)); // Name, Email, Password
      expect(find.text('REGISTER'), findsOneWidget);
    });
  });
}
