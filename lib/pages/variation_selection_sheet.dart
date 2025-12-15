import 'package:deligo/config/assets.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/product.dart';
import 'package:deligo/models/product_group.dart';
import 'package:deligo/models/product_group_choice.dart';
import 'package:deligo/widgets/custom_divider.dart';
import 'package:deligo/utility/cart_manager.dart';
import 'package:deligo/widgets/toaster.dart';
import 'package:flutter/material.dart';

class VariationSelectionSheet extends StatefulWidget {
  final Product product;
  final List<CartItemAddOn> addOnsExisting;
  const VariationSelectionSheet({
    super.key,
    required this.product,
    required this.addOnsExisting,
  });

  @override
  State<VariationSelectionSheet> createState() =>
      _VariationSelectionSheetState();
}

class _VariationSelectionSheetState extends State<VariationSelectionSheet> {
  @override
  void initState() {
    _setupAddOns();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // CachedImage(
                //   imageUrl: widget.product.imageUrls?.firstOrNull,
                //   height: MediaQuery.of(context).size.width * 0.24,
                //   width: MediaQuery.of(context).size.width * 0.24,
                // ),
                // const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Text(
                          widget.product.title,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.priceFormatted ?? "",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    //const Spacer(),
                  ],
                ),

                GestureDetector(
                  onTap: () => addChoice(),
                  child: Container(
                    height: 32,
                    width: MediaQuery.of(context).size.width * 0.22,
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
                        AppLocalization.instance.getLocalizationFor("add"),
                        style: TextStyle(
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            CustomDivider(),
            const SizedBox(height: 8),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.product.addon_groups!.length,
              separatorBuilder: (context, mainIndex) => const CustomDivider(),
              itemBuilder: (context, mainIndex) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.addon_groups![mainIndex].title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.product.addon_groups![mainIndex].max_choices == 1)
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.product.addon_groups![mainIndex]
                          .addon_choices.length,
                      itemBuilder: (context, innerIndex) =>
                          // ignore: deprecated_member_use
                          RadioListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                widget.product.addon_groups![mainIndex]
                                    .addon_choices[innerIndex].title,
                                style: theme.textTheme.bodyMedium),
                            Text(
                              widget
                                      .product
                                      .addon_groups![mainIndex]
                                      .addon_choices[innerIndex]
                                      .priceFormatted ??
                                  "",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        value: widget.product.addon_groups![mainIndex]
                          .addon_choices[innerIndex].id,
                        groupValue: widget
                          .product.addon_groups![mainIndex].choiceIdSelected,
                        onChanged: (value) => setState(() => widget.product
                          .addon_groups![mainIndex].choiceIdSelected = value),
                      ),
                    )
                  else
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.product.addon_groups![mainIndex]
                          .addon_choices.length,
                      itemBuilder: (context, innerIndex) => CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                widget.product.addon_groups![mainIndex]
                                    .addon_choices[innerIndex].title,
                                style: theme.textTheme.bodyMedium),
                            Text(
                              widget
                                      .product
                                      .addon_groups![mainIndex]
                                      .addon_choices[innerIndex]
                                      .priceFormatted ??
                                  "",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        value: widget.product.addon_groups![mainIndex]
                            .addon_choices[innerIndex].selected,
                        onChanged: (value) => setState(() => widget
                            .product
                            .addon_groups![mainIndex]
                            .addon_choices[innerIndex]
                            .selected = value),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setupAddOns() {
    for (ProductGroup group in (widget.product.addon_groups ?? [])) {
      group.choiceIdSelected = -1;

      if (group.addon_choices.isNotEmpty) {
        //SET SELECTED TRUE FOR add_ons_existing
        for (ProductGroupChoice choice in group.addon_choices) {
          choice.selected = false;
          for (CartItemAddOn ae in widget.addOnsExisting) {
            if (ae.id == choice.id) {
              choice.selected = true;
              group.choiceIdSelected = choice.id;
              break;
            }
          }
        }
        //CHECK FOR MINIMUM SELECTION
        if (group.min_choices > 0) {
          int selectedCount = 0;
          for (ProductGroupChoice choice in group.addon_choices) {
            if (choice.selected ?? false) {
              selectedCount += 1;
            }
          }
          if (selectedCount < group.min_choices) {
            int checksLeft = group.min_choices - selectedCount;
            for (ProductGroupChoice choice in group.addon_choices) {
              if (!(choice.selected ?? false) && checksLeft > 0) {
                choice.selected = true;
                group.choiceIdSelected = choice.id;
                checksLeft -= 1;
              }
            }
          }
        }
      }
    }
  }

  void addChoice() {
    List<ProductGroupChoice> selectedChoices = [];
    bool canProceed = true;
    for (ProductGroup group in (widget.product.addon_groups ?? [])) {
      List<ProductGroupChoice> groupChoicesSelected = [];
      if (group.addon_choices.isNotEmpty) {
        for (ProductGroupChoice choice in group.addon_choices) {
          if (choice.selected ?? false) {
            groupChoicesSelected.add(choice);
          }
        }
      }
      if (group.min_choices > groupChoicesSelected.length) {
        Toaster.showToastBottom(
            "${group.title} ${AppLocalization.instance.getLocalizationFor("addon_choices_lessthan_err")} ${group.min_choices}");
        selectedChoices = [];
        canProceed = false;
        break;
      } else if (groupChoicesSelected.length > group.max_choices) {
        Toaster.showToastBottom(
            "${group.title} ${AppLocalization.instance.getLocalizationFor("addon_choices_morethan_err")} ${group.max_choices}");
        selectedChoices = [];
        canProceed = false;
        break;
      } else {
        selectedChoices.addAll(groupChoicesSelected);
      }
    }
    if (canProceed) {
      Navigator.pop(context, selectedChoices);
    }
  }
}
