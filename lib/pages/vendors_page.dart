import 'dart:async';

import 'package:deligo/bloc/connectivity_cubit.dart';
import 'package:deligo/config/assets.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/pages/grid_item_vendor.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/placeholders/vendors_page_shimmer.dart';
import 'package:deligo/utility/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/vendor.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/error_final_widget.dart';

import 'list_item_vendor.dart';

class VendorsPage extends StatelessWidget {
  const VendorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    return BlocProvider(
      create: (context) => FetcherCubit(),
      child: VendorsStateful(
        category: args is Category ? args : null,
        vendorType: args is String ? args : null,
      ),
    );
  }
}

class VendorsStateful extends StatefulWidget {
  final Category? category;
  final String? vendorType;
  const VendorsStateful({
    super.key,
    this.vendorType,
    this.category,
  });

  @override
  State<VendorsStateful> createState() => _VendorsStatefulState();
}

class _VendorsStatefulState extends State<VendorsStateful> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<Vendor> _list = [];
  int _pageNo = 1;
  bool _isLoading = true;
  bool _allDone = false;
  bool _showGrid = true;
  //String? _query;
  Timer? _debounce;

  bool get hasCatOrVendorType =>
      widget.category?.id != null || widget.vendorType != null;

  @override
  void initState() {
    super.initState();
    if (hasCatOrVendorType) {
      BlocProvider.of<FetcherCubit>(context).initFetchVendors(
        pageNum: 1,
        catId: widget.category?.id,
        vendorType: widget.vendorType,
      );
    } else {
      _isLoading = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.category?.id == null && widget.vendorType == null) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String titleText = widget.vendorType ??
        widget.category!.vendorType ??
        AppLocalization.instance.getLocalizationFor("places");
    if (titleText == 'food') {
      titleText = AppLocalization.instance.getLocalizationFor("restaurants");
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<ConnectivityCubit, ConnectivityState>(
          listener: (context, state) {
            if (state.isConnected) {
              _reInit();
            }
          },
        ),
        BlocListener<FetcherCubit, FetcherState>(
          listener: (context, state) {
            if (state is VendorsLoaded) {
              _pageNo = state.vendors.meta.current_page ?? 1;
              _allDone = state.vendors.meta.current_page ==
                  state.vendors.meta.last_page;
              if (state.vendors.meta.current_page == 1) {
                _list.clear();
              }
              _list.addAll(state.vendors.data);
              _isLoading = false;
              setState(() {});
            }
            if (state is VendorsFail) {
              _isLoading = false;
              setState(() {});
            }
          },
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        (widget.category?.id == null &&
                                widget.vendorType == null)
                            ? AppLocalization.instance
                                .getLocalizationFor("search")
                            : (widget.category?.title ??
                                "${widget.vendorType?.capitalizeFirst()}"),
                        style: theme.textTheme.headlineSmall!
                            .copyWith(fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Toggle view button
                  IconButton(
                    onPressed: () => setState(() => _showGrid = !_showGrid),
                    icon: Icon(
                      _showGrid ? Icons.list : Icons.grid_view,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    children: [
                      CustomTextField(
                        bgColor: theme.scaffoldBackgroundColor,
                        hintText: AppLocalization.instance
                            .getLocalizationFor("search"),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.primaryColorDark,
                          size: 24,
                        ),
                        suffixIcon: _controller.text.trim().isNotBlank
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
                      if (_list.isNotEmpty &&
                          (_list.first.id > 0 ||
                              (_list.length > 1 && _list[1].id > 0)))
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              "${titleText.capitalizeFirst()} ${AppLocalization.instance.getLocalizationFor("nearMe")}",
                              textAlign: TextAlign.start,
                              style: theme.textTheme.titleLarge!.copyWith(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      Expanded(
                        child: RefreshIndicator(
                          key: _refreshIndicatorKey,
                          color: theme.primaryColor,
                          onRefresh: () async {
                            if (hasCatOrVendorType ||
                                _controller.text.trim().isNotEmpty) {
                              await BlocProvider.of<FetcherCubit>(context)
                                  .initFetchVendors(
                                pageNum: 1,
                                catId: widget.category?.id,
                                vendorType: widget.vendorType,
                                text: _controller.text.trim(),
                              );
                            }
                          },
                          child: _list.isNotEmpty
                              ? (_showGrid
                                  ? GridView.builder(
                                      padding: const EdgeInsets.only(top: 16),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 0.63,
                                      ),
                                      itemCount: _list.length,
                                      itemBuilder: (context, index) {
                                        if ((index == _list.length - 1) &&
                                            !_isLoading &&
                                            !_allDone) {
                                          _isLoading = true;
                                          BlocProvider.of<FetcherCubit>(context)
                                              .initFetchVendors(
                                            pageNum: _pageNo + 1,
                                            catId: widget.category?.id,
                                            vendorType: widget.vendorType,
                                            text: _controller.text.trim(),
                                          );
                                        }
                                        return GridItemVendor(
                                          theme: theme,
                                          vendor: _list[index],
                                        );
                                      },
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.only(top: 16),
                                      itemCount: _list.length,
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      separatorBuilder: (context, index) =>
                                          const SizedBox(height: 24),
                                      itemBuilder: (context, index) {
                                        if ((index == _list.length - 1) &&
                                            !_isLoading &&
                                            !_allDone) {
                                          _isLoading = true;
                                          BlocProvider.of<FetcherCubit>(context)
                                              .initFetchVendors(
                                            pageNum: _pageNo + 1,
                                            catId: widget.category?.id,
                                            vendorType: widget.vendorType,
                                            text: _controller.text.trim(),
                                          );
                                        }
                                        return ListItemVendor(
                                          vendor: _list[index],
                                          theme: theme,
                                        );
                                      },
                                    ))
                              : _isLoading
                                  ? VendorsPageShimmer()
                                  : ListView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 64,
                                              vertical: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5),
                                          child:
                                              ErrorFinalWidget.errorWithRetry(
                                            context: context,
                                            imageAsset: BlocProvider.of<
                                                            ConnectivityCubit>(
                                                        context)
                                                    .isConnected
                                                ? null
                                                : Assets.emptyOrders,
                                            message: AppLocalization.instance
                                                .getLocalizationFor(BlocProvider
                                                            .of<ConnectivityCubit>(
                                                                context)
                                                        .isConnected
                                                    ? (_controller.text
                                                            .trim()
                                                            .isNotEmpty
                                                        ? "no_vendors_found"
                                                        : "search_empty_hint")
                                                    : "network_issue"),
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(seconds: 2), () {
      Helper.clearFocus(context);
      if (query.trim().length >= 3 || query.trim().isEmpty) {
        if (query.trim().isEmpty) {
          _clearSearch();
        } else {
          _isLoading = true;
          _allDone = false;
          _list.clear();
          setState(() {});
          BlocProvider.of<FetcherCubit>(context).initFetchVendors(
            pageNum: 1,
            catId: widget.category?.id,
            vendorType: widget.vendorType,
            text: query.trim(),
          );
        }
      }
    });
  }

  void _clearSearch() {
    _list.clear();
    _pageNo = 1;
    _isLoading = false;
    _allDone = false;
    _controller.clear();
    if (hasCatOrVendorType) {
      _isLoading = true;
      BlocProvider.of<FetcherCubit>(context).initFetchVendors(
        pageNum: 1,
        catId: widget.category?.id,
        vendorType: widget.vendorType,
      );
    }
    setState(() {});
  }

  void _reInit() {
    Helper.clearFocus(context);
    _refreshIndicatorKey.currentState?.show();
  }
}
