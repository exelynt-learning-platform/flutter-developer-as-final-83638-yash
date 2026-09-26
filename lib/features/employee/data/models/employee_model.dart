import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.name,
    required super.email,
    required super.mobile,
    required super.country,
    required super.state,
    required super.district,
    super.avatar,
    super.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: (json['email'] ?? json['emailId'])?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      avatar: (json['avatar'] ?? json['profilePhoto'])?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'country': country,
      'state': state,
      'district': district,
      'avatar': avatar ?? '',
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  factory EmployeeModel.fromEntity(Employee employee) {
    return EmployeeModel(
      id: employee.id,
      name: employee.name,
      email: employee.email,
      mobile: employee.mobile,
      country: employee.country,
      state: employee.state,
      district: employee.district,
      avatar: employee.avatar,
      createdAt: employee.createdAt,
    );
  }
}
