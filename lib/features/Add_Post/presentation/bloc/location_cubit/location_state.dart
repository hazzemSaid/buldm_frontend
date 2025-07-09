part of 'location_cubit.dart';

abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationSelected extends LocationState {
  final LatLng location;
  LocationSelected(this.location);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationSelected && other.location == location;
  }

  @override
  int get hashCode => location.hashCode;
}
