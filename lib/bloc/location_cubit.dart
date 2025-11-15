import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/models/my_location.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  Location location = Location();

  LocationCubit() : super(const LocationInitial());

  void initFetchCurrentLocation(bool freshLocation) async {
    emit(const LocationLoading());
    MyLocation? savedLocation;
    if (!freshLocation) {
      savedLocation = await LocalDataLayer().getSavedLocation();
      if (savedLocation != null) {
        emit(LocationLoaded(savedLocation.lattitude, savedLocation.longitude));
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.granted) {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }
      if (serviceEnabled) {
        LocationData locationData = await location.getLocation();
        LocalDataLayer().setSavedLocation(
            MyLocation(locationData.latitude, locationData.longitude));
        if (freshLocation || savedLocation == null) {
          emit(LocationLoaded(locationData.latitude, locationData.longitude));
        }
      } else {
        if (freshLocation || savedLocation == null) {
          emit(const LocationFail("error_service"));
        }
      }
    } else {
      if (freshLocation || savedLocation == null) {
        emit(const LocationFail("error_permission"));
      }
    }
  }

  void initRequestLocationPermission() async {
    emit(const LocationLoading());
    PermissionStatus permissionGranted = await location.requestPermission();
    emit(LocationPermissionStatus(permissionGranted));
  }
}
