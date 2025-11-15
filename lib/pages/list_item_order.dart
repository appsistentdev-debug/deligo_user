import 'package:flutter/material.dart';

import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/order.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_divider.dart';

class ListItemOrder extends StatelessWidget {
  final ThemeData theme;
  final Order order;
  const ListItemOrder({
    super.key,
    required this.theme,
    required this.order,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: () => Navigator.pushNamed(
          context,
          PageRoutes.orderInfoPage,
          arguments: order,
        ),
        child: Material(
          color: theme.scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: CachedImage(
                        imageUrl: order.image ?? order.vendor?.imageUrl,
                        height: 56,
                        width: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              order.vendor?.name ?? "",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${AppLocalization.instance.getLocalizationFor("orderid")} ${order.id}",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                                Text(
                                  order.createdAtFormatted ?? "",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: CustomDivider(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          order.products?.length == 1
                              ? "${order.products?.length} ${AppLocalization.instance.getLocalizationFor("item")}"
                              : "${order.products?.length} ${AppLocalization.instance.getLocalizationFor("items")}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Text(
                          order.totalFormatted ?? "",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: order.colorLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppLocalization.instance
                            .getLocalizationFor("order_status_${order.status}")
                            .toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: order.color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
