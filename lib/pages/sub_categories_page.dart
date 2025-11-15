import 'package:deligo/config/colors.dart';
import 'package:deligo/utility/placeholders/sub_categories_page_shimmer.dart';
import 'package:deligo/utility/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/models/vendor.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/widget_size.dart';

import 'list_item_vendor.dart';

class SubCategoriesPage extends StatelessWidget {
  const SubCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: SubCategoriesStateful(
          ModalRoute.of(context)!.settings.arguments as Category,
        ),
      );
}

class SubCategoriesStateful extends StatefulWidget {
  final Category category;
  const SubCategoriesStateful(this.category, {super.key});

  @override
  State<SubCategoriesStateful> createState() => _SubCategoriesStatefulState();
}

class _SubCategoriesStatefulState extends State<SubCategoriesStateful> {
  Size? _headerSize;
  final List<Vendor> _list = [];
  int _pageNo = 1;
  bool _isLoading = true;
  bool _allDone = false;
  List<Category> _listCategories = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetcherCubit>(context)
        .initFetchCategoriesWithVendorType(widget.category.vendorType!);
    BlocProvider.of<FetcherCubit>(context).initFetchVendors(
      pageNum: 1,
      vendorType: widget.category.vendorType,
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    String titleText = widget.category.vendorType ?? 'Places';
    if (titleText == 'food') {
      titleText = 'Restaurants';
    }
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is CategoriesLoaded) {
          _listCategories = state.categories;
          if (_list.firstOrNull != Vendor.placeholder) {
            _list.insert(0, Vendor.placeholder);
          }
          setState(() {});
        }
        if (state is VendorsLoaded) {
          _pageNo = state.vendors.meta.current_page ?? 1;
          _allDone =
              state.vendors.meta.current_page == state.vendors.meta.last_page;
          if (state.vendors.meta.current_page == 1) {
            _list.clear();
          }
          _list.addAll(state.vendors.data);
          if (_list.firstOrNull != Vendor.placeholder) {
            _list.insert(0, Vendor.placeholder);
          }
          _isLoading = false;
          setState(() {});
        }
        if (state is VendorsFail) {
          if (_list.firstOrNull != Vendor.placeholder) {
            _list.insert(0, Vendor.placeholder);
          }
          _isLoading = false;
          setState(() {});
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            FractionallySizedBox(
              heightFactor: 0.25,
              widthFactor: 1.0,
              child: WidgetSize(
                child: CachedImage(
                  imageUrl: widget.category.imageBannerUrl,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
                onChange: (size) => setState(
                    () => _headerSize = Size(double.infinity, size.height)),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios_new, color: blackColor),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      widget.category.title,
                      style: theme.textTheme.headlineSmall!
                          .copyWith(color: blackColor),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              top: (_headerSize?.height ?? 0) - 40,
              height: MediaQuery.of(context).size.height -
                  (_headerSize?.height ?? 0) +
                  40,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      bgColor: theme.scaffoldBackgroundColor,
                      hintText: AppLocalization.instance
                          .getLocalizationFor("searchItemOrStore"),
                      prefixIcon: Icon(Icons.search,
                          color: theme.primaryColorDark, size: 24),
                      readOnly: true,
                      onTap: () => Navigator.pushNamed(
                          context, PageRoutes.searchStoreItemsPage),
                    ),
                    // ListTile(
                    //   contentPadding: EdgeInsets.zero,
                    //   title: Text(
                    //     widget.subtitle,
                    //     style: theme.textTheme.headlineSmall!.copyWith(
                    //       fontSize: 18,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                    //   subtitle: Text(
                    //     "Place order",
                    //     style: theme.textTheme.bodySmall!.copyWith(
                    //       fontSize: 13,
                    //       color: theme.hintColor,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: RefreshIndicator(
                        color: Theme.of(context).primaryColor,
                        onRefresh: () => BlocProvider.of<FetcherCubit>(context)
                            .initFetchVendors(
                          pageNum: 1,
                          vendorType: widget.category.vendorType,
                        ),
                        child: _listCategories.isNotEmpty || _list.length > 1
                            ? ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: _list.length,
                                //itemCount: 100,
                                physics: const AlwaysScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  if ((index == _list.length - 1) &&
                                      !_isLoading &&
                                      !_allDone) {
                                    _isLoading = true;
                                    BlocProvider.of<FetcherCubit>(context)
                                        .initFetchVendors(
                                      pageNum: _pageNo + 1,
                                      vendorType: widget.category.vendorType,
                                    );
                                  }
                                  // int index =
                                  //     i < _list.length ? i : _list.length - 1;
                                  return _list[index] == Vendor.placeholder
                                      ? _categoriesWidget(titleText)
                                      : ListItemVendor(
                                          vendor: _list[index],
                                          theme: theme,
                                        );
                                },
                              )
                            : _isLoading
                                ? SubCategoriesPageShimmer()
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
                                        child: ErrorFinalWidget.errorWithRetry(
                                          context: context,
                                          message: AppLocalization.instance
                                              .getLocalizationFor(
                                                  "no_vendors_found"),
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoriesWidget(String titleText) {
    if (_listCategories.isEmpty) {
      return const SizedBox.shrink();
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _listCategories.length,
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, PageRoutes.vendorsPage,
                  arguments: _listCategories[index]),
              child: GridTile(
                footer: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                      child: Text(
                    _listCategories[index].title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold, color: blackColor),
                  )),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: CachedImage(
                    imageUrl: _listCategories[index].imageUrl,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_list.isNotEmpty &&
              (_list.first.id > 0 || (_list.length > 1 && _list[1].id > 0)))
            Text(
              "${titleText.capitalizeFirst()} ${AppLocalization.instance.getLocalizationFor("nearMe")}",
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          //const SizedBox(height: 16),
        ],
      );
    }
  }
}
