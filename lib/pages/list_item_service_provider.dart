import 'package:deligo/config/colors.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/service_provider.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_divider.dart';
import 'package:flutter/material.dart';

class ListItemServiceProvider extends StatelessWidget {
  final ThemeData theme;
  final ServiceProvider service_provider;
  const ListItemServiceProvider({
    super.key,
    required this.service_provider,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          PageRoutes.serviceProviderPage,
          arguments: service_provider,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(8),
              child: CachedImage(
                imageUrl: service_provider.imageUrl,
                height: 100,
                width: 100,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service_provider.name ?? "",
                      style: theme.textTheme.headlineSmall!.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      service_provider.address ?? "",
                      style: theme.textTheme.bodySmall!.copyWith(
                        fontSize: 12,
                        color: theme.hintColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service_provider.categoriesAllString,
                      style: theme.textTheme.bodyLarge!.copyWith(
                        fontSize: 12,
                        color: theme.primaryColorDark,
                      ),
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
                                service_provider.ratingsString,
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
                          "${service_provider.subcategories.length} ${AppLocalization.instance.getLocalizationFor('jobs')}",
                          style: theme.textTheme.bodySmall!.copyWith(
                            fontSize: 12,
                            color: theme.hintColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${service_provider.feeMinMaxString}",
                          style: theme.textTheme.bodyLarge!.copyWith(
                            fontSize: 12,
                            color: theme.primaryColorDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
