import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/bloc/location_cubit.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/config/assets.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/address.dart';
import 'package:deligo/models/address_request.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/my_map_widget.dart';
import 'package:deligo/widgets/toaster.dart';


class AddAddressPage extends StatelessWidget {
  const AddAddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationCubit>(
          create: (BuildContext context) => LocationCubit(),
        ),
        BlocProvider<FetcherCubit>(
          create: (BuildContext context) => FetcherCubit(),
        ),
      ],
      child: AddAddressStateful(address: arguments?["address"]),
    );
  }
}

class AddAddressStateful extends StatefulWidget {
  final Address? address;

  const AddAddressStateful({super.key, this.address});

  @override
  State<AddAddressStateful> createState() => _AddAddressStatefulState();
}

class _AddAddressStatefulState extends State<AddAddressStateful> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _addressDetailController =
      TextEditingController();
  final GlobalKey<MyMapState> _myMapStateKey = GlobalKey();

  // ignore: unused_field
  bool _geoLocating = false;

  // ignore: unused_field
  bool _addressContinue = false;
  late LocationCubit _locationCubit;
  late FetcherCubit _fetcherCubit;
  late Address _address;

  @override
  void initState() {
    _address = widget.address ??
        Address(-1, "address_type_home", "", 0.0, 0.0, null, null, null, null,
            null, null, null, null);
    _addressController.text = _address.formatted_address;
    _locationCubit = BlocProvider.of<LocationCubit>(context);
    _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<LocationCubit, LocationState>(
          listener: (context, state) {
            setState(() => _geoLocating = state is LocationLoading);

            if (state is LocationPermissionStatus) {
              if (state.isPermissionGranted()) {
                _locationCubit.initFetchCurrentLocation(false);
              } else {
                Toaster.showToastBottom(AppLocalization.instance
                    .getLocalizationFor("error_permission"));
              }
            }
            if (state is LocationFail) {
              if (state.msgKey == "error_permission") {
                ConfirmDialog.showConfirmation(
                        context,
                        Text(AppLocalization.instance
                            .getLocalizationFor("location_services")),
                        Text(AppLocalization.instance
                            .getLocalizationFor("location_services_msg")),
                        null,
                        AppLocalization.instance.getLocalizationFor("okay"))
                    .then((value) {
                  if (value != null && value == true) {
                    _locationCubit.initRequestLocationPermission();
                  }
                });
              } else {
                Toaster.showToast(AppLocalization.instance
                    .getLocalizationFor("error_service"));
              }
            }
            if (state is LocationLoaded) {
              LatLng latLng =
                  LatLng(state.lattitude ?? 0.0, state.longitude ?? 0.0);
              _fetcherCubit.initFetchLatLngAddress("address", latLng);
              _updateLocationOnMap(latLng);
            }
          },
        ),
        BlocListener<FetcherCubit, FetcherState>(
          listener: (context, state) async {
            if (state is ReverseGeocodeLoaded) {
              _address.latitude = state.latLng.latitude;
              _address.longitude = state.latLng.longitude;
              _address.formatted_address = state.address;
              _addressController.text = state.address;
              _addressContinue = false;
              setState(() {});
            }
            if (state is GeocodeLoaded) {
              _address.latitude = state.latLng.latitude;
              _address.longitude = state.latLng.longitude;
              _address.formatted_address = state.address;
              _addressController.text = state.address;
              _addressContinue = false;
              setState(() {});

              _updateLocationOnMap(state.latLng);
            }
            if (state is AddressAddLoading || state is AddressUpdateLoading) {
              Loader.showLoader(context);
            } else {
              Loader.dismissLoader(context);
            }
            if (state is AddressAddLoaded) {
              Navigator.pop(context, state.address);
            }
            if (state is AddressUpdateLoaded) {
              Navigator.pop(context, state.address);
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: RegularAppBar(
            title:
                AppLocalization.instance.getLocalizationFor("addNewAddress")),
        body: Stack(
          children: [
            MyMapWidget(
              key: _myMapStateKey,
              myMapData: MyMapData(
                center: LatLng(AppConfig.mapCenterDefault["latitude"] ?? 0,
                    AppConfig.mapCenterDefault["longitude"] ?? 0),
                markers: {},
                polyLines: <Polyline>{},
                zoomLevel: 14.0,
                zoomControlsEnabled: false,
              ),
              mapStyleAsset: theme.brightness == Brightness.dark
                  ? "assets/map_style_dark.json"
                  : "assets/map_style.json",
              onMarkerTap: (String markerId) {},
              onMapTap: (LatLng latLng) {
                _fetcherCubit.initFetchLatLngAddress("address", latLng);
                _updateLocationOnMap(latLng);
              },
              onBuildComplete: () {
                if (_address.id != -1) {
                  _updateLocationOnMap(_address.latLng);
                }
              },
            ),
            Positioned(
              top: 12,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CustomTextField(
                    prefixIcon: const Icon(Icons.search),
                    bgColor: theme.scaffoldBackgroundColor,
                    hintText: AppLocalization.instance
                        .getLocalizationFor("searchLocation"),
                    onTap: () => _getPredictions(),
                    readOnly: true,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.arrow_back_ios_sharp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      //const Spacer(),
                      GestureDetector(
                        onTap: () =>
                            _locationCubit.initFetchCurrentLocation(true),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(Icons.gps_fixed),
                        ),
                      ),
                    ],
                  ),
                  if (_address.formatted_address.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30)),
                        color: theme.scaffoldBackgroundColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              AppLocalization.instance
                                  .getLocalizationFor("addNewAddress"),
                              style: theme.textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w600, fontSize: 22)),
                          // ListTile(
                          //   minVerticalPadding: 10,
                          //   contentPadding: const EdgeInsets.only(top: 10),
                          //   leading:
                          //       Image.asset(Assets.pinsIcLocation, height: 35),
                          //   title: Text(
                          //     AppLocalization.instance
                          //         .getLocalizationFor(_address.title!),
                          //     style: theme.textTheme.titleMedium
                          //         ?.copyWith(fontWeight: FontWeight.w600),
                          //   ),
                          //   subtitle: Padding(
                          //     padding: const EdgeInsets.only(top: 8),
                          //     child: Text(
                          //       _address.formatted_address,
                          //       style: theme.textTheme.bodySmall
                          //           ?.copyWith(color: theme.hintColor),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(
                            height: 16,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Image.asset(
                                    Assets.pinsIcLocation,
                                    height: 35,
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                    AppLocalization.instance
                                        .getLocalizationFor(_address.title!),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.only(
                                    start: 16 + 35),
                                child: Text(
                                  _address.formatted_address,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: theme.hintColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          // SizedBox(
                          //   height: 60,
                          //   child: ListView.separated(
                          //       shrinkWrap: true,
                          //       scrollDirection: Axis.horizontal,
                          //       itemCount: 3,
                          //       separatorBuilder: (context, index) =>
                          //           const SizedBox(width: 25),
                          //       itemBuilder: (context, index) =>
                          //           getAddressTypeButton(index, theme)),
                          // ),
                          Row(
                            children: [
                              Expanded(
                                child: getAddressTypeButton(0, theme),
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: getAddressTypeButton(1, theme),
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: getAddressTypeButton(2, theme),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                            text: AppLocalization.instance
                                .getLocalizationFor("next"),
                            onTap: () {
                              if (_addressController.text.isEmpty) {
                                Toaster.showToastTop(context
                                    .getLocalizationFor("enter_address"));
                                return;
                              }
                              if (_addressDetailController.text.isNotEmpty) {
                                _addressController.text =
                                    "${_addressDetailController.text} ${_addressController.text}";
                              }
                              AddressRequest addressRequest = AddressRequest(
                                  _address.title!,
                                  _addressController.text,
                                  _address.latitude,
                                  _address.longitude);
                              if (_address.id == -1) {
                                _fetcherCubit.initCreateAddress(addressRequest);
                              } else {
                                _fetcherCubit.initUpdateAddress(
                                    _address.id, addressRequest);
                              }
                            },
                          )
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateLocationOnMap(LatLng latLng) async {
    if (_myMapStateKey.currentState != null) {
      if (_myMapStateKey.currentState!.hasMarkerWithId("current_location")) {
        _myMapStateKey.currentState!
            .updateMarkerLocation("current_location", latLng);
      } else {
        BitmapDescriptor bitmapDescriptor =
            await MyMapHelper.createBitmapDescriptorFromImage(
                Assets.pinsIcLocation, "");
        _myMapStateKey.currentState!
            .addMarker("current_location", bitmapDescriptor, latLng);
      }
      _myMapStateKey.currentState!.moveCamera(latLng);
    }
  }

  Future<Null> _getPredictions() => LocalDataLayer()
      .getCurrentLanguage()
      .then((String currLang) => PlacesAutocomplete.show(
            context: context,
            apiKey: AppConfig.googleApiKey,
            language: currLang,
            mode: Mode.fullscreen,
            types: [],
            components: [],
            strictbounds: false,
            resultTextStyle: Theme.of(context).textTheme.titleSmall,
            onError: (response) {
              if (kDebugMode) {
                print("PlacesAutocomplete: $response");
              }
            },
          ).then((prediction) {
            if (prediction != null) {
              _fetcherCubit.initFetchPredictionAddress("address", prediction);
            }
          }));

  Widget getAddressTypeButton(int index, ThemeData theme) {
    String type = index == 0
        ? "address_type_home"
        : (index == 1 ? "address_type_office" : "address_type_other");
    IconData icon = index == 0
        ? Icons.home
        : (index == 1 ? Icons.apartment : Icons.location_on);
    return ElevatedButton(
      style: ButtonStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          _address.title == type ? theme.primaryColor : theme.cardColor,
        ),
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      onPressed: () => setState(() => _address.title = type),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color:
                  _address.title == type ? Colors.white : theme.primaryColor),
          const SizedBox(width: 8),
          Text(
            AppLocalization.instance.getLocalizationFor(type),
            style: theme.textTheme.bodyMedium!.copyWith(
                color: _address.title == type ||
                        theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black),
          ),
        ],
      ),
    );
  }
}

