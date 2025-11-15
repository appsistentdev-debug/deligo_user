import 'package:flutter/material.dart';

import 'package:deligo/config/colors.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/vendor.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_divider.dart';

class ListItemVendor extends StatelessWidget {
  final ThemeData theme;
  final Vendor vendor;
  const ListItemVendor({
    super.key,
    required this.theme,
    required this.vendor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          PageRoutes.productsPage,
          arguments: vendor,
        ),
        child: Row(
          children: [
            CachedImage(
              imageUrl: vendor.imageUrl,
              height: 100,
              width: 100,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: theme.textTheme.headlineSmall!.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      vendor.address ?? "",
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: AppLocalization.instance
                                  .getLocalizationFor("preperation_in_full")
                                  .replaceFirst(
                                      "9999", vendor.preperationTime ?? "")),
                          TextSpan(
                              text: " • ",
                              style: TextStyle(
                                  color: theme.unselectedWidgetColor)),
                          TextSpan(text: vendor.distanceFormatted ?? "0m"),
                        ],
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: theme.primaryColorDark,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    const CustomDivider(withoutPadding: true),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsetsDirectional.only(
                            start: 4,
                            top: 2,
                            bottom: 2,
                            end: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: ratingCardColor,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                vendor.ratingsFormatted ?? "",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                      fontSize: 10,
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${vendor.ratings_count} ${AppLocalization.instance.getLocalizationFor("rated")}",
                          style: theme.textTheme.bodySmall!.copyWith(
                            fontSize: 12,
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
      );
}
