import 'package:deligo/config/assets.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:flutter/material.dart';

class RideTypeSelectionSheet extends StatelessWidget {
  const RideTypeSelectionSheet({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.4, // Add initial size
      minChildSize: 0.3, // Add minimum size
      maxChildSize: 0.5,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                height: 4,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: theme.hintColor,
                ),
              ),
            ),
            const SizedBox(height: 36),
            Text(
              AppLocalization.instance.getLocalizationFor("select_cab_option"),
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => Navigator.pop(context, {"type": "ride"}),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.scaffoldBackgroundColor,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      Assets.mainCategoryRide,
                      height: 110,
                      width: 100,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalization.instance
                                .getLocalizationFor("bookRide"),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${AppLocalization.instance.getLocalizationFor("quickAndEasyRides")}\n${AppLocalization.instance.getLocalizationFor("withinTheCity")}",
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => Navigator.pop(context, {"type": "intercity"}),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: theme.scaffoldBackgroundColor,
                ),
                child: Row(
                  children: [
                    Image.asset(
                      Assets.mainCategoryIntercity,
                      height: 110,
                      width: 100,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalization.instance
                                .getLocalizationFor("bookIntercityRide"),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppLocalization.instance
                                .getLocalizationFor(
                                    "seamlessTravelBetweennewlinecitiesHasslefree")
                                .replaceAll("99999", "\n"),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    )
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
