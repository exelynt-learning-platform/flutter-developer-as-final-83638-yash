import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String? ?? 'Employee Admin',
      photoUrl: json['photoUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}
