import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/assets.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/coupon.dart';
import 'package:deligo/models/payment_method.dart';
import 'package:deligo/models/vehicle_type.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/toaster.dart';

import 'payment_method_sheet.dart';

class VehicleTypeSheet extends StatelessWidget {
  final String? latitudeFrom;
  final String? longitudeFrom;
  final String? cityFrom;
  final String? latitudeTo;
  final String? longitudeTo;
  final String? cityTo;
  final String? rideType;

  const VehicleTypeSheet({
    super.key,
    this.latitudeFrom,
    this.longitudeFrom,
    this.cityFrom,
    this.latitudeTo,
    this.longitudeTo,
    this.cityTo,
    this.rideType,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: VehicleTypeStateful(
          latitudeFrom: latitudeFrom,
          longitudeFrom: longitudeFrom,
          cityFrom: cityFrom,
          latitudeTo: latitudeTo,
          longitudeTo: longitudeTo,
          cityTo: cityTo,
          rideType: rideType,
        ),
      );
}

class VehicleTypeStateful extends StatefulWidget {
  final String? latitudeFrom;
  final String? longitudeFrom;
  final String? cityFrom;
  final String? latitudeTo;
  final String? longitudeTo;
  final String? cityTo;
  final String? rideType;

  const VehicleTypeStateful({
    super.key,
    this.latitudeFrom,
    this.longitudeFrom,
    this.cityFrom,
    this.latitudeTo,
    this.longitudeTo,
    this.cityTo,
    this.rideType,
  });

  @override
  State<VehicleTypeStateful> createState() => _VehicleTypeStatefulState();
}

class _VehicleTypeStatefulState extends State<VehicleTypeStateful> {
  VehicleType? _vehicleTypeSelected;
  PaymentMethod? _paymentMethodSelected;
  Coupon? _coupon;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetcherCubit>(context).initFetchVehicleTypes(
      latitudeFrom: widget.latitudeFrom,
      longitudeFrom: widget.longitudeFrom,
      cityFrom: widget.cityFrom,
      latitudeTo: widget.latitudeTo,
      longitudeTo: widget.longitudeTo,
      cityTo: widget.cityTo,
      rideType: widget.rideType,
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocBuilder<FetcherCubit, FetcherState>(
      builder: (context, state) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 14),
            Text(
              AppLocalization.instance.getLocalizationFor(
                  state is VehicleTypeLoaded && state.vehicleTypes.isNotEmpty
                      ? "chooseRideOrSwipeUp"
                      : "ride_options"),
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
            const SizedBox(height: 18),
            Flexible(
              child: state is VehicleTypeLoaded && state.vehicleTypes.isNotEmpty
                  ? Scrollbar(
                      controller: _scrollController,
                      thumbVisibility: true,
                      interactive: true,
                      thickness: 8.0,
                      radius: const Radius.circular(10),
                      child: ListView.separated(
                        controller: _scrollController,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        itemCount: state.vehicleTypes.length,
                        //itemCount: 100,
                        itemBuilder: (context, index) {
                          //int index = 0;
                          return InkWell(
                            onTap: () => setState(() => _vehicleTypeSelected =
                                state.vehicleTypes[index]),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: (_vehicleTypeSelected?.id ?? -1) ==
                                          state.vehicleTypes[index].id
                                      ? theme.primaryColor
                                      : theme.disabledColor,
                                  width: (_vehicleTypeSelected?.id ?? -1) ==
                                          state.vehicleTypes[index].id
                                      ? 3
                                      : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CachedImage(
                                      imageUrl:
                                          state.vehicleTypes[index].image_url,
                                      imagePlaceholder: Assets.assetsIcCab,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                state.vehicleTypes[index].title,
                                                style: theme
                                                    .textTheme.titleSmall
                                                    ?.copyWith(fontSize: 15),
                                              ),
                                            ),
                                            Text(
                                              "${AppSettings.currencyIcon} ${state.vehicleTypes[index].fare.toStringAsFixed(2)}",
                                              style: theme.textTheme.titleSmall
                                                  ?.copyWith(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            if (state.vehicleTypes[index]
                                                    .estimated_time !=
                                                null) ...[
                                              Text(
                                                state.vehicleTypes[index]
                                                    .estimated_time!,
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(fontSize: 13),
                                              ),
                                              const SizedBox(width: 8),
                                              CircleAvatar(
                                                radius: 2,
                                                backgroundColor:
                                                    theme.dividerColor,
                                              ),
                                              const SizedBox(width: 10),
                                            ],
                                            Icon(
                                              Icons.person,
                                              color: theme.dividerColor,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              state.vehicleTypes[index].seats
                                                  .toString(),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : state is VehicleTypeLoading
                      ? Loader.circularProgressIndicatorPrimary(context)
                      : Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: ErrorFinalWidget.errorWithRetry(
                            context: context,
                            message: AppLocalization.instance
                                .getLocalizationFor("empty_vehicle_types"),
                            actionText: AppLocalization.instance
                                .getLocalizationFor("okay"),
                            action: () => Navigator.pop(context),
                          ),
                        ),
            ),
            Material(
              color: theme.scaffoldBackgroundColor,
              elevation: 20,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 14.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _selectPaymentMethod(),
                          child: Row(
                            children: [
                              Image.asset(
                                _paymentMethodSelected?.imageAsset ??
                                    Assets.paymentVecWallet,
                                width: 20,
                                height: 20,
                                color: _paymentMethodSelected == null
                                    ? theme.hintColor
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _paymentMethodSelected?.title ??
                                    AppLocalization.instance.getLocalizationFor(
                                        "selectPaymentMethod"),
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => Navigator.pushNamed(
                            context,
                            PageRoutes.couponPage,
                            arguments: {"pick": true},
                          ).then((value) {
                            if (value is Coupon) {
                              setState(() => _coupon = value);
                            }
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.dividerColor,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.local_offer,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _coupon?.code ??
                                      AppLocalization.instance
                                          .getLocalizationFor("promoCode"),
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      text: AppLocalization.instance
                          .getLocalizationFor("continueText"),
                      margin: const EdgeInsets.symmetric(vertical: 20),
                      onTap: () {
                        if (_vehicleTypeSelected == null) {
                          Toaster.showToastBottom(AppLocalization.instance
                              .getLocalizationFor("chooseRideOrSwipeUp"));
                          return;
                        }
                        if (_paymentMethodSelected == null) {
                          Toaster.showToastBottom(AppLocalization.instance
                              .getLocalizationFor("selectPaymentMethod"));
                          _selectPaymentMethod();
                          return;
                        }
                        Navigator.pop(context, {
                          "vehicle_type": _vehicleTypeSelected,
                          "payment_method": _paymentMethodSelected,
                          "coupon": _coupon
                        });
                      },
                    ),
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
    _scrollController.dispose();
    super.dispose();
  }

  void _selectPaymentMethod() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        builder: (context) => PaymentMethodSheet(value: _paymentMethodSelected),
      ).then(
        (value) {
          if (value != null) {
            _paymentMethodSelected = value;
            setState(() {});
          }
        },
      );
}
