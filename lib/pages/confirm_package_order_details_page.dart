import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/vehicle_type.dart';
import 'package:deligo/pages/package_vehicle_type_sheet.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package_type_sheet.dart';

class ConfirmPackageOrderDetailsPage extends StatelessWidget {
  const ConfirmPackageOrderDetailsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: ConfirmPackageOrderDetailsStateful(
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>),
      );
}

class ConfirmPackageOrderDetailsStateful extends StatefulWidget {
  final Map<String, dynamic> arguments;

  const ConfirmPackageOrderDetailsStateful(this.arguments, {super.key});

  @override
  State<ConfirmPackageOrderDetailsStateful> createState() =>
      _ConfirmPackageOrderDetailsStatefulState();
}

class _ConfirmPackageOrderDetailsStatefulState
    extends State<ConfirmPackageOrderDetailsStateful> {
  late FetcherCubit _fetcherCubit;
  final TextEditingController _packageType = TextEditingController();
  List<VehicleType> _vehicleTypes = [];
  bool _isLoading = true;

  @override
  void initState() {
    _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
    super.initState();
    _fetcherCubit.initFetchVehicleTypes(
      latitudeFrom: widget.arguments["latitude_from"],
      latitudeTo: widget.arguments["latitude_to"],
      longitudeFrom: widget.arguments["longitude_from"],
      longitudeTo: widget.arguments["longitude_to"],
      rideType: widget.arguments["ride_type"],
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is VehicleTypeLoaded) {
          _vehicleTypes = state.vehicleTypes;
          _isLoading = false;
          setState(() {});
        }
        if (state is VehicleTypeFail) {
          _isLoading = false;
          setState(() {});
        }
      },
      child: Scaffold(
        appBar: RegularAppBar(
          title: AppLocalization.instance.getLocalizationFor("confirm_order"),
        ),
        //backgroundColor: theme.colorScheme.surface,
        body: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 12,
                color: theme.cardColor,
              ),
              Container(
                //color: theme.cardColor,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
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
                        const SizedBox(width: 14),
                        Text(
                          widget.arguments["name_from"],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.arguments["phone_from"],
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: theme.hintColor),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            CircleAvatar(
                              radius: 2,
                              backgroundColor: theme.hintColor,
                            ),
                            const SizedBox(height: 6),
                            CircleAvatar(
                              radius: 2,
                              backgroundColor: theme.hintColor,
                            ),
                            const SizedBox(height: 6),
                            CircleAvatar(
                              radius: 2,
                              backgroundColor: theme.hintColor,
                            ),
                            const SizedBox(height: 6),
                            CircleAvatar(
                              radius: 2,
                              backgroundColor: theme.hintColor,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                        const SizedBox(width: 22),
                        Expanded(
                          child: Text(
                            widget.arguments["address_from"],
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: theme.primaryColor,
                          child: Icon(
                            Icons.navigation,
                            size: 13,
                            color: theme.scaffoldBackgroundColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          widget.arguments["name_to"],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.arguments["phone_to"],
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 34),
                        Expanded(
                          child: Text(
                            widget.arguments["address_to"],
                            style: theme.textTheme.bodySmall
                                ?.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 12,
                color: theme.cardColor,
              ),
              Container(
                //color: theme.cardColor,
                padding: const EdgeInsets.all(16),
                child: CustomTextField(
                  prefixIcon: Icon(Icons.assignment, color: theme.hintColor),
                  hintText: AppLocalization.instance
                      .getLocalizationFor("selectPackageType"),
                  readOnly: true,
                  suffixIcon:
                      Icon(Icons.arrow_drop_down_sharp, color: theme.hintColor),
                  controller: _packageType,
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) =>
                        PackageTypeSheet(value: _packageType.text),
                  ).then(
                    (value) {
                      if (value != null) {
                        _packageType.text = value;
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: VehicleTypeBottomSheet(
          vehicleTypes: _vehicleTypes,
          isLoading: _isLoading,
          packageType: _packageType.text,
          arguments: widget.arguments,
        ),
      ),
    );
  }
  // late FetcherCubit _fetcherCubit;
  // final TextEditingController _packageType = TextEditingController();
  // List<VehicleType> _vehicleTypes = [];
  // VehicleType? _vehicleTypeSelected;
  // PaymentMethod? _paymentMethodSelected;
  // Coupon? _coupon;
  // bool _isLoading = true;
  // final _scrollController = ScrollController();

  // @override
  // void initState() {
  //   _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
  //   super.initState();
  //   _fetcherCubit.initFetchVehicleTypes(
  //     latitudeFrom: widget.arguments["latitude_from"],
  //     latitudeTo: widget.arguments["latitude_to"],
  //     longitudeFrom: widget.arguments["longitude_from"],
  //     longitudeTo: widget.arguments["longitude_to"],
  //     rideType: widget.arguments["ride_type"],
  //   );
  // }

  // @override
  // Widget build(BuildContext context) {
  //   ThemeData theme = Theme.of(context);
  //   return BlocListener<FetcherCubit, FetcherState>(
  //     listener: (context, state) {
  //       if (state is VehicleTypeLoaded) {
  //         _vehicleTypes = state.vehicleTypes;
  //         _isLoading = false;
  //         setState(() {});
  //       }
  //       if (state is VehicleTypeFail) {
  //         _isLoading = false;
  //         setState(() {});
  //       }
  //     },
  //     child: Scaffold(
  //       appBar: AppBar(
  //         title: Text(
  //             AppLocalization.instance.getLocalizationFor("confirm_order")),
  //       ),
  //       //backgroundColor: theme.colorScheme.surface,
  //       body: Column(
  //         // mainAxisAlignment: MainAxisAlignment.start,
  //         // crossAxisAlignment: CrossAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           Container(
  //             height: 12,
  //             color: disabledColor,
  //           ),
  //           Container(
  //             //color: theme.cardColor,
  //             padding: const EdgeInsets.all(16),
  //             child: Column(
  //               children: [
  //                 Row(
  //                   children: [
  //                     CircleAvatar(
  //                       radius: 11,
  //                       backgroundColor: theme.primaryColor,
  //                       child: Icon(
  //                         Icons.location_on,
  //                         size: 13,
  //                         color: theme.scaffoldBackgroundColor,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 14),
  //                     Text(
  //                       widget.arguments["name_from"],
  //                       style: theme.textTheme.titleMedium?.copyWith(
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                     const Spacer(),
  //                     Text(
  //                       widget.arguments["phone_from"],
  //                       style: theme.textTheme.titleMedium?.copyWith(
  //                           fontWeight: FontWeight.w500,
  //                           color: theme.hintColor),
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                   children: [
  //                     const SizedBox(width: 8),
  //                     Column(
  //                       children: [
  //                         const SizedBox(height: 20),
  //                         CircleAvatar(
  //                           radius: 2,
  //                           backgroundColor: theme.hintColor,
  //                         ),
  //                         const SizedBox(height: 6),
  //                         CircleAvatar(
  //                           radius: 2,
  //                           backgroundColor: theme.hintColor,
  //                         ),
  //                         const SizedBox(height: 6),
  //                         CircleAvatar(
  //                           radius: 2,
  //                           backgroundColor: theme.hintColor,
  //                         ),
  //                         const SizedBox(height: 6),
  //                         CircleAvatar(
  //                           radius: 2,
  //                           backgroundColor: theme.hintColor,
  //                         ),
  //                         const SizedBox(height: 20),
  //                       ],
  //                     ),
  //                     const SizedBox(width: 22),
  //                     Expanded(
  //                       child: Text(
  //                         widget.arguments["address_from"],
  //                         style:
  //                             theme.textTheme.bodySmall?.copyWith(fontSize: 14),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 Row(
  //                   children: [
  //                     CircleAvatar(
  //                       radius: 11,
  //                       backgroundColor: theme.primaryColor,
  //                       child: Icon(
  //                         Icons.navigation,
  //                         size: 13,
  //                         color: theme.scaffoldBackgroundColor,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 14),
  //                     Text(
  //                       widget.arguments["name_to"],
  //                       style: theme.textTheme.titleMedium?.copyWith(
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                     const Spacer(),
  //                     Text(
  //                       widget.arguments["phone_to"],
  //                       style: theme.textTheme.titleMedium?.copyWith(
  //                         fontWeight: FontWeight.w500,
  //                         color: theme.hintColor,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 10),
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     const SizedBox(width: 34),
  //                     Expanded(
  //                       child: Text(
  //                         widget.arguments["address_to"],
  //                         style:
  //                             theme.textTheme.bodySmall?.copyWith(fontSize: 14),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Container(
  //             height: 12,
  //             color: disabledColor,
  //           ),
  //           Container(
  //             //color: theme.cardColor,
  //             padding: const EdgeInsets.all(16),
  //             child: CustomTextField(
  //               prefixIcon: Icon(Icons.assignment, color: theme.hintColor),
  //               hintText: AppLocalization.instance
  //                   .getLocalizationFor("selectPackageType"),
  //               readOnly: true,
  //               suffixIcon:
  //                   Icon(Icons.arrow_drop_down_sharp, color: theme.hintColor),
  //               controller: _packageType,
  //               onTap: () => showModalBottomSheet(
  //                 context: context,
  //                 isScrollControlled: true,
  //                 shape: const RoundedRectangleBorder(
  //                   borderRadius:
  //                       BorderRadius.vertical(top: Radius.circular(20)),
  //                 ),
  //                 builder: (context) =>
  //                     PackageTypeSheet(value: _packageType.text),
  //               ).then(
  //                 (value) {
  //                   if (value != null) {
  //                     _packageType.text = value;
  //                     setState(() {});
  //                   }
  //                 },
  //               ),
  //             ),
  //           ),
  //           Container(
  //             height: 12,
  //             color: disabledColor,
  //           ),
  //           Container(
  //             //color: theme.cardColor,
  //             padding: const EdgeInsets.all(16),
  //             child: Text(
  //               AppLocalization.instance
  //                   .getLocalizationFor("selectDeliveryMode"),
  //               style: theme.textTheme.titleSmall
  //                   ?.copyWith(fontWeight: FontWeight.w500),
  //             ),
  //           ),
  //           Expanded(
  //             child: Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 16),
  //               //color: theme.cardColor,
  //               child: _vehicleTypes.isNotEmpty
  //                   ? Scrollbar(
  //                       controller: _scrollController,
  //                       thumbVisibility: true,
  //                       interactive: true,
  //                       thickness: 8.0,
  //                       radius: const Radius.circular(10),
  //                       child: ListView.separated(
  //                         controller: _scrollController,
  //                         shrinkWrap: true,
  //                         //itemCount: _vehicleTypes.length,
  //                         itemCount: 100,
  //                         separatorBuilder: (context, index) =>
  //                             const SizedBox(height: 10),
  //                         itemBuilder: (context, i) {
  //                           int index = 0;
  //                           return GestureDetector(
  //                             onTap: () => setState(() =>
  //                                 _vehicleTypeSelected = _vehicleTypes[index]),
  //                             child: Container(
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.circular(8),
  //                                 color: (_vehicleTypeSelected?.id ?? -1) ==
  //                                         _vehicleTypes[index].id
  //                                     ? unselectedItemColor
  //                                     : null,
  //                                 border: Border.all(
  //                                   color: theme.dividerColor,
  //                                   width: 0.5,
  //                                 ),
  //                               ),
  //                               child: Row(
  //                                 children: [
  //                                   Padding(
  //                                     padding: const EdgeInsets.all(8.0),
  //                                     child: CachedImage(
  //                                       imageUrl:
  //                                           _vehicleTypes[index].image_url,
  //                                       imagePlaceholder: Assets.assetsIcCab,
  //                                       width: 70,
  //                                       height: 70,
  //                                       fit: BoxFit.contain,
  //                                     ),
  //                                   ),
  //                                   const SizedBox(width: 20),
  //                                   Expanded(
  //                                     child: Column(
  //                                       crossAxisAlignment:
  //                                           CrossAxisAlignment.start,
  //                                       children: [
  //                                         Row(
  //                                           children: [
  //                                             Expanded(
  //                                               child: Text(
  //                                                 _vehicleTypes[index].title,
  //                                                 style: theme
  //                                                     .textTheme.titleSmall
  //                                                     ?.copyWith(fontSize: 15),
  //                                               ),
  //                                             ),
  //                                             Text(
  //                                               "${AppSettings.currencyIcon} ${_vehicleTypes[index].fare.toStringAsFixed(2)}",
  //                                               style: theme
  //                                                   .textTheme.titleSmall
  //                                                   ?.copyWith(
  //                                                 fontSize: 15,
  //                                                 fontWeight: FontWeight.w600,
  //                                               ),
  //                                             ),
  //                                             const SizedBox(width: 20),
  //                                           ],
  //                                         ),
  //                                         const SizedBox(height: 6),
  //                                         Row(
  //                                           children: [
  //                                             Icon(
  //                                               Icons.shopping_bag,
  //                                               color: theme.hintColor,
  //                                               size: 14,
  //                                             ),
  //                                             const SizedBox(width: 6),
  //                                             Text(
  //                                               "${_vehicleTypes[index].weightCapacity ?? "0"} Kg",
  //                                               style: theme.textTheme.bodySmall
  //                                                   ?.copyWith(fontSize: 13),
  //                                             ),
  //                                             const SizedBox(width: 8),
  //                                             CircleAvatar(
  //                                               radius: 2,
  //                                               backgroundColor:
  //                                                   theme.dividerColor,
  //                                             ),
  //                                             const SizedBox(width: 8),
  //                                             Icon(
  //                                               Icons.person,
  //                                               color: theme.hintColor,
  //                                               size: 14,
  //                                             ),
  //                                             const SizedBox(width: 6),
  //                                             Text(
  //                                               _vehicleTypes[index]
  //                                                   .seats
  //                                                   .toString(),
  //                                               style: theme.textTheme.bodySmall
  //                                                   ?.copyWith(fontSize: 13),
  //                                             ),
  //                                           ],
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 ],
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                       ),
  //                     )
  //                   : _isLoading
  //                       ? Loader.circularProgressIndicatorPrimary(context)
  //                       : Padding(
  //                           padding: const EdgeInsets.all(32.0),
  //                           child: ErrorFinalWidget.errorWithRetry(
  //                             context: context,
  //                             message: AppLocalization.instance
  //                                 .getLocalizationFor("empty_vehicle_types"),
  //                             actionText: AppLocalization.instance
  //                                 .getLocalizationFor("okay"),
  //                             action: () => Navigator.pop(context),
  //                           ),
  //                         ),
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //         ],
  //       ),
  //       bottomNavigationBar: Material(
  //         color: theme.scaffoldBackgroundColor,
  //         elevation: 20,
  //         child: Padding(
  //           padding:
  //               const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Row(
  //                 children: [
  //                   InkWell(
  //                     onTap: () => _selectPaymentMethod(),
  //                     child: Row(
  //                       children: [
  //                         Image.asset(
  //                           _paymentMethodSelected?.imageAsset ??
  //                               Assets.paymentVecWallet,
  //                           width: 20,
  //                           height: 20,
  //                           color: _paymentMethodSelected == null
  //                               ? theme.hintColor
  //                               : null,
  //                         ),
  //                         const SizedBox(width: 10),
  //                         Text(
  //                           _paymentMethodSelected?.title ??
  //                               AppLocalization.instance
  //                                   .getLocalizationFor("selectPaymentMethod"),
  //                           style: theme.textTheme.titleSmall,
  //                         ),
  //                         const SizedBox(width: 8),
  //                         const Icon(
  //                           Icons.arrow_forward_ios,
  //                           size: 12,
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                   const Spacer(),
  //                   InkWell(
  //                     onTap: () => Navigator.pushNamed(
  //                       context,
  //                       PageRoutes.couponPage,
  //                       arguments: {"pick": true},
  //                     ).then((value) {
  //                       if (value is Coupon) {
  //                         setState(() => _coupon = value);
  //                       }
  //                     }),
  //                     child: Container(
  //                       padding: const EdgeInsets.symmetric(
  //                           horizontal: 12, vertical: 8),
  //                       decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(6),
  //                         border: Border.all(
  //                           color: theme.dividerColor,
  //                           width: 0.5,
  //                         ),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           const Icon(
  //                             Icons.local_offer,
  //                             size: 14,
  //                           ),
  //                           const SizedBox(width: 12),
  //                           Text(
  //                             _coupon?.code ??
  //                                 AppLocalization.instance
  //                                     .getLocalizationFor("promoCode"),
  //                             style: theme.textTheme.titleSmall
  //                                 ?.copyWith(fontSize: 12),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const SizedBox(height: 10),
  //               CustomButton(
  //                 text: AppLocalization.instance.getLocalizationFor("next"),
  //                 onTap: () {
  //                   if (_packageType.text.trim().isEmpty) {
  //                     Toaster.showToastBottom(AppLocalization.instance
  //                         .getLocalizationFor("selectPackageType"));
  //                     return;
  //                   }
  //                   if (_vehicleTypeSelected == null) {
  //                     Toaster.showToastBottom(AppLocalization.instance
  //                         .getLocalizationFor("chooseRideOrSwipeUp"));
  //                     return;
  //                   }
  //                   if (_paymentMethodSelected == null) {
  //                     Toaster.showToastBottom(AppLocalization.instance
  //                         .getLocalizationFor("selectPaymentMethod"));
  //                     _selectPaymentMethod();
  //                     return;
  //                   }
  //                   Navigator.pop(context, {
  //                     "package_type": _packageType.text.trim(),
  //                     "vehicle_type": _vehicleTypeSelected,
  //                     "payment_method": _paymentMethodSelected,
  //                     "coupon": _coupon
  //                   });
  //                 },
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // @override
  // void dispose() {
  //   _scrollController.dispose();
  //   super.dispose();
  // }

  // void _selectPaymentMethod() => showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       backgroundColor: Colors.transparent,
  //       shape: const RoundedRectangleBorder(
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
  //       builder: (context) => PaymentMethodSheet(value: _paymentMethodSelected),
  //     ).then(
  //       (value) {
  //         if (value != null) {
  //           _paymentMethodSelected = value;
  //           setState(() {});
  //         }
  //       },
  //     );
}
