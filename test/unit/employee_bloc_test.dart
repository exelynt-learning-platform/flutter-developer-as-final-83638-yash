import 'package:bloc_test/bloc_test.dart';
import 'package:employee_management/features/employee/domain/entities/country.dart';
import 'package:employee_management/features/employee/domain/entities/employee.dart';
import 'package:employee_management/features/employee/domain/repositories/employee_repository.dart';
import 'package:employee_management/features/employee/presentation/bloc/employee_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEmployeeRepository extends Mock implements EmployeeRepository {}

void main() {
  late MockEmployeeRepository mockRepository;
  late EmployeeBloc employeeBloc;

  const tEmployee = Employee(
    id: '1',
    name: 'Mansi',
    email: 'mansi@gmail.com',
    mobile: '7425369808',
    country: 'India',
    state: 'Maharashtra',
    district: 'Buldhana',
  );

  const tCountry = Country(id: '1', name: 'India');

  setUp(() {
    mockRepository = MockEmployeeRepository();
    employeeBloc = EmployeeBloc(repository: mockRepository);
    registerFallbackValue(tEmployee);
  });

  tearDown(() {
    employeeBloc.close();
  });

  group('EmployeeBloc Unit Tests', () {
    test('initial state is EmployeeInitialState', () {
      expect(employeeBloc.state, equals(EmployeeInitialState()));
    });

    blocTest<EmployeeBloc, EmployeeState>(
      'emits [EmployeeLoadingState, EmployeeLoadedState] when LoadEmployeesEvent succeeds',
      build: () {
        when(() => mockRepository.getEmployees())
            .thenAnswer((_) async => [tEmployee]);
        when(() => mockRepository.getCountries())
            .thenAnswer((_) async => [tCountry]);
        return employeeBloc;
      },
      act: (bloc) => bloc.add(const LoadEmployeesEvent()),
      expect: () => [
        EmployeeLoadingState(),
        const EmployeeLoadedState(
          allEmployees: [tEmployee],
          filteredEmployees: [tEmployee],
          countries: [tCountry],
        ),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'filters employee list by name when FilterEmployeesEvent is dispatched',
      build: () => employeeBloc,
      seed: () => const EmployeeLoadedState(
        allEmployees: [tEmployee],
        filteredEmployees: [tEmployee],
      ),
      act: (bloc) => bloc.add(const FilterEmployeesEvent(
        query: 'Mansi',
        filterBy: 'Name',
      )),
      expect: () => [
        const EmployeeLoadedState(
          allEmployees: [tEmployee],
          filteredEmployees: [tEmployee],
          searchQuery: 'Mansi',
          filterType: 'Name',
        ),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'emits updated state when AddEmployeeEvent is dispatched',
      build: () {
        when(() => mockRepository.createEmployee(any()))
            .thenAnswer((_) async => tEmployee);
        return employeeBloc;
      },
      seed: () => const EmployeeLoadedState(
        allEmployees: [],
        filteredEmployees: [],
      ),
      act: (bloc) => bloc.add(const AddEmployeeEvent(tEmployee)),
      expect: () => [
        const EmployeeLoadedState(
          allEmployees: [],
          filteredEmployees: [],
          isSubmitting: true,
        ),
        const EmployeeLoadedState(
          allEmployees: [tEmployee],
          filteredEmployees: [tEmployee],
          isSubmitting: false,
          successMessage: 'Employee "Mansi" created successfully!',
        ),
      ],
    );

    blocTest<EmployeeBloc, EmployeeState>(
      'optimistically removes employee when DeleteEmployeeEvent is dispatched',
      build: () {
        when(() => mockRepository.deleteEmployee('1'))
            .thenAnswer((_) async => Future.value());
        return employeeBloc;
      },
      seed: () => const EmployeeLoadedState(
        allEmployees: [tEmployee],
        filteredEmployees: [tEmployee],
      ),
      act: (bloc) => bloc.add(const DeleteEmployeeEvent('1')),
      expect: () => [
        const EmployeeLoadedState(
          allEmployees: [],
          filteredEmployees: [],
          successMessage: 'Employee "Mansi" deleted successfully.',
        ),
      ],
    );
  });
}
