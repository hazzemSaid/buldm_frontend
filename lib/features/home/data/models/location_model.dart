import 'package:buldm/features/home/domain/entities/LocationEntity.dart';
import 'package:equatable/equatable.dart';

class LocationModel extends LocationEntity implements Equatable {
  LocationModel(
      {required super.type,
      required super.coordinates,
      required super.placeName});
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates']),
      placeName: json['placeName'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      'placeName': placeName,
    };
  }

  @override
  List<Object?> get props => [
        type,
        coordinates,
        placeName,
      ];

  @override
  bool? get stringify => true;
}
