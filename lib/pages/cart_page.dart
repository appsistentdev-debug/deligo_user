import 'dart:convert';

import 'package:deligo/models/user_data.dart';
import 'package:deligo/pages/order_type_sheet.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/bloc/payment_cubit.dart';
import 'package:deligo/config/assets.dart';
import 'package:deligo/config/colors.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/address.dart';
import 'package:deligo/models/coupon.dart';
import 'package:deligo/models/order_req.dart';
import 'package:deligo/models/order_req_addons.dart';
import 'package:deligo/models/order_req_product.dart';
import 'package:deligo/models/payment_method.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/cart_manager.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_divider.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/toaster.dart';

import 'payment_method_sheet.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: const CartStateful(),
      );
}

class CartStateful extends StatefulWidget {
  const CartStateful({super.key});

  @override
  State<CartStateful> createState() => _CartStatefulState();
}

class _CartStatefulState extends State<CartStateful> {
  final TextEditingController _instructionsController = TextEditingController();
  Address? _address;
  Coupon? _coupon;

  @override
  void initState() {
    CartManager().applyCoupon(null);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => LocalDataLayer().getSavedAddress().then((Address? sa) {
              setState(() => _address = sa);
              _refreshDeliveryFee();
            }));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is CouponValidityLoading ||
            state is WalletBalanceLoading ||
            state is CreateOrderLoading) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }
        if (state is DeliveryFeeLoaded) {
          CartManager().setDeliveryFee(state.deliveryFee.deliveryFee);
          setState(() {});
        }
        if (state is CouponValidityLoaded) {
          _coupon = state.coupon;
          CartManager().applyCoupon(state.coupon);
          setState(() {});
        }
        if (state is CouponValidityFail) {
          Toaster.showToastCenter(state.message);
        }
        if (state is WalletBalanceLoaded) {
          if (CartManager().cartTotal <= state.wallet.balance) {
            _confirmOrderTypeData("wallet");
          } else {
            Toaster.showToastCenter(AppLocalization.instance
                .getLocalizationFor("insufficient_wallet_balance"));
          }
        }
        if (state is WalletBalanceFail) {
          Toaster.showToastCenter(AppLocalization.instance
              .getLocalizationFor("wallet_verification_fail"));
        }
        if (state is CreateOrderLoaded) {
          Navigator.pushNamed(
            context,
            PageRoutes.processPaymentPage,
            arguments: state.paymentData,
          ).then((value) async {
            bool paid = value != null && value is PaymentStatus && value.isPaid;
            Toaster.showToastCenter(AppLocalization.instance.getLocalizationFor(
                paid ? "payment_success_message" : "payment_fail_message"));
            if (paid) {
              await LocalDataLayer().setTabUpdate(1,
                  "refresh_orders_${CartManager().orderMeta["category_slug"]}");
              await CartManager().clearCart();
              Navigator.popUntil(context, (route) => route.isFirst);
            } else {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          });
        }
        if (state is CreateOrderFail) {
          Toaster.showToastCenter(state.message);
        }
      },
      child: Scaffold(
        appBar: RegularAppBar(
            title: CartManager().cartItems.firstOrNull?.meta["vendor_name"] ??
                "Cart"),
        // appBar: AppBar(
        //   title: Text(
        //       CartManager().cartItems.firstOrNull?.meta["vendor_name"] ??
        //           "Cart"),
        //   centerTitle: false,
        // ),
        body: CartManager().cartItemsCount > 0
            ? Column(
                children: [
                  Container(
                    color: theme.scaffoldBackgroundColor,
                    child: const CustomDivider(),
                  ),
                  if (_address == null)
                    ListTile(
                      tileColor: theme.scaffoldBackgroundColor,
                      minVerticalPadding: 10,
                      leading: const Icon(
                        Icons.location_on,
                        size: 18,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppLocalization.instance
                                  .getLocalizationFor("address"),
                              style: theme.textTheme.bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        AppLocalization.instance
                            .getLocalizationFor("select_address_continue"),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey),
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        PageRoutes.savedAddressPage,
                        arguments: {"pick": true},
                      ).then(
                        (value) {
                          if (value is Address) {
                            LocalDataLayer().setSavedAddress(value);
                            _address = value;
                            setState(() {});
                            _refreshDeliveryFee();
                          }
                        },
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4),
                      color: theme.scaffoldBackgroundColor, // Mimic tileColor
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Icon(
                              _address!.title == "address_type_home"
                                  ? Icons.home
                                  : _address!.title == "address_type_office"
                                      ? Icons.apartment
                                      : Icons.location_on,
                              color: Theme.of(context).primaryColor,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "${AppLocalization.instance.getLocalizationFor("deliverTo")} ${AppLocalization.instance.getLocalizationFor(_address!.title!).toLowerCase()}",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                Text(
                                  _address!.formatted_address,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Divider(
                    thickness: 8,
                    color: theme.cardColor,
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                      child: Container(
                          color: theme.scaffoldBackgroundColor,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: CartManager().cartItems.length,
                            separatorBuilder: (context, index) =>
                                const CustomDivider(),
                            itemBuilder: (context, index) => Container(
                              padding: const EdgeInsets.only(
                                  top: 5, bottom: 5, right: 12, left: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          right: 12, top: 4),
                                      child: (CartManager()
                                                  .cartItems[index]
                                                  .meta["food_type"] !=
                                              null)
                                          ? Image.asset(
                                              CartManager()
                                                          .cartItems[index]
                                                          .meta["food_type"] ==
                                                      "veg"
                                                  ? Assets.foodFoodVeg
                                                  : Assets.foodFoodNonveg,
                                              height: 16,
                                              width: 40,
                                            )
                                          : const SizedBox()),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Title
                                        Text(
                                          CartManager().cartItems[index].title,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),

                                        // Price
                                        Text(
                                          "${AppSettings.currencyIcon} ${Helper.formatNumber(CartManager().cartItems[index].getTotalBase())}",
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(),
                                        ),

                                        // Add-ons
                                        for (CartItemAddOn addOn
                                            in CartManager()
                                                .cartItems[index]
                                                .addOns)
                                          Padding(
                                            padding: const EdgeInsetsDirectional
                                                .only(start: 12, top: 4),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  addOn.title,
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  "${AppSettings.currencyIcon} ${Helper.formatNumber(addOn.getTotalBase(CartManager().cartItems[index].quantity))}",
                                                  style: theme
                                                      .textTheme.titleSmall
                                                      ?.copyWith(
                                                    fontSize: 12,
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 16),

                                  // Third: Quantity controls (rest of the stuff)
                                  Container(
                                    height: 32,
                                    width: MediaQuery.of(context).size.width *
                                        0.22,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30.0),
                                      border: Border.all(
                                          color:
                                              Theme.of(context).primaryColor),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            CartManager()
                                                .removeOrDecrementCartItem(
                                                    CartManager()
                                                        .cartItems[index]);
                                            if (CartManager().cartItemsCount ==
                                                0) {
                                              Navigator.pop(context);
                                            } else {
                                              setState(() {});
                                            }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              start: 12,
                                              top: 4,
                                              bottom: 4,
                                            ),
                                            child: Icon(
                                              Icons.remove,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            CartManager()
                                                .cartItems[index]
                                                .quantity
                                                .toString(),
                                            style: const TextStyle(
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            CartManager()
                                                .addOrIncrementCartItem(
                                                    CartManager()
                                                        .cartItems[index]);
                                            setState(() {});
                                          },
                                          child: const Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              end: 12,
                                              top: 4,
                                              bottom: 4,
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))),
                  Container(
                    color: theme.scaffoldBackgroundColor,
                    child: ListTile(
                      leading: Icon(
                        Icons.assignment,
                        color: greyTextColor,
                        size: 18,
                      ),
                      title: CustomTextField(
                        hintText: AppLocalization.instance
                            .getLocalizationFor("addInstructionToRestaurant"),
                        controller: _instructionsController,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  if (_coupon == null)
                    ListTile(
                      tileColor: theme.scaffoldBackgroundColor,
                      minVerticalPadding: 10,
                      leading: Icon(
                        Icons.discount_sharp,
                        color: theme.hintColor,
                        size: 18,
                      ),
                      title: Text(
                        AppLocalization.instance
                            .getLocalizationFor("applyCoupon"),
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        AppLocalization.instance
                            .getLocalizationFor("view_offers"),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: theme.hintColor,
                      ),
                      onTap: () => Navigator.pushNamed(
                          context, PageRoutes.couponPage,
                          arguments: {"pick": true}).then(
                        (value) {
                          if (value is Coupon && mounted) {
                            BlocProvider.of<FetcherCubit>(context)
                                .initValidateCoupon(value.code);
                          }
                        },
                      ),
                    )
                  else
                    ListTile(
                      tileColor: theme.scaffoldBackgroundColor,
                      minVerticalPadding: 10,
                      leading: Icon(
                        Icons.discount_sharp,
                        color: theme.primaryColor,
                        size: 18,
                      ),
                      title: Text(
                        AppLocalization.instance
                            .getLocalizationFor("coupon_applied"),
                        style: theme.textTheme.bodyLarge,
                      ),
                      subtitle: Text(
                        _coupon!.detail,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.hintColor),
                      ),
                      trailing: const Icon(
                        Icons.close,
                        color: Colors.red,
                      ),
                      onTap: () {
                        _coupon = null;
                        CartManager().applyCoupon(null);
                        setState(() {});
                      },
                    ),
                  Divider(
                    thickness: 8,
                    color: theme.cardColor,
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20, top: 10, bottom: 20),
                    color: theme.scaffoldBackgroundColor,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalization.instance
                                    .getLocalizationFor("items_total"),
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            Text(
                              "${AppSettings.currencyIcon} ${Helper.formatNumber(CartManager().cartItemsTotal)}",
                              style: theme.textTheme.titleMedium,
                            )
                          ],
                        ),
                        const CustomDivider(),
                        ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: CartManager().extraCharges.length,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) =>
                              const CustomDivider(),
                          itemBuilder: (context, index) => Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppLocalization.instance.getLocalizationFor(
                                      CartManager().extraCharges[index].id),
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                "${AppSettings.currencyIcon} ${Helper.formatNumber(CartManager().calculateExtraChargePice(CartManager().extraCharges[index]))}",
                                style: theme.textTheme.titleMedium,
                              )
                            ],
                          ),
                        ),
                        const CustomDivider(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalization.instance
                                    .getLocalizationFor("amount_to_pay"),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              "${AppSettings.currencyIcon} ${Helper.formatNumber(CartManager().cartTotal)}",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          text: AppLocalization.instance
                              .getLocalizationFor("proceedToPay"),
                          onTap: () {
                            if (_address == null) {
                              Toaster.showToastCenter(AppLocalization.instance
                                  .getLocalizationFor(
                                      "select_address_continue"));
                              return;
                            }
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                top: Radius.circular(8),
                              )),
                              builder: (context) =>
                                  const PaymentMethodSheet(value: null),
                            ).then(
                              (value) {
                                if (value != null && value is PaymentMethod) {
                                  if (value.slug == "wallet") {
                                    BlocProvider.of<FetcherCubit>(context)
                                        .initFetchWalletBalance();
                                  } else {
                                    _confirmOrderTypeData(value.slug!);
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(32.0),
                child: ErrorFinalWidget.errorWithRetry(
                  context: context,
                  message:
                      AppLocalization.instance.getLocalizationFor("cart_empty"),
                  actionText:
                      AppLocalization.instance.getLocalizationFor("okay"),
                  action: () => Navigator.pop(context),
                ),
              ),
      ),
    );
  }

  void _refreshDeliveryFee() {
    if (_address != null && CartManager().cartItemsCount > 0) {
      BlocProvider.of<FetcherCubit>(context).initFetchDeliveryFee(
        vendorId:
            CartManager().cartItems.firstOrNull?.meta["vendor_id"].toString() ??
                "",
        sourceLat: CartManager().cartItems.firstOrNull?.meta["vendor_lat"],
        sourceLng: CartManager().cartItems.firstOrNull?.meta["vendor_lng"],
        destLat: _address!.latitude.toString(),
        destLng: _address!.longitude.toString(),
        orderType: "NORMAL",
      );
    }
  }

  void _confirmOrderTypeData(String paymentSlug) {
    bool hasTakeawayOption = false;
    //cust, whether vendor has takeaway enabled or not is controlled via category.meta.has_takeaway, which is saved in orderMeta at time of addToCart
    try {
      hasTakeawayOption =
          bool.tryParse("${CartManager().orderMeta["has_takeaway"]}") ?? false;
    } catch (e) {
      if (kDebugMode) {
        print("hasTakeawayOption: $e");
      }
    }
    //cust, whether vendor has takeaway enabled or not is controlled via category.meta.has_takeaway, which is saved in orderMeta at time of addToCart

    if (hasTakeawayOption) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        builder: (context) => OrderTypeSheet(),
      ).then((value) {
        if (value is OrderTypeData) {
          _proceedPlaceOrder(
            paymentSlug: paymentSlug,
            orderTypeData: value,
          );
        }
      });
    } else {
      _proceedPlaceOrder(
        paymentSlug: paymentSlug,
        orderTypeData: OrderTypeData(),
      );
    }
  }

  void _proceedPlaceOrder({
    required String paymentSlug,
    required OrderTypeData orderTypeData,
  }) async {
    UserData? savedUser = await LocalDataLayer().getUserMe();
    Map<String, String> orderMeta = CartManager().orderMeta;
    if (orderTypeData.reachingMins?.isNotEmpty ?? false) {
      orderMeta["reach_time"] = orderTypeData.reachingMins!;
    }
    orderMeta["customer_id"] = savedUser!.id.toString();
    if (savedUser.imageUrl != null) {
      orderMeta["customer_image"] = savedUser.imageUrl!;
    }
    BlocProvider.of<FetcherCubit>(context)
        .initCreateOrder(OrderReq.productsOrder(
      order_type: orderTypeData.orderType.name.toUpperCase(),
      type: orderTypeData.orderSubType.name.toUpperCase(),
      address_id: _address!.id,
      products: CartManager()
          .cartItems
          .map((ci) => OrderReqProduct(
                int.parse(ci.id.contains("+") ? ci.id.split("+").first : ci.id),
                ci.quantity,
                ci.addOns.map((ciAddOn) => OrderReqAddOns(ciAddOn.id)).toList(),
              ))
          .toList(),
      customer_name:
          orderTypeData.orderType == OrderType.normal ? null : savedUser.name,
      customer_email:
          orderTypeData.orderType == OrderType.normal ? null : savedUser.email,
      customer_mobile: orderTypeData.orderType == OrderType.normal
          ? null
          : savedUser.mobile_number,
      scheduled_on: orderTypeData.scheduledOn,
      notes: _instructionsController.text.trim(),
      coupon_code: _coupon?.code,
      payment_method_slug: paymentSlug,
      meta: jsonEncode(orderMeta),
    ));
  }
}
