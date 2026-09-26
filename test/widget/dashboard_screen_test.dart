import 'package:employee_management/core/theme/app_theme.dart';
import 'package:employee_management/features/auth/domain/entities/app_user.dart';
import 'package:employee_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:employee_management/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:employee_management/features/employee/domain/entities/country.dart';
import 'package:employee_management/features/employee/domain/entities/employee.dart';
import 'package:employee_management/features/employee/domain/repositories/employee_repository.dart';
import 'package:employee_management/features/employee/presentation/bloc/employee_bloc.dart';
import 'package:employee_management/features/employee/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockEmployeeRepository mockEmployeeRepository;
  late AuthBloc authBloc;
  late EmployeeBloc employeeBloc;

  const tUser = AppUser(
    id: '123',
    email: 'admin@company.com',
    displayName: 'Admin User',
  );

  const tEmployee = Employee(
    id: '1',
    name: 'Mansi',
    email: 'mansi@gmail.com',
    mobile: '7425369808',
    country: 'India',
    state: 'Maharashtra',
    district: 'Buldhana',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockEmployeeRepository = MockEmployeeRepository();

    authBloc = AuthBloc(authRepository: mockAuthRepository);
    employeeBloc = EmployeeBloc(repository: mockEmployeeRepository);

    when(() => mockEmployeeRepository.getEmployees())
        .thenAnswer((_) async => [tEmployee]);
    when(() => mockEmployeeRepository.getCountries())
        .thenAnswer((_) async => [const Country(id: '1', name: 'India')]);
  });

  tearDown(() {
    authBloc.close();
    employeeBloc.close();
  });

  Widget buildTestableWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<AuthBloc>.value(value: authBloc..emit(const Authenticated(tUser))),
        BlocProvider<EmployeeBloc>.value(
          value: employeeBloc
            ..emit(const EmployeeLoadedState(
              allEmployees: [tEmployee],
              filteredEmployees: [tEmployee],
            )),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('DashboardScreen Widget Tests', () {
    testWidgets('renders app bar title, search bar, and employee card', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const DashboardScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Employee Dashboard'), findsOneWidget);
      expect(find.text('Mansi'), findsOneWidget);
      expect(find.text('mansi@gmail.com'), findsOneWidget);
      expect(find.text('Add Employee'), findsOneWidget);
    });

    testWidgets('opens drawer when hamburger menu icon is tapped', (tester) async {
      await tester.pumpWidget(buildTestableWidget(const DashboardScreen()));
      await tester.pumpAndSettle();

      final drawerIcon = find.byTooltip('Open navigation menu');
      await tester.tap(drawerIcon);
      await tester.pumpAndSettle();

      expect(find.text('Admin User'), findsOneWidget);
      expect(find.text('admin@company.com'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
  });
}
