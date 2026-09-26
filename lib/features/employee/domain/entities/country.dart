import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String id;
  final String name;
  final String? flag;

  const Country({
    required this.id,
    required this.name,
    this.flag,
  });

  @override
  List<Object?> get props => [id, name, flag];
}
