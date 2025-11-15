import 'package:buy_this_app/buy_this_app.dart';
import 'package:deligo/config/colors.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/models/ride.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';

import 'package:deligo/config/app_config.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/utility/locale_data_layer.dart';

import 'bottom_tab_account.dart';
import 'bottom_tab_home.dart';
import 'bottom_tab_orders.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  late List<Widget> _children;
  late PageController _pageController;
  int _currentIndex = 0;
  GlobalKey<BottomTabOrdersState>? _ordersTabKey;
  GlobalKey<TabHomeStatefulState>? _homeTabKey;

  @override
  void initState() {
    _pageController = PageController();
    super.initState();

    _ordersTabKey = GlobalKey();
    _homeTabKey = GlobalKey();

    _children = [
      BottomTabHome(
        homeTabKey: _homeTabKey!,
      ),
      BottomTabOrders(
        key: _ordersTabKey,
      ),
      const BottomTabAccount(),
    ];
    if (AppConfig.isDemoMode) {
      _buyNowPopup();
    }
  }

  @override
  Widget build(BuildContext context) => FocusDetector(
        onFocusGained: () async {
          if (_currentIndex == 0) {
            _homeTabKey?.currentState?.setState(() {});
          }
          Map<String, dynamic>? tabUpdate =
              await LocalDataLayer().getTabUpdate();
          await LocalDataLayer().setTabUpdate(null, null);
          if (tabUpdate != null) {
            _pageController.jumpToPage(tabUpdate["tab"]);
            setState(() => _currentIndex = tabUpdate["tab"]);
            if (tabUpdate["data"] != null) {
              if (tabUpdate["tab"] == 0 &&
                  tabUpdate["data"] == "ride_rejected") {
                Ride? tr = await LocalDataLayer().getTempRide();
                if (tr == null) return;
                ConfirmDialog.showConfirmation(
                        context,
                        Text(AppLocalization.instance
                            .getLocalizationFor("ride_status_msg_cancelled")),
                        Text(AppLocalization.instance
                            .getLocalizationFor("ride_rejected_rebook_msg")),
                        AppLocalization.instance.getLocalizationFor("ignore"),
                        AppLocalization.instance.getLocalizationFor("yes"))
                    .then((value) {
                  if (value != null && value == true) {
                    Navigator.pushNamed(
                      context,
                      PageRoutes.selectSrcDstPage,
                      arguments: {"type": tr.type},
                    );
                  } else {
                    LocalDataLayer().setTempRide(null);
                  }
                });
              } else if (tabUpdate["tab"] == 1) {
                Future.delayed(const Duration(seconds: 1), () {
                  _ordersTabKey?.currentState?.setData(tabUpdate["data"]);
                });
              }
            }
          }
        },
        child: PopScope(
          canPop: _currentIndex == 0,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _pageController.jumpToPage(0);
              setState(() => _currentIndex = 0);
            }
          },
          child: Scaffold(
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _children,
              ),
              bottomNavigationBar: Theme(
                data: Theme.of(context).copyWith(
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                          ? darkBottomNavBarColor
                          : Theme.of(context).scaffoldBackgroundColor,
                  onTap: (val) {
                    _pageController.jumpToPage(val);
                    setState(() => _currentIndex = val);
                  },
                  currentIndex: _currentIndex,
                  elevation: 20,
                  items: [
                    BottomNavigationBarItem(
                      label:
                          AppLocalization.instance.getLocalizationFor("home"),
                      icon: const Icon(Icons.home),
                    ),
                    BottomNavigationBarItem(
                      label:
                          AppLocalization.instance.getLocalizationFor("orders"),
                      icon: const Icon(Icons.assignment_outlined),
                    ),
                    BottomNavigationBarItem(
                      label: AppLocalization.instance
                          .getLocalizationFor("account"),
                      icon: const Icon(Icons.person),
                    ),
                  ],
                ),
              )),
        ),
      );

  void _buyNowPopup() =>
      LocalDataLayer().isBuyThisAppPrompted().then((isPrompted) {
        if (!isPrompted) {
          Future.delayed(const Duration(seconds: 10), () {
            if (mounted) {
              BuyThisApp.showSubscribeDialog(context);
              LocalDataLayer().setBuyThisAppPrompted();
            }
          });
        }
      });

  Container buildActiveIcon(BuildContext context, Color color,
          Color? titleColor, String icon, String title) =>
      Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 35),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: color,
              ),
              height: 3,
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  icon,
                  height: 18,
                  width: 18,
                  color: titleColor,
                ),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: titleColor),
                ),
              ],
            ),
          ],
        ),
      );
}

abstract class BottomTabInteractor {}
