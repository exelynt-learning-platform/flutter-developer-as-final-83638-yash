import '../../../../core/errors/failures.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_ds.dart';
import '../models/employee_model.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Employee>> getEmployees() async {
    try {
      final models = await remoteDataSource.getEmployees();
      return models;
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch employees: ${e.toString()}');
    }
  }

  @override
  Future<Employee> getEmployeeById(String id) async {
    try {
      return await remoteDataSource.getEmployeeById(id);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch employee details for ID $id');
    }
  }

  @override
  Future<Employee> createEmployee(Employee employee) async {
    try {
      final model = EmployeeModel.fromEntity(employee);
      return await remoteDataSource.createEmployee(model);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to create employee: ${e.toString()}');
    }
  }

  @override
  Future<Employee> updateEmployee(String id, Employee employee) async {
    try {
      final model = EmployeeModel.fromEntity(employee);
      return await remoteDataSource.updateEmployee(id, model);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to update employee ID $id: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteEmployee(String id) async {
    try {
      await remoteDataSource.deleteEmployee(id);
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to delete employee ID $id: ${e.toString()}');
    }
  }

  @override
  Future<List<Country>> getCountries() async {
    try {
      return await remoteDataSource.getCountries();
    } catch (e) {
      if (e is Failure) rethrow;
      throw ServerFailure('Failed to fetch countries: ${e.toString()}');
    }
  }
}
