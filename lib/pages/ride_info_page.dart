import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/config/assets.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/chat.dart';
import 'package:deligo/models/ride.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/constants.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/utility/string_extensions.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/my_map_widget.dart';
import 'package:deligo/widgets/toaster.dart';

class RideInfoPage extends StatelessWidget {
  const RideInfoPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: RideInfoStateful(
            ride: ModalRoute.of(context)!.settings.arguments as Ride),
      );
}

class RideInfoStateful extends StatefulWidget {
  final Ride ride;

  const RideInfoStateful({super.key, required this.ride});

  @override
  State<RideInfoStateful> createState() => _RideInfoStatefulState();
}

class _RideInfoStatefulState extends State<RideInfoStateful> {
  late FetcherCubit _fetcherCubit;
  late Ride _ride;
  final GlobalKey<MyMapState> _myMapStateKey = GlobalKey();
  bool _ridePastHandled = false;
  bool _selfCancelled = false;

  @override
  void initState() {
    _ride = widget.ride;
    _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
    if (!_ride.isPast) {
      _fetcherCubit.registerRideUpdates(_ride);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is RideUpdateLoading) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }

        if (state is RideUpdateLoaded) {
          _ride = state.ride;
          _handleRideUpdate();
        }

        if (state is LocationUpdateLoaded) {
          _addUpdateDriverLocation(state.latLng);
        }
      },
      child: Scaffold(
        appBar: RegularAppBar(
          title:
              "${AppLocalization.instance.getLocalizationFor("ride").capitalizeFirst()} #${_ride.id}",
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
              onMapTap: (LatLng latLng) {},
              onBuildComplete: () => _setupMarkersAndPolyline(),
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
                          initialValue: _ride.address_from,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontSize: 14),
                          readOnly: true,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: AppLocalization.instance
                                .getLocalizationFor("startingPoint"),
                            hintStyle: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 14),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: theme.primaryColor,
                                child: Icon(
                                  Icons.location_on,
                                  color: theme.scaffoldBackgroundColor,
                                  size: 16,
                                ),
                              ),
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                          color: theme.cardColor,
                        ),
                        TextFormField(
                          initialValue: _ride.address_to,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontSize: 14),
                          readOnly: true,
                          decoration: InputDecoration(
                            isDense: true,
                            hintStyle: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 14),
                            hintText: AppLocalization.instance
                                .getLocalizationFor("whereToGo"),
                            prefixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
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
                            border: const OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DraggableScrollableSheet(
              maxChildSize: 0.5,
              builder:
                  (BuildContext context, ScrollController scrollController) =>
                      Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                        color: theme.primaryColor,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            height: 4,
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: theme.cardColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 0.0, bottom: 4, left: 8),
                                child: CachedImage(
                                  imageUrl: _ride.vehicle_type?.image_url,
                                  imagePlaceholder: Assets.deliveryTypeCar,
                                  width: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 40),
                              Text(
                                AppLocalization.instance
                                    .getLocalizationFor("estimated_time"),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.cardColor,
                                ),
                              ),
                              Text(
                                " ${Helper.formatDuration(Duration(minutes: _ride.estimated_time?.toInt() ?? 0))}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.cardColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            if (_ride.isOngoing) ...[
                              Divider(
                                thickness: 1,
                                height: 1,
                                color: theme.cardColor,
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      alignment: AlignmentDirectional.center,
                                      clipBehavior: Clip.none,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          child: CachedImage(
                                            imageUrl:
                                                _ride.driver?.user?.imageUrl,
                                            imagePlaceholder: Assets.emptyImage,
                                            height: 50,
                                            width: 50,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: -10,
                                          child: Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color:
                                                      const Color(0xFF009D06),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.star,
                                                      color: Colors.white,
                                                      size: 10,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      _ride.driver?.ratings
                                                              ?.toStringAsFixed(
                                                                  1) ??
                                                          "0",
                                                      style: theme
                                                          .textTheme.titleSmall
                                                          ?.copyWith(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _ride.driver?.user?.name ?? "",
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            fontSize: 15,
                                            color: theme.hintColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Text(
                                          _ride.driver?.vehicle_number ?? "",
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(fontSize: 13),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Text(
                                          _ride.vehicle_type?.title ?? "",
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () => Helper.launchURL(
                                          "tel:${_ride.driver?.user?.mobile_number}"),
                                      child: CircleAvatar(
                                        backgroundColor: theme.cardColor,
                                        child: Icon(
                                          Icons.call,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        PageRoutes.messagePage,
                                        arguments: {
                                          "chat": Chat(
                                            myId:
                                                "${_ride.user?.id}${Constants.roleUser}",
                                            chatId:
                                                "${_ride.driver?.user?.id}${Constants.roleDelivery}",
                                            chatImage:
                                                _ride.driver?.user?.imageUrl,
                                            chatName: _ride.driver?.user?.name,
                                            chatStatus: _ride
                                                .driver?.user?.mobile_number,
                                          ),
                                          "subtitle":
                                              "${AppLocalization.instance.getLocalizationFor("ride").capitalizeFirst()} #${_ride.id}",
                                        },
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: theme.cardColor,
                                        child: Icon(
                                          Icons.message_rounded,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            Divider(
                              thickness: 6,
                              height: 6,
                              color: theme.cardColor,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 11,
                                        backgroundColor: theme.primaryColor,
                                        child: Icon(
                                          Icons.location_on,
                                          size: 13,
                                          color: theme.scaffoldBackgroundColor,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ...List.generate(
                                        _ride.getMetaValue("landmark_from") !=
                                                null
                                            ? 7
                                            : 5,
                                        (index) => Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 2,
                                              backgroundColor: theme.hintColor,
                                            ),
                                            const SizedBox(height: 6)
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      CircleAvatar(
                                        radius: 11,
                                        backgroundColor: theme.primaryColor,
                                        child: Icon(
                                          Icons.navigation,
                                          size: 13,
                                          color: theme.scaffoldBackgroundColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _ride.getMetaValue("name_from") ??
                                              AppLocalization.instance
                                                  .getLocalizationFor(
                                                      "pickupFrom"),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(fontSize: 14),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _ride.address_from,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                        ),
                                        if (_ride.getMetaValue(
                                                "landmark_from") !=
                                            null)
                                          Text(
                                            _ride
                                                .getMetaValue("landmark_from")!,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w300,
                                            ),
                                            maxLines: 2,
                                          ),
                                        const SizedBox(height: 32),
                                        Text(
                                          _ride.getMetaValue("name_to") ??
                                              AppLocalization.instance
                                                  .getLocalizationFor(
                                                      "deliverTo"),
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(fontSize: 14),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          _ride.address_to,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (_ride.getMetaValue("landmark_to") !=
                                            null)
                                          Text(
                                            _ride.getMetaValue("landmark_to")!,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              thickness: 6,
                              height: 6,
                              color: theme.cardColor,
                            ),
                            const SizedBox(height: 20),
                            if (_ride.getMetaValue("package_type") != null)
                              buildAmountTile(
                                  theme,
                                  AppLocalization.instance
                                      .getLocalizationFor("packageType"),
                                  _ride.getMetaValue("package_type") ?? "")
                            else
                              buildAmountTile(
                                  theme,
                                  AppLocalization.instance
                                      .getLocalizationFor("rideOtp"),
                                  _ride.getMetaValue("ride_otp") ?? ""),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                indent: 20,
                                endIndent: 20,
                                color: theme.cardColor,
                              ),
                            ),
                            buildAmountTile(
                                theme,
                                AppLocalization.instance
                                    .getLocalizationFor("rideCost"),
                                _ride.fareFormatted ?? ""),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                indent: 20,
                                endIndent: 20,
                                color: theme.cardColor,
                              ),
                            ),
                            if (_ride.discount != null &&
                                _ride.discount != 0) ...[
                              buildAmountTile(
                                  theme,
                                  AppLocalization.instance
                                      .getLocalizationFor("discount"),
                                  "${AppSettings.currencyIcon} ${(_ride.discount ?? 0).toStringAsFixed(2)}"),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Divider(
                                  height: 1,
                                  indent: 20,
                                  endIndent: 20,
                                  color: theme.cardColor,
                                ),
                              ),
                            ],
                            buildAmountTile(
                                theme,
                                AppLocalization.instance
                                    .getLocalizationFor("paymentMethod"),
                                _ride.payment?.paymentMethod?.title ?? ""),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Divider(
                                height: 1,
                                indent: 20,
                                endIndent: 20,
                                color: theme.cardColor,
                              ),
                            ),
                            buildAmountTile(
                                theme,
                                AppLocalization.instance.getLocalizationFor(
                                    _ride.is_scheduled == 1
                                        ? "pickupDateTime"
                                        : "bookedOn"),
                                _ride.ride_on_formatted ?? ""),
                            const SizedBox(height: 20),
                            Divider(
                              thickness: 6,
                              height: 6,
                              color: theme.cardColor,
                            ),
                            if (_ride.isRequest)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 80,
                                  vertical: 40,
                                ),
                                child: CustomButton(
                                  onTap: () => ConfirmDialog.showConfirmation(
                                          context,
                                          Text(AppLocalization.instance
                                              .getLocalizationFor(
                                                  "cancel_ride")),
                                          Text(AppLocalization.instance
                                              .getLocalizationFor(
                                                  "cancel_ride_msg")),
                                          AppLocalization.instance
                                              .getLocalizationFor("no"),
                                          AppLocalization.instance
                                              .getLocalizationFor("yes"))
                                      .then((value) {
                                    if (value != null && value == true) {
                                      _selfCancelled = true;
                                      _fetcherCubit.initUpdateRide(
                                          _ride.id, "cancelled");
                                    }
                                  }),
                                  text: AppLocalization.instance
                                      .getLocalizationFor("cancelBooking"),
                                  buttonColor: const Color(0xFFF1D7D6),
                                  textColor: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fetcherCubit.initUnRegisterRideUpdates();
    super.dispose();
  }

  Padding buildAmountTile(ThemeData theme, String title, String amount) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall,
              ),
            ),
            Text(
              amount,
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
      );

  void _setupMarkersAndPolyline() {
    if (_myMapStateKey.currentState != null && mounted) {
      LatLng srcLatLng = LatLng(double.parse(_ride.latitude_from),
          double.parse(_ride.longitude_from));
      LatLng dstLatLng = LatLng(
          double.parse(_ride.latitude_to), double.parse(_ride.longitude_to));

      MyMapHelper.createBitmapDescriptorFromImage("assets/ic_location.png", "")
          .then((value) =>
              _myMapStateKey.currentState?.addMarker("src", value, srcLatLng));
      MyMapHelper.createBitmapDescriptorFromImage(
              "assets/ic_destination.png", "")
          .then((value) =>
              _myMapStateKey.currentState?.addMarker("dst", value, dstLatLng));

      MyMapHelper.getPolyLine(
        color: Theme.of(context).primaryColor,
        source: srcLatLng,
        destination: dstLatLng,
      ).then(
        (Polyline pl) {
          _myMapStateKey.currentState?.addPolyline(pl);
          Future.delayed(
            const Duration(milliseconds: 500),
            () => _myMapStateKey.currentState?.adjustMapZoom(),
          );
        },
      );
    }
  }

  void _addUpdateDriverLocation(LatLng latLng) {
    if (_myMapStateKey.currentState?.hasMarkerWithId("current_location") ??
        false) {
      _myMapStateKey.currentState
          ?.updateMarkerLocation("current_location", latLng);
    } else {
      MyMapHelper.createBitmapDescriptorFromImage("assets/ic_cab.png", "").then(
        (bitmapDescriptor) => _myMapStateKey.currentState
            ?.addMarker("current_location", bitmapDescriptor, latLng),
      );
    }
    _myMapStateKey.currentState?.adjustMapZoom();
    Future.delayed(const Duration(milliseconds: 500),
        () => _myMapStateKey.currentState?.moveCamera(latLng));
  }

  void _handleRideUpdate() {
    if (_ride.isPast) {
      if (!_ridePastHandled) {
        _ridePastHandled = true;
        _fetcherCubit.initUnRegisterRideUpdates();
        Toaster.showToastCenter(
          AppLocalization.instance
              .getLocalizationFor("ride_status_msg_${_ride.status}"),
        );
        Future.delayed(
          const Duration(milliseconds: 100),
          () async {
            if (_ride.status == "complete") {
              if (context.mounted) {
                Navigator.pushReplacementNamed(
                    context, PageRoutes.rideCompletePage,
                    arguments: _ride);
              }
            } else {
              if (_ride.status == "cancelled" && !_selfCancelled) {
                await LocalDataLayer().setTempRide(_ride);
                await LocalDataLayer().setTabUpdate(0, "ride_rejected");
              }
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
        );
      }
    } else {
      setState(() {});
    }
  }
}
