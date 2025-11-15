import 'package:flutter/material.dart';

import 'package:deligo/config/page_routes.dart';
import 'package:deligo/flavors.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/utility/string_extensions.dart';

import 'orders_tab_appointment.dart';
import 'orders_tab_delivery.dart';
import 'orders_tab_ride.dart';

class BottomTabOrders extends StatefulWidget {
  const BottomTabOrders({super.key});

  @override
  State<BottomTabOrders> createState() => BottomTabOrdersState();
}

class BottomTabOrdersState extends State<BottomTabOrders>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late List<String> vendorTypesCategorySlugs;
  late TabController _tabController;
  late Map<String, GlobalKey<OrdersTabDeliveryStatefulState>>
      _orderTabsGlobalKeys;
  late GlobalKey<OrdersTabRideStatefulState> _orderTabRideKey;
  late GlobalKey<OrdersTabAppointmentStatefulState> _orderTabAppointmentKey;
  late List<Category> _categoriesHomeAll;

  @override
  bool get wantKeepAlive => true;

  bool get servicesEnabled {
    if (F.name == Flavor.deligo.name) {
      for (Category c in _categoriesHomeAll) {
        if (c.slug == "home-service" && (c.isEnabled ?? false))
        //for testing purposes
        //(c.slug == "home-service")
        //for testing purposes
        {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    return FutureBuilder<List<Category>>(
      future: _setupTabController(),
      builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) =>
          snapshot.hasData
              ? Scaffold(
                  appBar: AppBar(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    leading: null,
                    title: Text(
                      AppLocalization.instance.getLocalizationFor("orders"),
                      style: theme.textTheme.headlineLarge
                          ?.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, PageRoutes.cartPage),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.primaryColor,
                          child: Icon(
                            Icons.shopping_basket,
                            color: theme.scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  body: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      color: theme.scaffoldBackgroundColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TabBar(
                                controller: _tabController,
                                indicatorColor: Colors.green,
                                labelColor: theme.primaryColor,
                                indicatorPadding:
                                    const EdgeInsetsDirectional.only(end: 20),
                                tabAlignment: TabAlignment.start,
                                isScrollable: true,
                                dividerHeight: 0,
                                tabs: [
                                  if (vendorTypesCategorySlugs.isEmpty)
                                    Tab(
                                      text: AppLocalization.instance
                                          .getLocalizationFor("orders"),
                                    )
                                  else
                                    for (String hc in vendorTypesCategorySlugs)
                                      Tab(
                                        text: hc
                                            .substring("home-".length)
                                            .capitalizeFirst(),
                                      ),
                                  Tab(
                                    text: AppLocalization.instance
                                        .getLocalizationFor("rides"),
                                  ),
                                  if (servicesEnabled)
                                    Tab(
                                      text: AppLocalization.instance
                                          .getLocalizationFor("services"),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: ColoredBox(
                            color: theme.cardColor,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                if (vendorTypesCategorySlugs.isEmpty)
                                  OrdersTabDelivery(
                                      innerKey: _orderTabsGlobalKeys["all"]!)
                                else
                                  for (String hc in vendorTypesCategorySlugs)
                                    OrdersTabDelivery(
                                        innerKey: _orderTabsGlobalKeys[hc]!,
                                        vendorType: hc),
                                OrdersTabRide(
                                  innerKey: _orderTabRideKey,
                                ),
                                if (servicesEnabled)
                                  OrdersTabAppointment(
                                    innerKey: _orderTabAppointmentKey,
                                  ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tabController.removeListener(() {});
    super.dispose();
  }

  void setData(String data) {
    if (data.contains("refresh_orders")) {
      String categorySlug = data.split("_")[2];
      int indexAt = 0;
      for (int i = 0; i < _orderTabsGlobalKeys.length; i++) {
        if (_orderTabsGlobalKeys.keys.elementAt(i) == categorySlug) {
          indexAt = i;
          break;
        }
      }
      _tabController.animateTo(indexAt);
      _orderTabsGlobalKeys.values.elementAt(indexAt).currentState?.refresh();
    } else if (data.contains("refresh_rides")) {
      _tabController
          .animateTo(_tabController.length - (servicesEnabled ? 2 : 1));
      _orderTabRideKey.currentState?.refresh();
    } else if (data.contains("refresh_appointments") && servicesEnabled) {
      _tabController.animateTo(_tabController.length - 1);
      _orderTabAppointmentKey.currentState?.refresh();
    }
  }

  Future<List<Category>> _setupTabController() async {
    _categoriesHomeAll = await LocalDataLayer().getCategoriesHome();
    List<Category> categories = await LocalDataLayer().getCategoriesHome();
    vendorTypesCategorySlugs = AppSettings.vendorType
        .split(",")
        .map((e) => "home-${e.trim()}")
        .toList();
    //first remove categories that are not related to vendors and are disabled from admin
    categories.removeWhere((element) =>
        !vendorTypesCategorySlugs.contains(element.slug) ||
        !(element.isEnabled ?? false));
    //now lets remove vendorTypesCategorySlugs whose category slugs are not present in categories
    vendorTypesCategorySlugs.removeWhere((elementVendorTypeCatSlug) =>
        categories
            .where((cat) => cat.slug == elementVendorTypeCatSlug)
            .isEmpty);

    //setup orderTab's global keys
    _orderTabsGlobalKeys = {};
    if (vendorTypesCategorySlugs.isEmpty) {
      _orderTabsGlobalKeys["all"] = GlobalKey<OrdersTabDeliveryStatefulState>();
    } else {
      for (String hc in vendorTypesCategorySlugs) {
        _orderTabsGlobalKeys[hc] = GlobalKey<OrdersTabDeliveryStatefulState>();
      }
    }

    //setup ride tab global key
    _orderTabRideKey = GlobalKey<OrdersTabRideStatefulState>();
    //setup appointment tab global key
    if (servicesEnabled) {
      _orderTabAppointmentKey = GlobalKey<OrdersTabAppointmentStatefulState>();
    }

    //setup tab controller accordingly
    _tabController = TabController(
      initialIndex: 0,
      length: vendorTypesCategorySlugs.isEmpty
          ? (2 + (servicesEnabled ? 1 : 0))
          : vendorTypesCategorySlugs.length + 1 + (servicesEnabled ? 1 : 0),
      vsync: this,
    );
    _tabController.addListener(() {});
    return categories;
  }
}
