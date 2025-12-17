import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:location/location.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/models/my_location.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final Location location = Location();

  LocationCubit() : super(const LocationInitial());

  Future<void> initFetchCurrentLocation(bool freshLocation) async {
    emit(const LocationLoading());

    MyLocation? savedLocation;

    if (!freshLocation) {
      savedLocation = await LocalDataLayer().getSavedLocation();
      if (savedLocation != null) {
        emit(LocationLoaded(
          savedLocation.lattitude,
          savedLocation.longitude,
        ));
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted != PermissionStatus.granted) {
      permissionGranted = await location.requestPermission();
    }

    if (permissionGranted == PermissionStatus.granted) {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
      }

      if (!serviceEnabled) {
        if (freshLocation || savedLocation == null) {
          emit(const LocationFail("error_service"));
        }
        return;
      }

      final locationData = await location.getLocation();

      if (locationData.latitude == null ||
          locationData.longitude == null) {
        emit(const LocationFail("error_location"));
        return;
      }

      final myLocation = MyLocation(
        locationData.latitude!,
        locationData.longitude!,
      );

      await LocalDataLayer().setSavedLocation(myLocation);

      if (freshLocation || savedLocation == null) {
        emit(LocationLoaded(
          myLocation.lattitude,
          myLocation.longitude,
        ));
      }
    } else {
      if (freshLocation || savedLocation == null) {
        emit(const LocationFail("error_permission"));
      }
    }
  }

  Future<void> initRequestLocationPermission() async {
    emit(const LocationLoading());
    final permission = await location.requestPermission();
    emit(LocationPermissionStatus(permission));
  }
}
