import 'package:deligo/config/assets.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/coupon.dart';
import 'package:deligo/models/payment_method.dart';
import 'package:deligo/models/vehicle_type.dart';
import 'package:deligo/pages/payment_method_sheet.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/toaster.dart';
import 'package:flutter/material.dart';

class VehicleTypeBottomSheet extends StatefulWidget {
  final List<VehicleType> vehicleTypes;
  final bool isLoading;
  final String packageType;
  final Map<String, dynamic> arguments;

  const VehicleTypeBottomSheet({
    super.key,
    required this.vehicleTypes,
    required this.isLoading,
    required this.packageType,
    required this.arguments,
  });

  @override
  State<VehicleTypeBottomSheet> createState() => _VehicleTypeBottomSheetState();
}

class _VehicleTypeBottomSheetState extends State<VehicleTypeBottomSheet>
    with SingleTickerProviderStateMixin {
  VehicleType? _vehicleTypeSelected;
  PaymentMethod? _paymentMethodSelected;
  Coupon? _coupon;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  static const double _collapsedHeight = 430.0;
  double _expandedHeight = 800.0;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightAnimation = Tween<double>(
      begin: _collapsedHeight,
      end: _expandedHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateExpandedHeight();
    });
  }

  @override
  void didUpdateWidget(VehicleTypeBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vehicleTypes.length != widget.vehicleTypes.length ||
        oldWidget.isLoading != widget.isLoading) {
      _updateExpandedHeight();
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _heightAnimation,
      builder: (context, child) {
        return GestureDetector(
          onPanUpdate: (details) {
            if (details.delta.dy < -5 && !_isExpanded) {
              _toggleExpansion();
            } else if (details.delta.dy > 5 && _isExpanded) {
              _toggleExpansion();
            }
          },
          child: Container(
            height: _heightAnimation.value,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  // onPanUpdate: (details) {
                  //   if (details.delta.dy < -5 && !_isExpanded) {
                  //     _toggleExpansion();
                  //   } else if (details.delta.dy > 5 && _isExpanded) {
                  //     _toggleExpansion();
                  //   }
                  // },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        Container(
                          height: 4,
                          width: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: theme.cardColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalization.instance.getLocalizationFor(
                              widget.vehicleTypes.isNotEmpty &&
                                      !widget.isLoading
                                  ? "chooseDeliveryModeOrSwipeUp"
                                  : "delivery_mode_options"),
                          style:
                              theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // Vehicle types list
                Expanded(
                  child: widget.isLoading
                      ? Loader.circularProgressIndicatorPrimary(context)
                      : widget.vehicleTypes.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: ErrorFinalWidget.errorWithRetry(
                                context: context,
                                message: AppLocalization.instance
                                    .getLocalizationFor("empty_vehicle_types"),
                                actionText: AppLocalization.instance
                                    .getLocalizationFor("okay"),
                                action: () => Navigator.pop(context),
                              ),
                            )
                          : NotificationListener<ScrollNotification>(
                              onNotification: (scrollNotification) {
                                if (!_isExpanded &&
                                    scrollNotification
                                        is ScrollUpdateNotification) {
                                  if (scrollNotification.scrollDelta! < -10) {
                                    _toggleExpansion();
                                    return true;
                                  }
                                }
                                return false;
                              },
                              child: Scrollbar(
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  itemCount: widget.vehicleTypes.length,
                                  //itemCount: 100,
                                  itemBuilder: (context, index) {
                                    //int index = 0;
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          _vehicleTypeSelected =
                                              widget.vehicleTypes[index];
                                        });
                                        _collapseAfterSelection();
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: (_vehicleTypeSelected?.id ??
                                                        -1) ==
                                                    widget
                                                        .vehicleTypes[index].id
                                                ? theme.primaryColor
                                                : theme.disabledColor,
                                            width: (_vehicleTypeSelected?.id ??
                                                        -1) ==
                                                    widget
                                                        .vehicleTypes[index].id
                                                ? 3
                                                : 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CachedImage(
                                                imageUrl: widget
                                                    .vehicleTypes[index]
                                                    .image_url,
                                                imagePlaceholder:
                                                    Assets.assetsIcCab,
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
                                                          widget
                                                              .vehicleTypes[
                                                                  index]
                                                              .title,
                                                          style: theme.textTheme
                                                              .titleSmall
                                                              ?.copyWith(
                                                                  fontSize: 15),
                                                        ),
                                                      ),
                                                      Text(
                                                        "${AppSettings.currencyIcon} ${widget.vehicleTypes[index].fare.toStringAsFixed(2)}",
                                                        style: theme.textTheme
                                                            .titleSmall
                                                            ?.copyWith(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 20),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      if (widget
                                                              .vehicleTypes[
                                                                  index]
                                                              .estimated_time !=
                                                          null) ...[
                                                        Text(
                                                          widget
                                                              .vehicleTypes[
                                                                  index]
                                                              .estimated_time!,
                                                          style: theme.textTheme
                                                              .bodySmall
                                                              ?.copyWith(
                                                                  fontSize: 13),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        CircleAvatar(
                                                          radius: 2,
                                                          backgroundColor: theme
                                                              .dividerColor,
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                      ],
                                                      Icon(
                                                        Icons.person,
                                                        color:
                                                            theme.dividerColor,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        widget
                                                            .vehicleTypes[index]
                                                            .seats
                                                            .toString(),
                                                        style: theme
                                                            .textTheme.bodySmall
                                                            ?.copyWith(
                                                                fontSize: 13),
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
                                        AppLocalization.instance
                                            .getLocalizationFor(
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
                            if (widget.packageType.trim().isEmpty) {
                              Toaster.showToastBottom(AppLocalization.instance
                                  .getLocalizationFor("selectPackageType"));
                              return;
                            }
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
                              "package_type": widget.packageType,
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
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateExpandedHeight() {
    const double headerHeight = 50.0;
    const double bottomSectionHeight = 140.0;
    const double itemHeight = 100.0;
    const double separatorHeight = 12.0;
    const double listPadding = 28.0;
    const double minListHeight = 100.0;

    double listHeight;

    if (widget.isLoading) {
      listHeight = minListHeight;
    } else if (widget.vehicleTypes.isEmpty) {
      listHeight = 200.0;
    } else {
      listHeight = (widget.vehicleTypes.length * itemHeight) +
          ((widget.vehicleTypes.length - 1) * separatorHeight) +
          listPadding;
    }

    _expandedHeight = headerHeight + listHeight + bottomSectionHeight;

    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    _expandedHeight = _expandedHeight > maxHeight ? maxHeight : _expandedHeight;

    _heightAnimation = Tween<double>(
      begin: _collapsedHeight,
      end: _expandedHeight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    setState(() {});
  }

  void _toggleExpansion() {
    _updateExpandedHeight();

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _collapseAfterSelection() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _animationController.reverse();
      });
    }
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
            setState(() {
              _paymentMethodSelected = value;
            });
          }
        },
      );
}
