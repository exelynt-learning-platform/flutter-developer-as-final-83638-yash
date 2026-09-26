import '../../domain/entities/country.dart';

class CountryModel extends Country {
  const CountryModel({
    required super.id,
    required super.name,
    super.flag,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      id: json['id']?.toString() ?? '',
      name: (json['country'] ?? json['name'])?.toString() ?? '',
      flag: json['flag']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'country': name,
      'flag': flag,
    };
  }
}
