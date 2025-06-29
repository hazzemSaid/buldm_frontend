class LocationEntity {
  final String type; // always "Point"
  final List<double> coordinates; // [longitude, latitude]
  final String placeName;

  const LocationEntity({
    required this.type,
    required this.coordinates,
    required this.placeName,
  });
}
