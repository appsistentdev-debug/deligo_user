import 'package:deligo/config/colors.dart';
import 'package:flutter/material.dart';

import 'package:deligo/config/assets.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/product.dart';
import 'package:deligo/widgets/cached_image.dart';

class ListItemProduct extends StatelessWidget {
  final ThemeData theme;
  final Product product;
  final void Function(Product product) onTapItem;
  final void Function(Product product) onTapAdd;
  final void Function(Product product) onTapRemove;
  final void Function(Product product) onTapCustomize;
  const ListItemProduct({
    super.key,
    required this.theme,
    required this.product,
    required this.onTapItem,
    required this.onTapAdd,
    required this.onTapRemove,
    required this.onTapCustomize,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    ThemeData theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => onTapItem.call(product),
      child: SizedBox(
        height: width * 0.24,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedImage(
                imageUrl: product.imageUrls?.firstOrNull,
                height: width * 0.24,
                width: width * 0.24,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: width * 0.66,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      if (product.foodType != null)
                        Image.asset(
                          product.foodType == "veg"
                              ? Assets.foodFoodVeg
                              : Assets.foodFoodNonveg,
                          height: 16,
                        ),
                      if (product.foodType != null) const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          product.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.priceFormatted ?? "",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    // mainAxisAlignment:
                    //     MainAxisAlignment.spaceBetween,
                    children: [
                      if (product.addon_groups?.isNotEmpty ?? false)
                        GestureDetector(
                          onTap: () => onTapCustomize.call(product),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            decoration: BoxDecoration(
                                color:
                                    isDark ? darkBottomNavBarColor : cardColor,
                                borderRadius: BorderRadius.circular(36)),
                            child: Row(
                              children: [
                                Text(
                                  AppLocalization.instance
                                      .getLocalizationFor("customize"),
                                  textAlign: TextAlign.end,
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ),
                        ),
                      const Spacer(),
                      Container(
                        height: 32,
                        width: width * 0.22,
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(color: theme.primaryColor),
                          color: ((product.quantity ?? 0) <= 0)
                              ? theme.scaffoldBackgroundColor
                              : theme.primaryColor,
                        ),
                        // padding:
                        //     const EdgeInsets.symmetric(
                        //         horizontal: 12,
                        //         vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if ((product.quantity ?? 0) > 0) ...[
                              GestureDetector(
                                onTap: () => onTapRemove.call(product),
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: 12, top: 4, bottom: 4),
                                  child: Icon(
                                    Icons.remove,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  product.quantity?.toString() ?? "0",
                                  style: const TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => onTapAdd.call(product),
                                child: const Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      end: 12, top: 4, bottom: 4),
                                  child: Icon(Icons.add,
                                      size: 16, color: Colors.white),
                                ),
                              ),
                            ] else
                              GestureDetector(
                                onTap: () => onTapAdd.call(product),
                                behavior: HitTestBehavior.translucent,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    // horizontal: 28,
                                  ),
                                  child: Text(
                                    AppLocalization.instance
                                        .getLocalizationFor("add"),
                                    style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
