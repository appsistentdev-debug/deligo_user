import 'dart:convert';

import 'package:deligo/models/ride.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/bloc/location_cubit.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/config/colors.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/address.dart';
import 'package:deligo/models/coupon.dart';
import 'package:deligo/models/payment_method.dart';
import 'package:deligo/models/ride_request.dart';
import 'package:deligo/models/vehicle_type.dart';
import 'package:deligo/pages/vehicle_type_sheet.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/my_map_widget.dart';
import 'package:deligo/widgets/ripple_animation.dart';
import 'package:deligo/widgets/toaster.dart';

import 'date_time_picker_sheet.dart';
import 'pick_drop_details_sheet.dart';

class SelectSrcDstPage extends StatelessWidget {
  const SelectSrcDstPage({super.key});

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
      child: SelectSrcDstStateful(arguments?["type"] ?? "ride"),
    );
  }
}

class SelectSrcDstStateful extends StatefulWidget {
  final String rideType; //["ride", "intercity", "courier"]
  const SelectSrcDstStateful(this.rideType, {super.key});

  @override
  State<SelectSrcDstStateful> createState() => _SelectSrcDstStatefulState();
}

class _SelectSrcDstStatefulState extends State<SelectSrcDstStateful> {
  late LocationCubit _locationCubit;
  late FetcherCubit _fetcherCubit;
  List<Address> addresses = [];
  List<Address> recentSearches = [];
  final GlobalKey<MyMapState> _myMapStateKey = GlobalKey();

  // ignore: unused_field
  bool _geoLocating = false;
  bool _searchMode = false;

  final TextEditingController _sourceLocationController =
      TextEditingController();
  final TextEditingController _destinationLocationController =
      TextEditingController();
  String? _tag;
  String? _sourceAddress;
  // ignore: unused_field
  String? _sourceCity;
  String? _destinationAddress;
  // ignore: unused_field
  String? _destinationCity;
  LatLng? _sourceLatlng;
  LatLng? _destinationLatlng;
  bool _latLngsChanged = false;

  bool get _isSelectedSource => _sourceAddress != null && _sourceLatlng != null;

  bool get _isSelectedDestination =>
      _destinationAddress != null && _destinationLatlng != null;

  DateTime? dateSelected;
  TimeOfDay? timeSelected;
  DateTime? dateTimeSelected;
  String? dateTimeSelectedFormatted;
  bool isRideLoading = false;
  Map<String, String> requestMetaMap = {};

  @override
  void initState() {
    _locationCubit = BlocProvider.of<LocationCubit>(context);
    _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
    super.initState();
    LocalDataLayer().getRecentSearches().then((value) {
      recentSearches = value;
      _fetcherCubit.initFetchAddresses();
    });
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => LocalDataLayer().getTempRide().then((Ride? tr) {
              if (tr != null) {
                _setupRideData(tr);
              }
              LocalDataLayer().setTempRide(null);
            }));
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
              _fetcherCubit.initFetchLatLngAddress(
                  _searchMode ? (_tag ?? "src") : "src", latLng);
            }
          },
        ),
        BlocListener<FetcherCubit, FetcherState>(
          listener: (context, state) {
            if (state is ReverseGeocodeLoading || state is GeocodeLoading) {
              _geoLocating = true;
              setState(() {});
            } else if (_geoLocating) {
              _geoLocating = false;
              setState(() {});
            }
            if (state is ReverseGeocodeLoaded) {
              _sourceLocationController.text = _sourceAddress ?? "";
              _searchMode = false;
              _setupLocation(
                  state.tag, state.city, state.address, state.latLng);
              setState(() {});
            }
            if (state is GeocodeLoaded) {
              _sourceLocationController.text = _sourceAddress ?? "";
              _searchMode = false;
              _setupLocation(
                  state.tag, state.city, state.address, state.latLng);
              setState(() {});
            }
            if (state is AddressesLoaded) {
              addresses = state.addresses;
              setState(() {});
            }
            if (state is CreateRideLoading) {
              //Loader.showLoader(context);
              setState(() => isRideLoading = true);
            } else {
              //Loader.dismissLoader(context);
              setState(() => isRideLoading = false);
            }
            if (state is CreateRideLoaded) {
              if (state.ride.is_scheduled == 1) {
                Toaster.showToastCenter(AppLocalization.instance
                    .getLocalizationFor("ride_scheduled"));
                LocalDataLayer().setTabUpdate(1, "refresh_rides").then((_) =>
                    Navigator.popUntil(context, (route) => route.isFirst));
              } else {
                Navigator.pushReplacementNamed(context, PageRoutes.rideInfoPage,
                    arguments: state.ride);
              }
            }
            if (state is CreateRideFail) {
              Toaster.showToastCenter(AppLocalization.instance
                  .getLocalizationFor(state.messageKey));
            }
          },
        ),
      ],
      child: PopScope(
        canPop: _tag == null,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            setState(() => _tag = null);
          }
        },
        child: Scaffold(
          appBar: RegularAppBar(
            title: AppLocalization.instance
                .getLocalizationFor("${widget.rideType}_title"),
          ),
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
                  if (_searchMode) {
                    _fetcherCubit.initFetchLatLngAddress(_tag, latLng);
                  }
                },
                onBuildComplete: () {},
              ),
              if (isRideLoading)
                RipplesAnimation(
                  color: Theme.of(context).primaryColor,
                  child: const Icon(Icons.location_on),
                ),
              Positioned(
                left: 20,
                right: 20,
                top: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: theme.scaffoldBackgroundColor,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            onTap: () {
                              if (_searchMode) {
                                _showAutocompleteScreen(context, null, null);
                              } else {
                                if (_tag == "src") {
                                  _sourceLocationController.clear();
                                  setState(() => _searchMode = true);
                                  _showAutocompleteScreen(context, null, null);
                                } else {
                                  setState(() => _tag = "src");
                                }
                              }
                            },
                            controller: _sourceLocationController,
                            readOnly: true,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontSize: 14),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: AppLocalization.instance
                                  .getLocalizationFor(_searchMode
                                      ? "searchLocation"
                                      : "startingPoint"),
                              hintStyle: theme.textTheme.bodySmall
                                  ?.copyWith(fontSize: 14),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: theme.primaryColor,
                                  child: Icon(
                                    _searchMode && _tag == "dst"
                                        ? Icons.navigation
                                        : Icons.location_on,
                                    color: theme.scaffoldBackgroundColor,
                                    size: 16,
                                  ),
                                ),
                              ),
                              suffixIcon: _geoLocating
                                  ? SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Transform.scale(
                                        scale: 0.5,
                                        child: Loader
                                            .circularProgressIndicatorPrimary(
                                                context),
                                      ),
                                    )
                                  : GestureDetector(
                                      onTap: () {
                                        if (!_searchMode && _isSelectedSource) {
                                          _clearLocation("src");
                                          setState(() {});
                                        } else {
                                          _locationCubit
                                              .initFetchCurrentLocation(true);
                                        }
                                      },
                                      child: Icon(
                                        (!_searchMode && _isSelectedSource)
                                            ? Icons.cancel
                                            : Icons.gps_fixed,
                                        size: 20,
                                        color: theme.hintColor,
                                      ),
                                    ),
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          if (!_searchMode)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                              color: theme.cardColor,
                            ),
                          if (!_searchMode)
                            TextFormField(
                              onTap: () {
                                if (_tag == "dst") {
                                  _sourceLocationController.clear();
                                  setState(() => _searchMode = true);
                                  _showAutocompleteScreen(context, null, null);
                                } else {
                                  setState(() => _tag = "dst");
                                }
                              },
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontSize: 14),
                              controller: _destinationLocationController,
                              readOnly: true,
                              decoration: InputDecoration(
                                isDense: true,
                                hintStyle: theme.textTheme.bodySmall
                                    ?.copyWith(fontSize: 14),
                                hintText: AppLocalization.instance
                                    .getLocalizationFor("whereToGo"),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: theme.primaryColor,
                                    child: Icon(
                                      Icons.navigation,
                                      color: theme.scaffoldBackgroundColor,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                suffixIcon: _isSelectedDestination
                                    ? GestureDetector(
                                        onTap: () {
                                          _clearLocation("dst");
                                          setState(() {});
                                        },
                                        child: Icon(
                                          Icons.cancel,
                                          size: 20,
                                          color: theme.hintColor,
                                        ),
                                      )
                                    : null,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          if (!_searchMode &&
                              (widget.rideType == "intercity" ||
                                  (dateTimeSelected != null &&
                                      dateSelected != null &&
                                      timeSelected != null)))
                            Divider(
                              height: 2,
                              thickness: 2,
                              indent: 20,
                              endIndent: 20,
                              color: theme.cardColor,
                            ),
                          if (!_searchMode &&
                              (widget.rideType == "intercity" ||
                                  (dateTimeSelected != null &&
                                      dateSelected != null &&
                                      timeSelected != null)))
                            GestureDetector(
                              onTap: () => showModalBottomSheet(
                                isScrollControlled: true,
                                //backgroundColor: theme.scaffoldBackgroundColor,
                                context: context,
                                builder: (context) => DateTimePickerSheet(
                                  title: AppLocalization.instance
                                      .getLocalizationFor("whenDoYouWant"),
                                  date: dateSelected,
                                  time: timeSelected,
                                ),
                              ).then((value) {
                                if (value != null && value is Map) {
                                  dateSelected = value["date"];
                                  timeSelected = value["time"];
                                  dateTimeSelected = DateTime(
                                      dateSelected!.year,
                                      dateSelected!.month,
                                      dateSelected!.day,
                                      timeSelected!.hour,
                                      timeSelected!.minute);
                                  dateTimeSelectedFormatted =
                                      Helper.setupDateTimeFromMillis(
                                          dateTimeSelected!
                                              .millisecondsSinceEpoch,
                                          true,
                                          true);
                                  setState(() {});
                                }
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 18,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: theme.scaffoldBackgroundColor,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Text(
                                        dateTimeSelectedFormatted ??
                                            AppLocalization.instance
                                                .getLocalizationFor(
                                                    "pickupNow"),
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_tag != null && !_searchMode)
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: theme.scaffoldBackgroundColor,
                          ),
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 20,
                            ),
                            shrinkWrap: true,
                            children: [
                              InkWell(
                                onTap: () {
                                  _sourceLocationController.clear();
                                  setState(() => _searchMode = true);
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.search,
                                        size: 22,
                                        color: theme.dividerColor,
                                      ),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalization.instance
                                                  .getLocalizationFor("search"),
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              AppLocalization.instance
                                                  .getLocalizationFor(
                                                      "search_map"),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (addresses.isNotEmpty)
                                Text(
                                  AppLocalization.instance
                                      .getLocalizationFor("savedLocations"),
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontSize: 14),
                                ),
                              if (addresses.isNotEmpty)
                                const SizedBox(height: 20),
                              for (Address address in addresses)
                                InkWell(
                                  onTap: () {
                                    _setupLocation(
                                        _tag!,
                                        address.city,
                                        address.formatted_address,
                                        address.latLng);
                                    setState(() {});
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          address.title == "address_type_home"
                                              ? Icons.home
                                              : address.title ==
                                                      "address_type_office"
                                                  ? Icons.apartment_outlined
                                                  : Icons.location_on,
                                          size: 22,
                                          color: theme.dividerColor,
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalization.instance
                                                    .getLocalizationFor(
                                                        address.title!),
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                address.formatted_address,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (addresses.isNotEmpty &&
                                  recentSearches.isNotEmpty)
                                const SizedBox(height: 8),
                              if (recentSearches.isNotEmpty)
                                Text(
                                  AppLocalization.instance
                                      .getLocalizationFor("recentSearches"),
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(fontSize: 14),
                                ),
                              if (recentSearches.isNotEmpty)
                                const SizedBox(height: 20),
                              for (Address address in recentSearches)
                                InkWell(
                                  onTap: () {
                                    _setupLocation(
                                        _tag!,
                                        address.city,
                                        address.formatted_address,
                                        address.latLng);
                                    setState(() {});
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.refresh,
                                          size: 22,
                                          color: theme.dividerColor,
                                        ),
                                        const SizedBox(width: 15),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalization.instance
                                                    .getLocalizationFor(
                                                        address.title!),
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                address.formatted_address,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              if (recentSearches.isNotEmpty)
                                const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: CustomButton(
                  onTap: () {
                    if (!_isSelectedSource) {
                      Toaster.showToastCenter(AppLocalization.instance
                          .getLocalizationFor("select_location_source"));
                      return;
                    }
                    if (!_isSelectedDestination) {
                      Toaster.showToastCenter(AppLocalization.instance
                          .getLocalizationFor("select_location_destination"));
                      return;
                    }
                    // if (widget.rideType == "intercity" &&
                    //     dateTimeSelected == null) {
                    //   Toaster.showToastCenter(AppLocalization.instance
                    //       .getLocalizationFor("select_travel_datetime"));
                    //   return;
                    // }
                    _onContinue();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearLocation(String tag) {
    if (tag == "src") {
      _sourceCity = null;
      _sourceAddress = null;
      _sourceLatlng = null;
      _sourceLocationController.clear();
    } else {
      _destinationCity = null;
      _destinationAddress = null;
      _destinationLatlng = null;
      _destinationLocationController.clear();
    }
    _myMapStateKey.currentState!.clearMarkerWithId(tag);
    _myMapStateKey.currentState!.clearPolyline();
    if (_myMapStateKey.currentState!.mapData.markers.length == 1) {
      _myMapStateKey.currentState!.moveCamera(
          _myMapStateKey.currentState!.mapData.markers.values.first.position);
    }
  }

  void _setupLocation(
      String? tag, String? city, String address, LatLng latLng) {
    _latLngsChanged = false;
    if (_sourceLatlng != latLng || _destinationLatlng != latLng) {
      _latLngsChanged = true;
    }
    if (tag == "src") {
      _sourceCity = city;
      _sourceAddress = address;
      _sourceLatlng = latLng;
      _sourceLocationController.text = address;
    } else {
      _destinationCity = city;
      _destinationAddress = address;
      _destinationLatlng = latLng;
      _destinationLocationController.text = address;
    }
    _updateLocationOnMap(tag, latLng);
    if (_latLngsChanged &&
        _sourceLatlng != null &&
        _destinationLatlng != null) {
      Loader.showLoader(context);
      MyMapHelper.getPolyLine(
        color: Theme.of(context).primaryColor,
        source: _sourceLatlng!,
        destination: _destinationLatlng!,
      ).then((Polyline pl) {
        Loader.dismissLoader(context);
        _myMapStateKey.currentState!.addPolyline(pl);
      });
    }
    _tag = null;
    LocalDataLayer().addRecentSearches(Address(
        -2,
        "address_type_recent",
        address,
        latLng.longitude,
        latLng.latitude,
        null,
        null,
        null,
        null,
        null,
        city,
        null,
        null));
  }

  Future<void> _updateLocationOnMap(String? tag, LatLng latLng) async {
    if (_myMapStateKey.currentState != null) {
      if (_myMapStateKey.currentState!.hasMarkerWithId(tag ?? "src")) {
        _myMapStateKey.currentState!.updateMarkerLocation(tag ?? "src", latLng);
      } else {
        BitmapDescriptor bitmapDescriptor =
            await MyMapHelper.createBitmapDescriptorFromImage(
                tag == "src"
                    ? "assets/ic_location.png"
                    : "assets/ic_destination.png",
                "");
        _myMapStateKey.currentState!
            .addMarker(tag ?? "src", bitmapDescriptor, latLng);
      }
      if (_myMapStateKey.currentState!.mapData.markers.length > 1) {
        await _myMapStateKey.currentState!.adjustMapZoom();
      } else {
        await _myMapStateKey.currentState!.moveCamera(latLng);
      }
    }
  }

  // void _getPredictions(String tag) => LocalDataLayer()
  //     .getCurrentLanguage()
  //     .then((String currLang) => PlacesAutocomplete.show(
  //           context: context,
  //           apiKey: AppConfig.googleApiKey,
  //           language: currLang,
  //           mode: Mode.fullscreen,
  //           types: [],
  //           components: [],
  //           strictbounds: false,
  //           resultTextStyle: Theme.of(context).textTheme.titleSmall,
  //           onError: (response) {
  //             if (kDebugMode) {
  //               print("PlacesAutocomplete: $response");
  //             }
  //           },
  //         ).then((prediction) {
  //           if (prediction != null) {
  //             _fetcherCubit.initFetchPredictionAddress(tag, prediction);
  //           }
  //         }));

  void _showAutocompleteScreen(
      BuildContext context, double? latitude, double? longitude) async {
    final lang = await LocalDataLayer().getCurrentLanguage();
    final prediction = await PlacesAutocomplete.show(
      context: context,
      apiKey: AppConfig.googleApiKey,
      language: lang,
      textDecoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      mode: Mode.fullscreen,
      strictbounds: false,
      location: latitude != null && longitude != null
          ? Location(lat: latitude, lng: longitude)
          : null,
      radius: 50000, // 50km radius
      resultTextStyle: Theme.of(context).textTheme.titleSmall,
      onError: (response) {
        if (kDebugMode) {
          print("PlacesAutocomplete Error: $response");
        }
      },
    );

    if (prediction != null) {
      _fetcherCubit.initFetchPredictionAddress(_tag, prediction);
    }
  }

  void _selectVehicleTypes() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => VehicleTypeSheet(
          latitudeFrom: _sourceLatlng?.latitude.toString(),
          longitudeFrom: _sourceLatlng?.longitude.toString(),
          //cityFrom: _sourceCity,
          latitudeTo: _destinationLatlng?.latitude.toString(),
          longitudeTo: _destinationLatlng?.longitude.toString(),
          //cityTo: _destinationCity,
          rideType: widget.rideType,
        ),
      ).then(
        (value) async {
          if (value != null &&
              value is Map &&
              value["vehicle_type"] != null &&
              value["payment_method"] != null) {
            VehicleType vehicleType = value["vehicle_type"];
            PaymentMethod paymentMethod = value["payment_method"];
            Coupon? coupon = value["coupon"];
            if (coupon != null) {
              await ConfirmDialog.showConfirmation(
                  context,
                  Text(
                      AppLocalization.instance.getLocalizationFor("promoCode")),
                  Text(
                      "${coupon.title} ${AppLocalization.instance.getLocalizationFor("will_applied")}"),
                  null,
                  AppLocalization.instance.getLocalizationFor("okay"));
            }
            _fetcherCubit.initCreateRide(RideRequest(
              payment_method_slug: paymentMethod.slug!,
              vehicle_type_id: vehicleType.id,
              is_scheduled: dateTimeSelected == null ? 0 : 1,
              type: widget.rideType,
              ride_on: DateFormat("yyyy-MM-dd HH:mm")
                  .format(dateTimeSelected?.toUtc() ?? DateTime.now().toUtc()),
              address_from: _sourceAddress!,
              latitude_from: _sourceLatlng!.latitude.toString(),
              longitude_from: _sourceLatlng!.longitude.toString(),
              //from_city: _sourceCity,
              address_to: _destinationAddress!,
              latitude_to: _destinationLatlng!.latitude.toString(),
              longitude_to: _destinationLatlng!.longitude.toString(),
              //to_city: _destinationCity,
              coupon_code: coupon?.code ?? "",
              meta: jsonEncode({
                "ride_otp": Helper.getRandomOtp().toString(),
              }),
            ));
          }
        },
      );

  void _selectPickDropDetails() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PickDropDetailsSheet(
          type: "from",
          address: _sourceAddress ?? "",
          values: requestMetaMap,
        ),
      ).then(
        (valueFrom) {
          if (valueFrom != null && valueFrom is Map<String, String>) {
            _setupRequestMetaMap(valueFrom, "from");
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PickDropDetailsSheet(
                type: "to",
                address: _destinationAddress ?? "",
                values: requestMetaMap,
              ),
            ).then((valueTo) {
              if (valueTo != null && valueTo is Map<String, String>) {
                _setupRequestMetaMap(valueTo, "to");
                _confirmPackageDetails();
              }
            });
          }
        },
      );

  void _confirmPackageDetails() => Navigator.pushNamed(
        context,
        PageRoutes.confirmPackageOrderDetailsPage,
        arguments: {
          ...requestMetaMap,
          "address_from": _sourceAddress,
          "address_to": _destinationAddress,
          "latitude_from": _sourceLatlng!.latitude.toString(),
          "longitude_from": _sourceLatlng!.longitude.toString(),
          "latitude_to": _destinationLatlng!.latitude.toString(),
          'longitude_to': _destinationLatlng!.longitude.toString(),
          "ride_type": widget.rideType,
        },
      ).then(
        (value) {
          if (value != null &&
              value is Map &&
              value["package_type"] != null &&
              value["vehicle_type"] != null &&
              value["payment_method"] != null) {
            String packageType = value["package_type"];
            VehicleType vehicleType = value["vehicle_type"];
            PaymentMethod paymentMethod = value["payment_method"];
            Coupon? coupon = value["coupon"];
            _fetcherCubit.initCreateRide(RideRequest(
              payment_method_slug: paymentMethod.slug!,
              vehicle_type_id: vehicleType.id,
              is_scheduled: 0,
              type: "courier",
              ride_on:
                  DateFormat("yyyy-MM-dd HH:mm").format(DateTime.now().toUtc()),
              address_from: _sourceAddress!,
              latitude_from: _sourceLatlng!.latitude.toString(),
              longitude_from: _sourceLatlng!.longitude.toString(),
              //from_city: _sourceCity,
              address_to: _destinationAddress!,
              latitude_to: _destinationLatlng!.latitude.toString(),
              longitude_to: _destinationLatlng!.longitude.toString(),
              //to_city: _destinationCity,
              coupon_code: coupon?.code ?? "",
              meta: jsonEncode({
                ...requestMetaMap,
                "package_type": packageType,
              }),
            ));
          }
        },
      );

  void _setupRequestMetaMap(Map<String, String> valueFrom, String type) {
    if (valueFrom["landmark_$type"] != null) {
      requestMetaMap["landmark_$type"] = valueFrom["landmark_$type"]!;
    }
    if (valueFrom["name_$type"] != null) {
      requestMetaMap["name_$type"] = valueFrom["name_$type"]!;
    }
    if (valueFrom["phone_$type"] != null) {
      requestMetaMap["phone_$type"] = valueFrom["phone_$type"]!;
    }
  }

  Future<void> _setupRideData(Ride ride) async {
    _sourceLocationController.text = ride.address_from;
    _destinationLocationController.text = ride.address_to;
    _sourceAddress = ride.address_from;
    _destinationAddress = ride.address_to;
    _sourceLatlng = LatLng(double.tryParse(ride.latitude_from) ?? 0,
        double.tryParse(ride.longitude_from) ?? 0);
    _destinationLatlng = LatLng(double.tryParse(ride.latitude_to) ?? 0,
        double.tryParse(ride.longitude_to) ?? 0);

    await _updateLocationOnMap("src", _sourceLatlng!);
    await Future.delayed(const Duration(milliseconds: 500));
    await _updateLocationOnMap("dst", _destinationLatlng!);

    if (ride.is_scheduled == 1) {
      dateTimeSelected = DateTime.parse(ride.ride_on);
      dateSelected = DateTime.parse(ride.ride_on);
      timeSelected = TimeOfDay.fromDateTime(dateTimeSelected!);
      dateTimeSelectedFormatted = Helper.setupDateTimeFromMillis(
          dateTimeSelected!.millisecondsSinceEpoch, true, true);
    }

    if (ride.meta != null && ride.meta is Map) {
      ride.meta.forEach((key, value) {
        if (key != "package_type" && key != "ride_otp" && value is String) {
          requestMetaMap[key] = value;
        }
      });
    }

    setState(() {});

    Loader.showLoader(context);
    MyMapHelper.getPolyLine(
      color: darken(Theme.of(context).primaryColor),
      source: _sourceLatlng!,
      destination: _destinationLatlng!,
    ).then((Polyline pl) {
      Loader.dismissLoader(context);
      _myMapStateKey.currentState!.addPolyline(pl);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (context.mounted) {
          _onContinue();
        }
      });
    });
  }

  void _onContinue() {
    if (widget.rideType == "courier") {
      _selectPickDropDetails();
    } else {
      _selectVehicleTypes();
    }
  }
}
