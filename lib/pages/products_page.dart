import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/colors.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/base_list_response.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/models/product.dart';
import 'package:deligo/models/product_group.dart';
import 'package:deligo/models/product_group_choice.dart';
import 'package:deligo/models/vendor.dart';
import 'package:deligo/pages/list_item_product.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/cart_manager.dart';
import 'package:deligo/utility/constants.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:deligo/widgets/custom_divider.dart';
import 'package:deligo/widgets/custom_shadow.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/toaster.dart';

import 'item_detail_sheet.dart';
import 'variation_selection_mode_sheet.dart';
import 'variation_selection_sheet.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: ProductsStateful(
            ModalRoute.of(context)!.settings.arguments as Vendor),
      );
}

class ProductsStateful extends StatefulWidget {
  final Vendor vendor;
  const ProductsStateful(this.vendor, {super.key});

  @override
  State<ProductsStateful> createState() => _ProductsStatefulState();
}

class _ProductsStatefulState extends State<ProductsStateful> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  // late MenuController _controller;
  final List<ExpansibleController> _expansionTileControllers = [];
  final Map<Category, ListResponse<Product>> _catPros = {};

  @override
  void initState() {
    _setupCatPros();
    super.initState();
    if (_catPros.isNotEmpty) {
      BlocProvider.of<FetcherCubit>(context).initFetchProducts(
        pageNum: 1,
        vendorId: widget.vendor.id,
        categoryId: _catPros.keys.elementAt(0).id,
        pagination: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is ProductsLoading && state.categoryId != null) {
          _catPros[Category.fromJson({"id": state.categoryId, "title": ""})]
              ?.isLoading = true;
          setState(() {});
        }
        if (state is ProductsListLoaded && state.categoryId != null) {
          _catPros[Category.fromJson({"id": state.categoryId, "title": ""})]
              ?.list = state.products;
          _catPros[Category.fromJson({"id": state.categoryId, "title": ""})]
              ?.isLoading = false;
          _catPros[Category.fromJson({"id": state.categoryId, "title": ""})]
              ?.allDone = true;
          setState(() {});
          Future.delayed(const Duration(milliseconds: 100),
              () => _expandTile(state.categoryId!));
        }
        if (state is ProductsFail && state.categoryId != null) {
          _catPros[Category.fromJson({"id": state.categoryId, "title": ""})]
              ?.isLoading = false;
          _catPros[Category.fromJson({"id": state.categoryId, "title": ""})]
              ?.allDone = true;
          setState(() {});
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          // actions: [
          //   // IconButton(
          //   //   onPressed: () => Navigator.pop(context),
          //   //   icon: const Icon(Icons.favorite_border),
          //   // ),
          //   IconButton(
          //     onPressed: () {},
          //     icon: const Icon(Icons.search),
          //   ),
          // ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.vendor.name,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${widget.vendor.address ?? ""}  |  ${widget.vendor.distanceFormatted}",
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const CustomDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${widget.vendor.ratings_count ?? 0} ${AppLocalization.instance.getLocalizationFor("ratings")}",
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  color: Colors.green.shade700,
                                  //size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.vendor.ratingsFormatted ?? "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              //AppLocalization.instance.getLocalizationFor("distance"),
                              AppLocalization.instance
                                  .getLocalizationFor("preperation_in"),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_bike_outlined,
                                  color: Colors.green.shade700,
                                  //size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  //widget.vendor.distanceFormatted ?? "0m",
                                  "${widget.vendor.preperationTime} ${AppLocalization.instance.getLocalizationFor("mins")}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const CustomShadow(),
            Expanded(
              child: ScrollablePositionedList.separated(
                itemScrollController: _itemScrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _catPros.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                separatorBuilder: (context, index) => CustomDivider(),
                itemBuilder: (context, outerIndex) => Column(
                  children: [
                    ExpansionTile(
                      controller: _expansionTileControllers[outerIndex],
                      onExpansionChanged: (bool isExpanding) {
                        if (isExpanding) {
                          _collapseTile(outerIndex);
                        }
                        if (!_catPros.values.elementAt(outerIndex).isLoading &&
                            !_catPros.values.elementAt(outerIndex).allDone &&
                            _catPros.values
                                .elementAt(outerIndex)
                                .list
                                .isEmpty) {
                          BlocProvider.of<FetcherCubit>(context)
                              .initFetchProducts(
                            pageNum: 1,
                            vendorId: widget.vendor.id,
                            categoryId: _catPros.keys.elementAt(outerIndex).id,
                            pagination: false,
                          );
                        }
                      },
                      collapsedIconColor: greyTextColor2,
                      iconColor: orderBlack,
                      trailing: _catPros.values.elementAt(outerIndex).isLoading
                          ? SizedBox(
                              width: 40,
                              height: 40,
                              child: Transform.scale(
                                scale: 0.5,
                                child: Loader.circularProgressIndicatorPrimary(
                                    context),
                              ),
                            )
                          : null,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(top: 16),
                      dense: true,
                      shape: InputBorder.none,
                      title: Text(
                        _catPros.keys.elementAt(outerIndex).title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      enabled: true,
                      children: [
                        _catPros.values.elementAt(outerIndex).list.isNotEmpty
                            ? ListView.separated(
                                itemCount: _catPros.values
                                    .elementAt(outerIndex)
                                    .list
                                    .length,
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                separatorBuilder: (context, index) =>
                                    const CustomDivider(),
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, innerIndex) =>
                                    ListItemProduct(
                                  theme: theme,
                                  product: _catPros.values
                                      .elementAt(outerIndex)
                                      .list[innerIndex],
                                  onTapItem: (Product product) =>
                                      showItemDetail(product),
                                  onTapCustomize: (Product product) =>
                                      variationSelectItem(product),
                                  onTapRemove: (Product product) =>
                                      removeItem(product),
                                  onTapAdd: (Product product) =>
                                      addProCart(product),
                                ),
                              )
                            : _catPros.values.elementAt(outerIndex).isLoading
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: ErrorFinalWidget.errorWithRetry(
                                      context: context,
                                      message: AppLocalization.instance
                                          .getLocalizationFor(
                                              "no_products_found"),
                                    ),
                                  ),
                      ],
                    ),
                    if (outerIndex == _catPros.length - 1)
                      const SizedBox(
                        height: 70,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Builder(builder: (context) {
          final isRestaurant = widget.vendor.vendorType == 'food';
          final text = isRestaurant
              ? AppLocalization.instance.getLocalizationFor("menu")
              : AppLocalization.instance.getLocalizationFor("list");
          final icon = isRestaurant ? Icons.restaurant_menu : Icons.list_alt;
          return SizedBox(
            height: 40,
            child: FloatingActionButton.extended(
              icon: Icon(
                icon,
                size: 20,
                color: isDark
                    ? theme.primaryColorDark
                    : theme.scaffoldBackgroundColor,
              ),
              label: Text(text),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(36)),
              backgroundColor: isDark ? mainColor : theme.primaryColorDark,
              foregroundColor: isDark
                  ? theme.primaryColorDark
                  : theme.scaffoldBackgroundColor,
              extendedIconLabelSpacing: 8,
              onPressed: () => _showCategoryMenu(context),
            ),
          );
        }),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 16.0, left: 8, right: 8),
          child: GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, PageRoutes.cartPage).then((value) {
              _setupCatProsQuantity();
              setState(() {});
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              height: CartManager().cartItemsCount > 0 ? 60 : 0,
              margin: CartManager().cartItemsCount > 0
                  ? const EdgeInsets.all(10)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: theme.primaryColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CartManager().cartItemsCount > 0
                  ? Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${CartManager().cartItemsCount} ${AppLocalization.instance.getLocalizationFor("items")} • ${AppSettings.currencyIcon} ${Helper.formatNumber(CartManager().cartItemsTotal)}",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              AppLocalization.instance
                                  .getLocalizationFor("extraChargesMayApply"),
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey.shade300),
                            )
                          ],
                        ),
                        const Spacer(),
                        const Icon(Icons.shopping_basket_outlined,
                            color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          AppLocalization.instance
                              .getLocalizationFor("viewCart"),
                          style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset buttonPosition =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final Size buttonSize = button.size;
    final double buttonCenterX = buttonPosition.dx + (buttonSize.width / 2);

    double maxTextWidth = 0;
    const double menuItemHeight = 48.0;

    final TextStyle textStyle = Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(
            color: Theme.of(context).primaryColorDark,
            fontWeight: FontWeight.bold);

    for (final category in _catPros.keys) {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: category.title, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      maxTextWidth = math.max(maxTextWidth, textPainter.width);
    }

    final double menuWidth = (maxTextWidth + 32).clamp(150.0, 250.0);
    final double menuLeft = (buttonCenterX - (menuWidth / 2))
        .clamp(16.0, overlay.size.width - menuWidth - 16.0);

    final double fabTop = buttonPosition.dy;
    final double desiredMenuHeight = _catPros.length * menuItemHeight;
    final double availableHeight = fabTop - 16;
    final double gapAboveFab = 8.0;
    final double menuHeight =
        desiredMenuHeight.clamp(0.0, availableHeight - gapAboveFab);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(
        menuLeft,
        fabTop - menuHeight - gapAboveFab,
        menuLeft + menuWidth,
        overlay.size.height - fabTop + buttonSize.height,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? darkBottomNavBarColor : Colors.white,
      elevation: 8,
      constraints: BoxConstraints(
        minWidth: menuWidth,
        maxWidth: menuWidth,
        maxHeight: menuHeight,
      ),
      items: List.generate(
        _catPros.length,
        (index) => PopupMenuItem<int>(
          value: index,
          height: menuItemHeight,
          child: SizedBox(
            width: menuWidth,
            child: Text(
              _catPros.keys.elementAt(index).title,
              style: textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ).then((selectedIndex) {
      if (selectedIndex != null) {
        _expandTile(_catPros.keys.elementAt(selectedIndex).id);
      }
    });
  }

  void _setupCatPros() {
    for (Category cat in widget.vendor.product_categories ?? []) {
      _expansionTileControllers.add(ExpansibleController());
      _catPros[cat] = ListResponse([], 1, false, false);
    }
    if (_catPros.isNotEmpty) _catPros.values.elementAt(0).isLoading = true;
  }

  void _setupCatProsQuantity() {
    for (ListResponse<Product> pros in _catPros.values) {
      for (Product pro in pros.list) {
        pro.setup();
      }
    }
  }

  void _expandTile(int categoryId) {
    int indexOpenAt = 0;
    for (int i = 0; i < _catPros.length; i++) {
      if (_catPros.keys.elementAt(i).id == categoryId) {
        indexOpenAt = i;
        _expansionTileControllers[i].expand();
      } else {
        _expansionTileControllers[i].collapse();
      }
    }
    _itemScrollController.scrollTo(
      index: indexOpenAt,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _collapseTile(int expandedIndex) {
    for (int i = 0; i < _catPros.length; i++) {
      if (expandedIndex != i) {
        _expansionTileControllers[i].collapse();
      }
    }
    _itemScrollController.scrollTo(
      index: expandedIndex,
      duration: const Duration(milliseconds: 500),
    );
  }

  void variationSelectItem(Product pro) {
    if (!(pro.stockQuantity == -1 || (pro.stockQuantity ?? 0) > 0)) {
      Toaster.showToastBottom(
          AppLocalization.instance.getLocalizationFor("pro_out_stock"));
      return;
    }
    bool addOnsAvailable = false;
    for (ProductGroup group in (pro.addon_groups ?? [])) {
      if (group.addon_choices.isNotEmpty) {
        addOnsAvailable = true;
        break;
      }
    }
    if (!addOnsAvailable) {
      CartManager().removeCartItemWithProductId(
          pro.vendor_products?.firstOrNull?.id ?? pro.id);
      Toaster.showToastBottom(
          AppLocalization.instance.getLocalizationFor("no_cust_avail"));
      return;
    }
    List<CartItem> existingCartItems = CartManager().getCartItemsWithProductId(
        pro.vendor_products?.firstOrNull?.id ?? pro.id);
    if (existingCartItems.length > 1) {
      _confirmVariationSelectionMode(pro, existingCartItems);
    } else {
      _proceedVariationSelection(pro);
    }
  }

  void showItemDetail(Product pro) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ItemDetailSheet(product: pro),
    );
  }

  void addProCart(Product pro) {
    if (!(pro.stockQuantity == -1 || (pro.stockQuantity ?? 0) > 0)) {
      Toaster.showToastBottom(
          AppLocalization.instance.getLocalizationFor("pro_out_stock"));
      return;
    }
    if (CartManager().cartItems.isNotEmpty &&
        CartManager().cartItems.first.meta["vendor_id"] !=
            pro.vendor_products?.firstOrNull?.vendor_id) {
      ConfirmDialog.showConfirmation(
              context,
              Text(AppLocalization.instance.getLocalizationFor("clear_cart")),
              Text(AppLocalization.instance
                  .getLocalizationFor("clear_cart_message")),
              AppLocalization.instance.getLocalizationFor("cancel"),
              AppLocalization.instance.getLocalizationFor("clear_now"))
          .then((value) {
        if (value != null && value == true) {
          CartManager().clearCart().then((value) => setState(() {}));
        }
      });
      return;
    }

    List<CartItem> existingCartItems = CartManager().getCartItemsWithProductId(
        pro.vendor_products?.firstOrNull?.id ?? pro.id);
    if (existingCartItems.isNotEmpty &&
        existingCartItems.first.addOns.isNotEmpty) {
      _confirmVariationSelectionMode(pro, existingCartItems);
    } else if (pro.addOnChoicesIsMust ?? false) {
      _proceedVariationSelection(pro);
    } else {
      CartManager().addOrIncrementCartItem(
          CartManager().genCartItemFromProduct(pro, []));
      pro.quantity = (pro.quantity ?? 0) + 1;
      setState(() {});
      _addOrderMeta();
    }
  }

  void removeItem(Product pro) {
    List<CartItem> existingCartItems = CartManager().getCartItemsWithProductId(
        pro.vendor_products?.firstOrNull?.id ?? pro.id);
    if (existingCartItems.length > 1) {
      ConfirmDialog.showConfirmation(
              context,
              Text(AppLocalization.instance
                  .getLocalizationFor("remove_item_title")),
              Text(AppLocalization.instance
                  .getLocalizationFor("remove_item_msg")),
              AppLocalization.instance.getLocalizationFor("cancel"),
              AppLocalization.instance.getLocalizationFor("go_cart"))
          .then((value) {
        if (value != null && value == true) {
          Navigator.pushNamed(context, PageRoutes.cartPage);
        }
      });
    } else {
      CartManager().removeOrDecrementCartItem(CartManager()
          .genCartItemFromProduct(pro, existingCartItems.firstOrNull?.addOns));
      pro.quantity = pro.quantity == 0 ? 0 : (pro.quantity ?? 0) - 1;
      setState(() {});
    }
  }

  void _confirmVariationSelectionMode(
      Product product, List<CartItem> existingCartsItem) {
    List<CartItemAddOn> addOns = [];
    for (CartItem ci in existingCartsItem) {
      addOns.addAll(ci.addOns);
    }
    showModalBottomSheet(
      context: context,
      builder: (context) => VariationSelectionModeSheet(
        product: product,
        addOnsExisting: addOns,
      ),
    ).then((value) {
      if (value == "repeat") {
        CartManager().addOrIncrementCartItem(
            existingCartsItem[existingCartsItem.length - 1]);
        product.quantity = (product.quantity ?? 0) + 1;
        setState(() {});
        _addOrderMeta();
      } else if (value == "new") {
        _proceedVariationSelection(product);
      }
    });
  }

  void _proceedVariationSelection(Product product) {
    showModalBottomSheet(
      context: context,
      builder: (context) => VariationSelectionSheet(
        product: product,
        addOnsExisting: const [],
      ),
    ).then((value) {
      if (value is List<ProductGroupChoice> && value.isNotEmpty) {
        List<CartItemAddOn> ciChoices = [];
        for (ProductGroupChoice proChoice in value) {
          ciChoices.add(CartItemAddOn(
            id: proChoice.id,
            title: proChoice.title,
            price: proChoice.price,
            priceToShow:
                "${AppSettings.currencyIcon} ${Helper.formatNumber(num.tryParse("${proChoice.price}") ?? 0)}",
          ));
        }
        CartManager().addOrIncrementCartItem(
            CartManager().genCartItemFromProduct(product, ciChoices));
        product.quantity = (product.quantity ?? 0) + 1;
        setState(() {});
        _addOrderMeta();
      }
    });
  }

  void _addOrderMeta() async {
    Category? category;
    List<Category> homeCats = await LocalDataLayer().getCategoriesHome();
    for (Category hc in homeCats) {
      if (hc.slug == "${Constants.scopeHome}-${widget.vendor.vendorType}") {
        category = hc;
      }
    }
    if (category != null) {
      category.setup();
      CartManager().orderMeta.addAll({
        "category_id": category.id.toString(),
        "category_slug": category.slug ?? "",
        "category_title": category.title,
        "category_image": category.imageUrl ?? "",
        //cust, whether vendor has takeaway enabled or not is controlled via category.meta.has_takeaway
        "has_takeaway": category.hasTakeaway?.toString() ?? "false",
        //cust, whether vendor has takeaway enabled or not is controlled via category.meta.has_takeaway
      });
    }
  }
}
