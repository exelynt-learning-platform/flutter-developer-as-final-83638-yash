import '../../../../core/network/api_client.dart';
import '../models/country_model.dart';
import '../models/employee_model.dart';

abstract class EmployeeRemoteDataSource {
  Future<List<EmployeeModel>> getEmployees();

  Future<EmployeeModel> getEmployeeById(String id);

  Future<EmployeeModel> createEmployee(EmployeeModel employee);

  Future<EmployeeModel> updateEmployee(String id, EmployeeModel employee);

  Future<void> deleteEmployee(String id);

  Future<List<CountryModel>> getCountries();
}

class EmployeeRemoteDataSourceImpl implements EmployeeRemoteDataSource {
  final ApiClient apiClient;

  EmployeeRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<EmployeeModel>> getEmployees() async {
    final response = await apiClient.get('/employee');
    if (response is List) {
      return response
          .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  @override
  Future<EmployeeModel> getEmployeeById(String id) async {
    final response = await apiClient.get('/employee/$id');
    return EmployeeModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<EmployeeModel> createEmployee(EmployeeModel employee) async {
    final body = employee.toJson();
    // Remove ID for creation so MockAPI auto-generates ID
    body.remove('id');
    final response = await apiClient.post('/employee', body);
    return EmployeeModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<EmployeeModel> updateEmployee(String id, EmployeeModel employee) async {
    final response = await apiClient.put('/employee/$id', employee.toJson());
    return EmployeeModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteEmployee(String id) async {
    await apiClient.delete('/employee/$id');
  }

  @override
  Future<List<CountryModel>> getCountries() async {
    final response = await apiClient.get('/country');
    if (response is List) {
      return response
          .map((item) => CountryModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}
