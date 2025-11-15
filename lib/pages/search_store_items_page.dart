import 'dart:async';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/models/product_group.dart';
import 'package:deligo/models/product_group_choice.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/cart_manager.dart';
import 'package:deligo/utility/constants.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:deligo/widgets/custom_divider.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:deligo/widgets/toaster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/product.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';

import 'item_detail_sheet.dart';
import 'list_item_product.dart';
import 'list_item_vendor.dart';
import 'variation_selection_mode_sheet.dart';
import 'variation_selection_sheet.dart';

class SearchStoreItemsPage extends StatelessWidget {
  const SearchStoreItemsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: SearchStoreItemsStateful(),
      );
}

class SearchStoreItemsStateful extends StatefulWidget {
  const SearchStoreItemsStateful({super.key});

  @override
  State<SearchStoreItemsStateful> createState() =>
      _SearchStoreItemsStatefulState();
}

class _SearchStoreItemsStatefulState extends State<SearchStoreItemsStateful>
    with TickerProviderStateMixin
    implements SearchParentInteractor {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late TabController _tabController;
  final GlobalKey<_SearchResultsTabState> _storesGlobalKey =
      GlobalKey<_SearchResultsTabState>();
  final GlobalKey<_SearchResultsTabState> _itemsGlobalKey =
      GlobalKey<_SearchResultsTabState>();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
    _tabController.addListener(() {});
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: RegularAppBar(
          title: AppLocalization.instance.getLocalizationFor("search")),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CustomTextField(
                    bgColor: theme.scaffoldBackgroundColor,
                    hintText:
                        AppLocalization.instance.getLocalizationFor("search"),
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.primaryColorDark,
                      size: 24,
                    ),
                    suffixIcon: _controller.text.trim().isNotEmpty
                        ? IconButton(
                            onPressed: () => _clearSearch(),
                            icon: Icon(
                              Icons.close,
                              color: theme.primaryColorDark,
                              size: 24,
                            ),
                          )
                        : null,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                    controller: _controller,
                  ),
                  Row(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.green,
                        labelColor: theme.primaryColor,
                        labelPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        labelStyle: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                        indicatorPadding:
                            const EdgeInsetsDirectional.only(end: 20),
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        dividerHeight: 0,
                        tabs: [
                          Tab(
                            text: AppLocalization.instance
                                .getLocalizationFor("search_tab_stores"),
                          ),
                          Tab(
                            text: AppLocalization.instance
                                .getLocalizationFor("search_tab_items"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        SearchResultsTab(
                          key: _storesGlobalKey,
                          type: "stores",
                          searchParentInteractor: this,
                        ),
                        SearchResultsTab(
                          key: _itemsGlobalKey,
                          type: "items",
                          searchParentInteractor: this,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  String getInitialQuery() => _controller.text.trim();

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(seconds: 2), () {
      Helper.clearFocus(context);
      if (query.trim().length >= 3 || query.trim().isEmpty) {
        if (query.trim().isEmpty) {
          _clearSearch();
        } else {
          _storesGlobalKey.currentState?.setData(
            allDone: false,
            clearList: true,
            isLoading: true,
            query: query.trim(),
          );
          _itemsGlobalKey.currentState?.setData(
            allDone: false,
            clearList: true,
            isLoading: true,
            query: query.trim(),
          );
        }
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {});
    _storesGlobalKey.currentState?.setData(
      allDone: false,
      clearList: true,
      isLoading: false,
      pageNo: 1,
      query: "",
    );
    _itemsGlobalKey.currentState?.setData(
      allDone: false,
      clearList: true,
      isLoading: false,
      pageNo: 1,
      query: "",
    );
  }
}

class SearchResultsTab extends StatefulWidget {
  final String type;
  final SearchParentInteractor searchParentInteractor;
  const SearchResultsTab({
    super.key,
    required this.type,
    required this.searchParentInteractor,
  });

  @override
  State<SearchResultsTab> createState() => _SearchResultsTabState();
}

class _SearchResultsTabState extends State<SearchResultsTab>
    with AutomaticKeepAliveClientMixin {
  final List<dynamic> _list = [];
  int _pageNo = 1;
  bool _isLoading = false;
  bool _allDone = false;
  String? _query;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if (widget.searchParentInteractor.getInitialQuery().isNotEmpty) {
      setData(
        allDone: false,
        clearList: true,
        isLoading: true,
        query: widget.searchParentInteractor.getInitialQuery(),
      );
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (widget.type == "stores" && state is VendorsLoaded) {
          setData(
            pageNo: state.vendors.meta.current_page ?? 1,
            allDone:
                state.vendors.meta.current_page == state.vendors.meta.last_page,
            clearList: state.vendors.meta.current_page == 1,
            list: state.vendors.data,
            isLoading: false,
          );
        }
        if (widget.type == "stores" && state is VendorsFail) {
          setData(
            isLoading: false,
          );
        }
        if (widget.type != "stores" && state is ProductsLoaded) {
          setData(
            pageNo: state.products.meta.current_page ?? 1,
            allDone: state.products.meta.current_page ==
                state.products.meta.last_page,
            clearList: state.products.meta.current_page == 1,
            list: state.products.data,
            isLoading: false,
          );
        }
        if (widget.type != "stores" && state is ProductsFail) {
          setData(
            isLoading: false,
          );
        }
      },
      child: Scaffold(
        body: RefreshIndicator(
          color: theme.primaryColor,
          onRefresh: () async {
            if (_query != null) {
              if (widget.type == "stores") {
                await BlocProvider.of<FetcherCubit>(context).initFetchVendors(
                  pageNum: 1,
                  text: _query!,
                );
              } else {
                await BlocProvider.of<FetcherCubit>(context).initFetchProducts(
                  pageNum: 1,
                  search: _query!,
                );
              }
            }
          },
          child: _list.isNotEmpty
              ? ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  itemCount: _list.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: widget.type == "stores" ? 24 : 0),
                  itemBuilder: (context, index) {
                    if ((index == _list.length - 1) &&
                        !_isLoading &&
                        !_allDone) {
                      _isLoading = true;
                      if (widget.type == "stores") {
                        BlocProvider.of<FetcherCubit>(context).initFetchVendors(
                          pageNum: _pageNo + 1,
                          text: _query!,
                        );
                      } else {
                        BlocProvider.of<FetcherCubit>(context)
                            .initFetchProducts(
                          pageNum: _pageNo + 1,
                          search: _query!,
                        );
                      }
                    }
                    return widget.type == "stores"
                        ? ListItemVendor(
                            vendor: _list[index],
                            theme: theme,
                          )
                        : Column(
                            children: [
                              ListItemProduct(
                                product: _list[index],
                                theme: theme,
                                onTapItem: (Product product) =>
                                    showItemDetail(product),
                                onTapCustomize: (Product product) =>
                                    variationSelectItem(product),
                                onTapRemove: (Product product) =>
                                    removeItem(product),
                                onTapAdd: (Product product) =>
                                    addProCart(product),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              const CustomDivider(
                                withoutPadding: false,
                              ),
                            ],
                          );
                  },
                )
              : _isLoading
                  ? Loader.circularProgressIndicatorPrimary(context)
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 64,
                              vertical:
                                  MediaQuery.of(context).size.width * 0.5),
                          child: ErrorFinalWidget.errorWithRetry(
                            context: context,
                            message: AppLocalization.instance
                                .getLocalizationFor(
                                    (_query?.isNotEmpty ?? false)
                                        ? "no_vendors_found"
                                        : "search_empty_hint"),
                          ),
                        ),
                      ],
                    ),
        ),
        bottomNavigationBar: widget.type == "stores"
            ? null
            : GestureDetector(
                onTap: () => Navigator.pushNamed(context, PageRoutes.cartPage)
                    .then((value) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                  AppLocalization.instance.getLocalizationFor(
                                      "extraChargesMayApply"),
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      : const SizedBox(),
                ),
              ),
      ),
    );
  }

  void setData({
    int? pageNo,
    bool? allDone,
    bool? clearList,
    List<dynamic>? list,
    bool? isLoading,
    String? query,
  }) {
    if (pageNo != null) {
      _pageNo = pageNo;
    }
    if (allDone != null) {
      _allDone = allDone;
    }
    if (clearList ?? false) {
      _list.clear();
    }
    if (list != null) {
      _list.addAll(list);
    }
    if (isLoading != null) {
      _isLoading = isLoading;
    }
    if (query != null) {
      _query = query;
      if (query.isNotEmpty) {
        if (widget.type == "stores") {
          BlocProvider.of<FetcherCubit>(context).initFetchVendors(
            pageNum: 1,
            text: query.trim(),
          );
        } else {
          BlocProvider.of<FetcherCubit>(context).initFetchProducts(
            pageNum: 1,
            search: query.trim(),
          );
        }
      }
    }
    setState(() {});
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

  void showItemDetail(Product pro) => showModalBottomSheet(
        context: context,
        builder: (context) => ItemDetailSheet(product: pro),
      );

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
      _addOrderMeta(pro);
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
        _addOrderMeta(product);
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
        _addOrderMeta(product);
      }
    });
  }

  void _addOrderMeta(Product product) async {
    Category? category;
    List<Category> homeCats = await LocalDataLayer().getCategoriesHome();
    for (Category hc in homeCats) {
      if (hc.slug ==
          "${Constants.scopeHome}-${product.vendor_products?.first.vendor?.vendorType}") {
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

  void _setupCatProsQuantity() {
    for (Product pro in _list) {
      pro.setup();
    }
  }
}

abstract class SearchParentInteractor {
  String getInitialQuery();
}
