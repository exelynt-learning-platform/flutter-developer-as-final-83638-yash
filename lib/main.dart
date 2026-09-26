import 'package:employee_management/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_ds.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/employee/data/datasources/employee_remote_ds.dart';
import 'features/employee/data/repositories/employee_repository_impl.dart';
import 'features/employee/domain/repositories/employee_repository.dart';
import 'features/employee/presentation/bloc/employee_bloc.dart';
import 'features/employee/presentation/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safe Firebase Initialization
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase Core initialization notice: $e');
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  // Core & Data Layer Injection
  final apiClient = ApiClient();
  final authRemoteDS = AuthRemoteDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDS);

  final employeeRemoteDS = EmployeeRemoteDataSourceImpl(apiClient: apiClient);
  final employeeRepository = EmployeeRepositoryImpl(
    remoteDataSource: employeeRemoteDS,
  );

  runApp(
    EmployeeApp(
      authRepository: authRepository,
      employeeRepository: employeeRepository,
    ),
  );
}

class EmployeeApp extends StatelessWidget {
  final AuthRepository authRepository;
  final EmployeeRepository employeeRepository;

  const EmployeeApp({
    super.key,
    required this.authRepository,
    required this.employeeRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<AuthBloc>(
          create: (_) =>
              AuthBloc(authRepository: authRepository)
                ..add(AuthCheckRequested()),
        ),
        BlocProvider<EmployeeBloc>(
          create: (_) => EmployeeBloc(repository: employeeRepository),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Employee Management App',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: const AuthRouter(),
          );
        },
      ),
    );
  }
}

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const DashboardScreen();
        } else if (state is Unauthenticated || state is AuthError) {
          return const LoginScreen();
        }

        // Loading Splash State
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.badge_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Initializing Employee App...'),
              ],
            ),
          ),
        );
      },
    );
  }
}
