import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/pages/orders_tab_ride.dart';
import 'package:flutter/material.dart';

class BottomTabRides extends StatelessWidget {
  final GlobalKey<OrdersTabRideStatefulState> orderTabRideKey;
  const BottomTabRides({
    super.key,
    required this.orderTabRideKey,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  AppLocalization.instance.getLocalizationFor("activity"),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 20),
              Divider(
                thickness: 6,
                height: 6,
                color: Theme.of(context).disabledColor,
              ),
              Expanded(
                child: OrdersTabRide(
                  innerKey: orderTabRideKey,
                ),
              ),
            ],
          ),
        ),
      );
}
