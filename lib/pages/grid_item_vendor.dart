import 'package:deligo/config/colors.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/vendor.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_divider.dart';
import 'package:flutter/material.dart';

class GridItemVendor extends StatelessWidget {
  final ThemeData theme;
  final Vendor vendor;
  const GridItemVendor({super.key, required this.theme, required this.vendor});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          PageRoutes.productsPage,
          arguments: vendor,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedImage(
                  imageUrl: vendor.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    vendor.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    vendor.address ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              '${vendor.preperationTime ?? '20'} ${AppLocalization.instance.getLocalizationFor("mins")}',
                        ),
                        TextSpan(
                            text: " • ",
                            style:
                                TextStyle(color: theme.unselectedWidgetColor)),
                        TextSpan(
                          text: vendor.distanceFormatted ?? "0m",
                        ),
                      ],
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.primaryColorDark,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const CustomDivider(withoutPadding: false),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsetsDirectional.only(
                          start: 8,
                          top: 4,
                          bottom: 4,
                          end: 8,
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
                              style: theme.textTheme.bodyMedium!.copyWith(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${vendor.ratings_count} ${AppLocalization.instance.getLocalizationFor("rated")}",
                          style: theme.textTheme.bodySmall!.copyWith(
                            fontSize: 12,
                            color: theme.hintColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
