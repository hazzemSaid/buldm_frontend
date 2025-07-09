import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(LocationInitial());

  void setLocation(LatLng newLocation) {
    emit(LocationSelected(newLocation));
  }

  void resetLocation() {
    emit(LocationInitial());
  }

  LatLng? getLocation() {
    if (state is LocationSelected) {
      return (state as LocationSelected).location;
    }
    return null;
  }
}
