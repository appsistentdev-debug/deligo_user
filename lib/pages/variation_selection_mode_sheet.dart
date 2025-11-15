import 'package:deligo/config/assets.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/product.dart';
import 'package:deligo/widgets/custom_divider.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/cart_manager.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:flutter/material.dart';

class VariationSelectionModeSheet extends StatefulWidget {
  final Product product;
  final List<CartItemAddOn> addOnsExisting;
  const VariationSelectionModeSheet(
      {super.key, required this.product, required this.addOnsExisting});

  @override
  State<VariationSelectionModeSheet> createState() =>
      _VariationSelectionModeSheetState();
}

class _VariationSelectionModeSheetState
    extends State<VariationSelectionModeSheet> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CachedImage(
                imageUrl: widget.product.imageUrls?.firstOrNull,
                height: MediaQuery.of(context).size.width * 0.24,
                width: MediaQuery.of(context).size.width * 0.24,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width * 0.20,
                width: MediaQuery.of(context).size.width * 0.66,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (widget.product.foodType != null)
                          Image.asset(
                            widget.product.foodType == "veg"
                                ? Assets.foodFoodVeg
                                : Assets.foodFoodNonveg,
                            height: 16,
                          ),
                        if (widget.product.foodType != null)
                          const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.product.title,
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
                    Text(
                      widget.product.priceFormatted ?? "",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalization.instance
                .getLocalizationFor("repeat_last_used_customisation"),
            style: theme.textTheme.headlineSmall!.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: widget.addOnsExisting.length,
            separatorBuilder: (context, index) => const CustomDivider(),
            itemBuilder: (context, index) => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.addOnsExisting[index].title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                Text(
                  "${AppSettings.currencyIcon} ${Helper.formatNumber(num.tryParse("${widget.addOnsExisting[index].price}") ?? 0)}",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => actionNew(),
                child: Container(
                  height: 32,
                  // width: MediaQuery.of(context).size.width * 0.22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: theme.primaryColor),
                    color: theme.scaffoldBackgroundColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Center(
                    child: Text(
                      AppLocalization.instance
                          .getLocalizationFor("i_ll_choose"),
                      style: TextStyle(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => actionOld(),
                child: Container(
                  height: 32,
                  // width: MediaQuery.of(context).size.width * 0.22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: theme.primaryColor),
                    color: theme.scaffoldBackgroundColor,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Center(
                    child: Text(
                      AppLocalization.instance
                          .getLocalizationFor("repeat_last"),
                      style: TextStyle(
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void actionNew() => Navigator.pop(context, "new");

  void actionOld() => Navigator.pop(context, "repeat");
}
