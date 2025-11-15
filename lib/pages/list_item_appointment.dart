import 'package:deligo/config/page_routes.dart';
import 'package:flutter/material.dart';

import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/appointment.dart';
import 'package:deligo/utility/string_extensions.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_divider.dart';

class ListItemAppointment extends StatelessWidget {
  final Appointment appointment;
  final ThemeData theme;
  const ListItemAppointment({
    super.key,
    required this.appointment,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) => InkWell(
        splashFactory: NoSplash.splashFactory,
        onTap: () => Navigator.pushNamed(
          context,
          PageRoutes.appointmentInfoPage,
          arguments: appointment,
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
                        imageUrl: appointment.provider?.imageUrl,
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
                              appointment.provider!.name ?? "",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${AppLocalization.instance.getLocalizationFor("serviceid")} ${appointment.id}",
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                                Text(
                                  appointment.scheduled_at_formatted ?? "",
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
                          "${appointment.categories?.length} ${AppLocalization.instance.getLocalizationFor((appointment.categories?.length ?? 0) > 1 ? "services" : "service").capitalizeFirst()}",
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
                          appointment.amountFormatted ?? "",
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
                        color: appointment.colorLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppLocalization.instance
                            .getLocalizationFor(
                                "appointment_status_${appointment.status}")
                            .toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: appointment.color,
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
