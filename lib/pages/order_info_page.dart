import 'package:deligo/utility/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/config/assets.dart';
import 'package:deligo/config/colors.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/chat.dart';
import 'package:deligo/models/order.dart';
import 'package:deligo/utility/constants.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_divider.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/my_map_widget.dart';

class OrderInfoPage extends StatelessWidget {
  const OrderInfoPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: OrderInfoStateful(
            ModalRoute.of(context)!.settings.arguments as Order),
      );
}

class OrderInfoStateful extends StatefulWidget {
  final Order order;
  const OrderInfoStateful(this.order, {super.key});

  @override
  State<OrderInfoStateful> createState() => _OrderInfoStatefulState();
}

class _OrderInfoStatefulState extends State<OrderInfoStateful> {
  final GlobalKey<MyMapState> _myMapStateKey = GlobalKey();
  late FetcherCubit _fetcherCubit;
  Order? _order;
  final GlobalKey _stackKey = GlobalKey();
  double _stackHeight = 0;
  bool _hasRated = false;

  @override
  void initState() {
    _order = widget.order;
    _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
    super.initState();
    if (!(_order?.isPast ?? false)) {
      _fetcherCubit.initRegisterOrderUpdates(widget.order.id);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_order?.status == "complete") {
        LocalDataLayer()
            .getOrderIdRated(_order!.id)
            .then((value) => setState(() => _hasRated = value));
      }
      final RenderBox? box =
          _stackKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null && mounted) {
        _stackHeight = box.size.height;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _fetcherCubit.initUnRegisterOrderUpdates();
    _fetcherCubit.initUnRegisterDeliveryUpdates();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) async {
        if (state is OrdersLoading) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }
        if (state is OrderUpdateLoaded) {
          _order = state.order;
          if (state.order.status == "complete") {
            _hasRated = await LocalDataLayer().getOrderIdRated(_order!.id);
          }
          setState(() {});
          if (state.order.delivery?.delivery.id != null &&
              !state.order.isPast) {
            _fetcherCubit
                .initRegisterDeliveryUpdates(state.order.delivery!.delivery.id);
          }
        }
        if (state is LocationUpdateLoaded) {
          _setupDeliveryMarker(state.latLng);
        }
      },
      child: Scaffold(
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
            PositionedDirectional(
              top: 52,
              start: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.scaffoldBackgroundColor,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.arrow_back_ios_sharp),
                ),
              ),
            ),
            if ((_order?.status == "complete") && !_hasRated)
              PositionedDirectional(
                top: 52,
                end: 16,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    PageRoutes.rateOrderPage,
                    arguments: _order,
                  ).then((value) => LocalDataLayer()
                      .getOrderIdRated(_order!.id)
                      .then((value) => setState(() => _hasRated = value))),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Icon(Icons.star),
                        const SizedBox(width: 4),
                        Text(AppLocalization.instance
                            .getLocalizationFor("rate_order")),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        bottomSheet: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.35,
          minChildSize: 0.35,
          maxChildSize: 0.6,
          snap: true,
          builder: (context, controller) => Column(
            children: [
              Container(
                padding: const EdgeInsetsDirectional.only(
                  top: 8,
                  end: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                  color: theme.primaryColor,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        height: 4,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          Assets.assetsDelivery,
                          height: 75,
                          width: 75,
                        ),
                        Text(
                          _order?.delivery?.delivery.user == null
                              ? (_order?.order_type?.toLowerCase() == "normal"
                                  ? AppLocalization.instance
                                      .getLocalizationFor("delivery_na")
                                  : AppLocalization.instance.getLocalizationFor(
                                      "order_type_${_order?.order_type!.toLowerCase()}"))
                              : (_order?.isPast ?? false)
                                  ? "${AppLocalization.instance.getLocalizationFor("order")} ${AppLocalization.instance.getLocalizationFor("order_status_${_order?.status}")}"
                                  : AppLocalization.instance
                                      .getLocalizationFor("delivery_soon"),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 75,
                        )
                        // Text.rich(
                        //   TextSpan(
                        //     text: "Deliveryman arriving in ",
                        //     children: [
                        //       TextSpan(
                        //         text: "20 mins",
                        //         style: theme.textTheme.titleLarge?.copyWith(
                        //           color: theme.scaffoldBackgroundColor,
                        //           fontWeight: FontWeight.w600,
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        //   style: theme.textTheme.titleLarge
                        //       ?.copyWith(color: theme.scaffoldBackgroundColor),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: ListView(
                controller: controller,
                shrinkWrap: true,
                children: [
                  ColoredBox(
                    color: theme.cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_order?.delivery?.delivery.user != null)
                          Container(
                            color: theme.scaffoldBackgroundColor,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional.center,
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: CachedImage(
                                        imageUrl: _order
                                            ?.delivery?.delivery.user.imageUrl,
                                        imagePlaceholder:
                                            Assets.assetsPlaceholderProfile,
                                        height: 70,
                                        width: 70,
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
                                              color: const Color(0xFF009D06),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                  size: 10,
                                                ),
                                                const SizedBox(width: 3),
                                                Text(
                                                  _order?.delivery?.delivery
                                                          .ratings
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
                                SizedBox(
                                  height: 70,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalization.instance
                                            .getLocalizationFor("delivery_guy"),
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          fontSize: 12,
                                          color: theme.hintColor,
                                        ),
                                      ),
                                      Text(
                                        _order?.delivery?.delivery.user.name ??
                                            "",
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          //fontSize: 15,
                                          //color: theme.hintColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _order?.delivery?.delivery.user
                                                .mobile_number ??
                                            "",
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          //fontSize: 15,
                                          //color: theme.hintColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!(_order?.isPast ?? false)) const Spacer(),
                                if (!(_order?.isPast ?? false))
                                  GestureDetector(
                                    onTap: () => Helper.launchURL(
                                        "tel:${_order?.delivery?.delivery.user.mobile_number}"),
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.scaffoldBackgroundColor,
                                        border:
                                            Border.all(color: theme.hintColor),
                                      ),
                                      child: Icon(Icons.call,
                                          color: theme.primaryColor),
                                    ),
                                  ),
                                if (!(_order?.isPast ?? false))
                                  const SizedBox(width: 16),
                                if (!(_order?.isPast ?? false))
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      PageRoutes.messagePage,
                                      arguments: {
                                        "chat": Chat(
                                          myId:
                                              "${_order?.user?.id}${Constants.roleUser}",
                                          chatId:
                                              "${_order?.delivery?.delivery.user.id}${Constants.roleDelivery}",
                                          chatImage: _order?.delivery?.delivery
                                              .user.imageUrl,
                                          chatName: _order
                                              ?.delivery?.delivery.user.name,
                                          chatStatus: _order?.delivery?.delivery
                                              .user.mobile_number,
                                        ),
                                        "subtitle": AppLocalization.instance
                                            .getLocalizationFor("delivery_guy"),
                                      },
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: theme.scaffoldBackgroundColor,
                                        border:
                                            Border.all(color: theme.hintColor),
                                      ),
                                      child: Icon(Icons.message,
                                          color: theme.primaryColor),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 4),
                        // Padding(
                        //   padding: const EdgeInsets.all(16.0),
                        //   child: Text(
                        //     "Delivery Details",
                        //     style: theme.textTheme.titleMedium
                        //         ?.copyWith(color: theme.hintColor),
                        //   ),
                        // ),

                        Container(
                          color: theme.scaffoldBackgroundColor,
                          padding: const EdgeInsets.all(16),
                          width: double.infinity,
                          child: Stack(
                            key: _stackKey,
                            clipBehavior: Clip.none,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2.0),
                                        child: Icon(Icons.store,
                                            color: theme.primaryColor),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _order?.vendor?.name ?? "",
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                      color: theme.hintColor),
                                            ),
                                            Text(
                                              _order?.vendor?.address ??
                                                  _order?.source_address
                                                      ?.formatted_address ??
                                                  "",
                                              overflow: TextOverflow.visible,
                                              maxLines: 3,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!(_order?.isPast ?? false))
                                        const SizedBox(width: 16),
                                      if (!(_order?.isPast ?? false))
                                        GestureDetector(
                                          onTap: () => Helper.launchURL(
                                              "tel:${_order?.vendor?.user?.mobile_number}"),
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  theme.scaffoldBackgroundColor,
                                              border: Border.all(
                                                  color: theme.hintColor),
                                            ),
                                            child: Icon(Icons.call,
                                                color: theme.primaryColor),
                                          ),
                                        ),
                                      if (!(_order?.isPast ?? false))
                                        const SizedBox(width: 16),
                                      if (!(_order?.isPast ?? false))
                                        GestureDetector(
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            PageRoutes.messagePage,
                                            arguments: {
                                              "chat": Chat(
                                                myId:
                                                    "${_order?.user?.id}${Constants.roleUser}",
                                                chatId:
                                                    "${_order?.vendor?.user?.id}${Constants.roleVendor}",
                                                chatImage:
                                                    _order?.vendor?.imageUrl,
                                                chatName: _order?.vendor?.name,
                                                chatStatus: _order?.vendor?.user
                                                    ?.mobile_number,
                                              ),
                                              "subtitle":
                                                  "${AppLocalization.instance.getLocalizationFor("orderid")} ${_order?.id}",
                                            },
                                          ),
                                          child: Container(
                                            margin:
                                                const EdgeInsets.only(top: 10),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  theme.scaffoldBackgroundColor,
                                              border: Border.all(
                                                  color: theme.hintColor),
                                            ),
                                            child: Icon(Icons.message,
                                                color: theme.primaryColor),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (_order?.order_type?.toLowerCase() ==
                                      "normal")
                                    const SizedBox(height: 16),
                                  if (_order?.order_type?.toLowerCase() ==
                                      "normal")
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2.0),
                                          child: Icon(Icons.home,
                                              color: theme.primaryColor),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                AppLocalization.instance
                                                    .getLocalizationFor(
                                                        "delivery_location"),
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                        color: theme.hintColor),
                                              ),
                                              Text(
                                                _order?.address
                                                        ?.formatted_address ??
                                                    "",
                                                overflow: TextOverflow.visible,
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              if (_order?.order_type?.toLowerCase() == "normal")
                                PositionedDirectional(
                                  top: _stackHeight * .25,
                                  start: -2,
                                  child: Icon(
                                    Icons.more_vert,
                                    color: theme.hintColor,
                                    size: 30,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            AppLocalization.instance
                                .getLocalizationFor("ordered_itms"),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: theme.hintColor),
                          ),
                        ),

                        Container(
                          color: theme.scaffoldBackgroundColor,
                          child: ListView.separated(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) =>
                                const CustomDivider(),
                            itemCount: _order?.products?.length ?? 0,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      if (_order!
                                              .products![index]
                                              .vendor_product
                                              .product
                                              ?.foodType !=
                                          null)
                                        Image.asset(
                                          _order!
                                                      .products![index]
                                                      .vendor_product
                                                      .product
                                                      ?.foodType ==
                                                  "veg"
                                              ? Assets.foodFoodVeg
                                              : Assets.foodFoodNonveg,
                                          height: 16,
                                        ),
                                      if (_order!
                                              .products![index]
                                              .vendor_product
                                              .product
                                              ?.foodType !=
                                          null)
                                        const SizedBox(width: 16),
                                      Text(
                                        _order!.products![index].vendor_product
                                                .product?.title ??
                                            "",
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "  x ${_order!.products![index].quantity}",
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(color: theme.hintColor),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _order!.products![index].totalFormatted ??
                                        "",
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_order?.notes?.isNotEmpty ?? false)
                          Container(
                            color: Colors.white,
                            child: ListTile(
                              leading: Icon(
                                Icons.assignment,
                                color: greyTextColor,
                                size: 18,
                              ),
                              title: Text(
                                _order?.notes ?? "",
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        if (_order?.notes?.isNotEmpty ?? false)
                          const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(20.0),
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
                                    _order?.subtotalFormatted ?? "",
                                    style: theme.textTheme.titleMedium,
                                  )
                                ],
                              ),
                              const CustomDivider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppLocalization.instance
                                          .getLocalizationFor("delivery_fee"),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  Text(
                                    _order?.deliveryFeeFormatted ?? "",
                                    style: theme.textTheme.titleMedium,
                                  )
                                ],
                              ),
                              const CustomDivider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      AppLocalization.instance
                                          .getLocalizationFor(
                                              "taxes_and_charges"),
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  Text(
                                    _order?.taxesFormatted ?? "",
                                    style: theme.textTheme.titleMedium,
                                  )
                                ],
                              ),
                              const CustomDivider(),
                              if ((_order?.discountFormatted?.isNotEmpty ??
                                      false) &&
                                  _order?.discountFormatted !=
                                      "${AppSettings.currencyIcon} 0")
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppLocalization.instance
                                            .getLocalizationFor("discount"),
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ),
                                    Text(
                                      _order?.discountFormatted ?? "",
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              if ((_order?.discountFormatted?.isNotEmpty ??
                                      false) &&
                                  _order?.discountFormatted !=
                                      "${AppSettings.currencyIcon} 0")
                                const CustomDivider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _order?.payment?.status == "paid"
                                          ? AppLocalization.instance
                                                  .getLocalizationFor(
                                                      "paid_via") +
                                              _order!.payment!.paymentMethod!
                                                  .title!
                                          : AppLocalization.instance
                                              .getLocalizationFor("total"),
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: _order?.payment?.status ==
                                                      "paid"
                                                  ? theme.primaryColor
                                                  : Colors.black,
                                              fontSize: 18),
                                    ),
                                  ),
                                  Text(
                                    _order?.totalFormatted ?? "",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          color: theme.scaffoldBackgroundColor,
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Order ID",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Text(
                                    _order?.id.toString() ?? "",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Ordered on",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  Text(
                                    _order?.createdAtFormatted ?? "",
                                    style: theme.textTheme.titleMedium,
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        if (_order?.status == "new" ||
                            _order?.status == "pending")
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 80,
                              vertical: 40,
                            ),
                            child: CustomButton(
                              onTap: () => ConfirmDialog.showConfirmation(
                                      context,
                                      Text(AppLocalization.instance
                                          .getLocalizationFor("cancel_order")),
                                      Text(AppLocalization.instance
                                          .getLocalizationFor(
                                              "cancel_order_msg")),
                                      AppLocalization.instance
                                          .getLocalizationFor("no"),
                                      AppLocalization.instance
                                          .getLocalizationFor("yes"))
                                  .then((value) {
                                if (value != null && value == true) {
                                  _fetcherCubit.initUpdateOrder(
                                      widget.order.id, {"status": "cancelled"});
                                }
                              }),
                              text: AppLocalization.instance
                                  .getLocalizationFor("cancelOrder"),
                              buttonColor: const Color(0xFFF1D7D6),
                              textColor: Colors.red,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }

  void _setupDeliveryMarker(LatLng latLng) {
    if (_myMapStateKey.currentState != null) {
      if (_myMapStateKey.currentState!.hasMarkerWithId("delivery")) {
        _myMapStateKey.currentState!.updateMarkerLocation("delivery", latLng);
      } else {
        MyMapHelper.createBitmapDescriptorFromImage(Assets.pinsIcBike, "").then(
            (value) => _myMapStateKey.currentState!
                .addMarker("delivery", value, latLng));
      }
      _myMapStateKey.currentState!.moveCamera(latLng);
    }
  }

  void _setupMarkersAndPolyline() {
    if (_myMapStateKey.currentState != null) {
      if (widget.order.sourceLatLng != null &&
          widget.order.destinationLatLng != null) {
        MyMapHelper.createBitmapDescriptorFromImage(
                "assets/ic_location.png", "")
            .then((value) => _myMapStateKey.currentState!
                .addMarker("src", value, widget.order.sourceLatLng!));
        MyMapHelper.createBitmapDescriptorFromImage(
                "assets/ic_destination.png", "")
            .then((value) => _myMapStateKey.currentState!
                .addMarker("dst", value, widget.order.destinationLatLng!));

        MyMapHelper.getPolyLine(
          color: darken(Theme.of(context).primaryColor),
          source: widget.order.sourceLatLng!,
          destination: widget.order.destinationLatLng!,
        ).then(
          (Polyline pl) {
            _myMapStateKey.currentState!.addPolyline(pl);
            Future.delayed(
              const Duration(milliseconds: 500),
              () => _myMapStateKey.currentState?.adjustMapZoom(),
            );
          },
        );
      }
    }
  }
}
