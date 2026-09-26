import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String country;
  final String state;
  final String district;
  final String? avatar;
  final String? createdAt;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.country,
    required this.state,
    required this.district,
    this.avatar,
    this.createdAt,
  });

  Employee copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? country,
    String? state,
    String? district,
    String? avatar,
    String? createdAt,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      country: country ?? this.country,
      state: state ?? this.state,
      district: district ?? this.district,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        mobile,
        country,
        state,
        district,
        avatar,
        createdAt,
      ];
}
