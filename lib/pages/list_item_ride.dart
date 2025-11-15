import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/ride.dart';
import 'package:flutter/material.dart';

class ListItemRide extends StatelessWidget {
  final ThemeData theme;
  final Ride ride;
  const ListItemRide({
    super.key,
    required this.theme,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: () {
          if (ride.status == "complete") {
            Navigator.pushNamed(context, PageRoutes.rideCompletePage,
                arguments: ride);
          } else {
            Navigator.pushNamed(context, PageRoutes.rideInfoPage,
                arguments: ride);
          }
        },
        child: Material(
          color: theme.scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Image.asset(
                        RideType.values
                            .firstWhere((type) =>
                                type.toString().split('.').last == ride.type)
                            .image,
                        height: 55,
                        width: 55,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ride.type != null
                                ? ride.type! == "courier"
                                    ? AppLocalization.instance
                                        .getLocalizationFor("package")
                                    : ride.type!.substring(0, 1).toUpperCase() +
                                        ride.type!.substring(1)
                                : "Ride",
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Text(
                            ride.ride_on_formatted ?? "",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: ride.colorLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            AppLocalization.instance
                                .getLocalizationFor(
                                    "ride_status_${ride.status.isNotEmpty ? ride.status : "pending"}")
                                .toUpperCase(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: ride.color,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ride.fareFormatted ?? "",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            CircleAvatar(
                              radius: 2,
                              backgroundColor: theme.hintColor,
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                              ride.payment?.paymentMethod?.title ?? "Cash",
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  thickness: 1,
                  color: theme.highlightColor,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: theme.primaryColor,
                      child: Icon(
                        Icons.location_on,
                        size: 12,
                        color: theme.scaffoldBackgroundColor,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Text(
                        ride.address_from,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: theme.primaryColor,
                      child: Icon(
                        Icons.navigation,
                        size: 12,
                        color: theme.scaffoldBackgroundColor,
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Text(
                        ride.address_to,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
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
