import 'package:buldm/features/home/domain/entities/LocationEntity.dart';

class LocationModel extends LocationEntity {
  LocationModel({
    required super.type,
    required super.coordinates,
    required super.placeName,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'] ?? '',
      coordinates: json['coordinates'] == null
          ? []
          : List<double>.from(
              json['coordinates'].map((e) => (e as num).toDouble())),
      placeName: json['placeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      'placeName': placeName,
    };
  }
}
