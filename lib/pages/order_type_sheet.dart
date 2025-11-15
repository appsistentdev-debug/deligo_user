import 'package:flutter/material.dart';

import 'package:deligo/config/colors.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/pages/pickup_time_selector_sheet.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/toaster.dart';

enum OrderType { takeaway, normal, dinein }

enum OrderSubType { asap, later }

class OrderTypeSheet extends StatelessWidget {
  const OrderTypeSheet({super.key});

  @override
  Widget build(BuildContext context) => OrderTypeStateful();
}

class OrderTypeStateful extends StatefulWidget {
  const OrderTypeStateful({super.key});

  @override
  State<OrderTypeStateful> createState() => _OrderTypeStatefulState();
}

class _OrderTypeStatefulState extends State<OrderTypeStateful> {
  OrderType orderType = OrderType.normal;
  OrderSubType orderSubType = OrderSubType.asap;
  PickupTime? pickupTime;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DraggableScrollableSheet(
      minChildSize: 0.5,
      maxChildSize: 0.8,
      initialChildSize: 0.5,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: theme.unselectedWidgetColor,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              AppLocalization.instance.getLocalizationFor(AppLocalization
                  .instance
                  .getLocalizationFor("choose_ordering_method")),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => orderType = OrderType.normal),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: orderType == OrderType.normal
                              ? mainColor.withValues(alpha: 0.1)
                              : theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: orderType == OrderType.normal
                                ? mainColor
                                : unselectedItemColor,
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: ListTile(
                          leading:
                              Image.asset('assets/delivery_mode_deliver.png'),
                          title: Text(AppLocalization.instance
                              .getLocalizationFor(
                                  "order_type_${OrderType.normal.name}")),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => orderType = OrderType.takeaway),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: orderType == OrderType.takeaway
                              ? mainColor.withValues(alpha: 0.1)
                              : theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: orderType == OrderType.takeaway
                                ? mainColor
                                : unselectedItemColor,
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: ListTile(
                          leading:
                              Image.asset('assets/delivery_mode_pickup.png'),
                          title: Text(AppLocalization.instance
                              .getLocalizationFor(
                                  "order_type_${OrderType.takeaway.name}")),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: theme.scaffoldBackgroundColor,
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                ),
                child: Column(
                  children: [
                    if (orderType == OrderType.takeaway)
                      Row(
                        children: [
                          InkWell(
                            onTap: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => PickupTimeSelectorSheet(
                                pickupTimeIn: pickupTime,
                              ),
                            ).then(
                              (value) {
                                if (value is PickupTime) {
                                  pickupTime = value;
                                  setState(() {});
                                }
                              },
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 22),
                                Image.asset(
                                    'assets/delivery_mode_pickup_time.png'),
                                const SizedBox(width: 20),
                                Text(pickupTime?.title ??
                                    AppLocalization.instance.getLocalizationFor(
                                        "reaching_in_pick_msg")),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    CustomButton(
                      text: AppLocalization.instance
                          .getLocalizationFor("continueText"),
                      margin: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 20, top: 10),
                      onTap: () {
                        if (orderType == OrderType.takeaway &&
                            pickupTime == null) {
                          Toaster.showToastCenter(AppLocalization.instance
                              .getLocalizationFor("reaching_in_pick_msg"));
                          return;
                        }
                        Navigator.pop(
                            context,
                            OrderTypeData(
                              orderType: orderType,
                              orderSubType: orderSubType,
                              // scheduledOn: orderSubType == OrderSubType.later
                              //     ? DateFormat("yyyy-MM-dd HH:mm:ss").format(
                              //         DateTime.parse(
                              //             scheduledOnDate + " " + scheduledOnTime))
                              //     : null,
                              reachingMins: pickupTime?.value,
                            ));
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
}

class OrderTypeData {
  final OrderType orderType;
  final OrderSubType orderSubType;
  final String? scheduledOn;
  final String? reachingMins;

  OrderTypeData(
      {this.orderType = OrderType.normal,
      this.orderSubType = OrderSubType.asap,
      this.scheduledOn,
      this.reachingMins});
}
