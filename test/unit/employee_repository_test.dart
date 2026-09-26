import 'package:employee_management/core/errors/failures.dart';
import 'package:employee_management/features/employee/data/datasources/employee_remote_ds.dart';
import 'package:employee_management/features/employee/data/models/country_model.dart';
import 'package:employee_management/features/employee/data/models/employee_model.dart';
import 'package:employee_management/features/employee/data/repositories/employee_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockEmployeeRemoteDataSource extends Mock implements EmployeeRemoteDataSource {}

void main() {
  late MockEmployeeRemoteDataSource mockRemoteDataSource;
  late EmployeeRepositoryImpl repository;

  const tEmployeeModel = EmployeeModel(
    id: '1',
    name: 'Mansi',
    email: 'mansi@gmail.com',
    mobile: '7425369808',
    country: 'India',
    state: 'Maharashtra',
    district: 'Buldhana',
  );

  const tCountryModel = CountryModel(
    id: '1',
    name: 'India',
  );

  setUpAll(() {
    registerFallbackValue(tEmployeeModel);
  });

  setUp(() {
    mockRemoteDataSource = MockEmployeeRemoteDataSource();
    repository = EmployeeRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('EmployeeRepository CRUD Operations', () {
    test('getEmployees returns list of employees from remote data source', () async {
      when(() => mockRemoteDataSource.getEmployees())
          .thenAnswer((_) async => [tEmployeeModel]);

      final result = await repository.getEmployees();

      expect(result, equals([tEmployeeModel]));
      verify(() => mockRemoteDataSource.getEmployees()).called(1);
    });

    test('getEmployeeById returns single employee details', () async {
      when(() => mockRemoteDataSource.getEmployeeById('1'))
          .thenAnswer((_) async => tEmployeeModel);

      final result = await repository.getEmployeeById('1');

      expect(result, equals(tEmployeeModel));
      verify(() => mockRemoteDataSource.getEmployeeById('1')).called(1);
    });

    test('createEmployee delegates to remote data source and returns created employee', () async {
      when(() => mockRemoteDataSource.createEmployee(any()))
          .thenAnswer((_) async => tEmployeeModel);

      final result = await repository.createEmployee(tEmployeeModel);

      expect(result, equals(tEmployeeModel));
      verify(() => mockRemoteDataSource.createEmployee(any())).called(1);
    });

    test('updateEmployee delegates to remote data source and returns updated employee', () async {
      when(() => mockRemoteDataSource.updateEmployee('1', any()))
          .thenAnswer((_) async => tEmployeeModel);

      final result = await repository.updateEmployee('1', tEmployeeModel);

      expect(result, equals(tEmployeeModel));
      verify(() => mockRemoteDataSource.updateEmployee('1', any())).called(1);
    });

    test('deleteEmployee delegates call to remote data source', () async {
      when(() => mockRemoteDataSource.deleteEmployee('1'))
          .thenAnswer((_) async => Future.value());

      await repository.deleteEmployee('1');

      verify(() => mockRemoteDataSource.deleteEmployee('1')).called(1);
    });

    test('getCountries returns list of countries', () async {
      when(() => mockRemoteDataSource.getCountries())
          .thenAnswer((_) async => [tCountryModel]);

      final result = await repository.getCountries();

      expect(result, equals([tCountryModel]));
      verify(() => mockRemoteDataSource.getCountries()).called(1);
    });

    test('throws ServerFailure when remote data source fails', () async {
      when(() => mockRemoteDataSource.getEmployees())
          .thenThrow(const ServerFailure('Server Error'));

      expect(
        () => repository.getEmployees(),
        throwsA(isA<ServerFailure>()),
      );
    });
  });
}
