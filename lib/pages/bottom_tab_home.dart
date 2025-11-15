import 'package:carousel_slider/carousel_slider.dart';
import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/colors.dart';
import 'package:deligo/models/address.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/models/vendor.dart';
import 'package:deligo/pages/ride_type_selection_sheet.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/cart_manager.dart';
import 'package:deligo/utility/constants.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/utility/string_extensions.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/toaster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deligo/models/category.dart' as my_category;
import 'package:shimmer/shimmer.dart';

import 'list_item_vendor.dart';

class BottomTabHome extends StatelessWidget {
  final GlobalKey<TabHomeStatefulState> homeTabKey;
  const BottomTabHome({super.key, required this.homeTabKey});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: TabHomeStateful(
          key: homeTabKey,
        ),
      );
}

class TabHomeStateful extends StatefulWidget {
  const TabHomeStateful({super.key});

  @override
  State<TabHomeStateful> createState() => TabHomeStatefulState();
}

class TabHomeStatefulState extends State<TabHomeStateful>
    with AutomaticKeepAliveClientMixin {
  Address? _address;
  List<my_category.Category>? _categories;
  List<Category>? _banners;
  int _activeBannerId = 0;
  final Map<String, List<Vendor>> _typeVends = {};
  EdgeInsets horizontalPadding = const EdgeInsets.symmetric(horizontal: 16.0);

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetcherCubit>(context)
        .initFetchCategoriesWithScope(Constants.scopeHome);
    BlocProvider.of<FetcherCubit>(context).initFetchBanners();
    WidgetsBinding.instance.addPostFrameCallback((_) => LocalDataLayer()
        .getSavedAddress()
        .then((Address? sa) => setState(() => _address = sa)));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is CategoriesLoaded) {
          _categories = state.categories;
          _refreshVendors();
          setState(() {});
        }
        if (state is BannersLoaded) {
          _banners = state.banners;
          setState(() {});
        }
        if (state is VendorsLoaded) {
          if (state.vendors.data.isNotEmpty) {
            _typeVends[state.sortOrVendorType!] = state.vendors.data;
            setState(() {});
          }
        }
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kTextTabBarHeight + 20),
          child: SafeArea(
            child: ListTile(
              onTap: () => Navigator.pushNamed(
                context,
                PageRoutes.savedAddressPage,
                arguments: {"pick": true},
              ).then(
                (value) {
                  if (value is Address) {
                    LocalDataLayer().setSavedAddress(value).then((_) {
                      setState(() => _address = value);
                      _refreshVendors();
                    });
                  }
                },
              ),
              title: Row(
                children: [
                  Icon(Icons.home, color: theme.primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalization.instance
                        .getLocalizationFor(_address?.title ?? "address"),
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.keyboard_arrow_down, color: theme.dividerColor),
                ],
              ),
              subtitle: Text(
                _address?.formatted_address ??
                    AppLocalization.instance
                        .getLocalizationFor("select_address"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontSize: 12, color: theme.hintColor),
              ),
              trailing: GestureDetector(
                onTap: () => Navigator.pushNamed(context, PageRoutes.cartPage),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.primaryColor,
                      child: Icon(
                        Icons.shopping_basket,
                        color: theme.scaffoldBackgroundColor,
                      ),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: darken(theme.primaryColor, .2),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Center(
                          child: Text(
                            "${CartManager().cartItemsCount}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 16),
            // Padding(
            //   padding: horizontalPadding,
            //   child: Image.asset('assets/banner_home.png'),
            // ),
            if (_banners == null || _banners!.isEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider(
                    items: [
                      Shimmer.fromColors(
                        baseColor: gradientColor2,
                        highlightColor: gradientColor1,
                        child: Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                    options: CarouselOptions(
                        autoPlay: true,
                        height: 180,
                        viewportFraction: 1,
                        enlargeCenterPage: false,
                        onPageChanged: (index, reason) {}),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12.0,
                        height: 3.0,
                        margin: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          shape: BoxShape.rectangle,
                          color: Theme.of(context).secondaryHeaderColor,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            if (_banners != null && _banners!.isNotEmpty)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CarouselSlider(
                    items: [
                      for (Category category in _banners!)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedImage(
                              imageUrl: category.imageUrl,
                              imagePlaceholder: 'assets/banner_home.png',
                              fit: BoxFit.fill,
                            ),
                          ),
                        )
                    ],
                    options: CarouselOptions(
                        autoPlay: true,
                        viewportFraction: 0.9,
                        height: 180,
                        enlargeCenterPage: false,
                        onPageChanged: (index, reason) => setState(
                            () => _activeBannerId = _banners![index].id)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (Category category in _banners!)
                        Container(
                          width: 12.0,
                          height: 3.0,
                          margin: const EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle,
                            color: category.id == _activeBannerId
                                ? Theme.of(context).secondaryHeaderColor
                                : Theme.of(context)
                                    .secondaryHeaderColor
                                    .withValues(alpha: 0.5),
                          ),
                        ),
                    ],
                  )
                ],
              ),
            const SizedBox(height: 20),
            Padding(
              padding: horizontalPadding,
              child: Text(
                AppLocalization.instance
                    .getLocalizationFor("whatAreYouLookingFor"),
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),
            if (_categories != null && _categories!.length < 8)
              _buildDynamicGrid(_categories!.length)
            else if (_categories != null)
              GridView.builder(
                padding: horizontalPadding,
                itemCount: _categories!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () => _onTapCategory(
                    _categories![index],
                  ),
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedImage(
                            imageUrl: _categories![index].imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          _categories![index].title,
                          style: theme.textTheme.bodyLarge!.copyWith(
                              fontSize: 10,
                              color: blackColor,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 22),
            for (String type in _typeVends.keys)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: horizontalPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${type.capitalizeFirst()} ${AppLocalization.instance.getLocalizationFor("nearMe")}",
                          style: theme.textTheme.headlineSmall!.copyWith(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            PageRoutes.vendorsPage,
                            arguments: type,
                          ),
                          child: Text(
                            AppLocalization.instance
                                .getLocalizationFor("seeAll"),
                            style: theme.textTheme.headlineSmall!.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).primaryColor),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    width: size.width,
                    child: ListView.separated(
                      padding: horizontalPadding,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: _typeVends[type]!.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 16),
                      itemBuilder: (context, index) => SizedBox(
                        width: size.width * 0.80,
                        child: ListItemVendor(
                          vendor: _typeVends[type]![index],
                          theme: theme,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _refreshVendors() {
    String catsComaSepAvail = _categories!
        .map((e) {
          List<String> esplits = e.slug?.split("-") ?? [];
          if (esplits.length == 2) {
            return esplits[1];
          } else {
            return null;
          }
        })
        .toList()
        .join(".");
    List<String> vts =
        AppSettings.vendorType.split(",").map((e) => e.trim()).toList();
    vts.removeWhere(
        (element) => element.isEmpty || !catsComaSepAvail.contains(element));
    BlocProvider.of<FetcherCubit>(context).initCancelFetchVendors();
    for (String vt in vts) {
      BlocProvider.of<FetcherCubit>(context).initFetchVendors(
        pageNum: 1,
        perPage: 5,
        vendorType: vt,
      );
    }
  }

  void _onTapCategory(my_category.Category category) {
    if (category.slug == "home-cab") {
      // Navigator.pushNamed(
      //   context,
      //   PageRoutes.selectSrcDstPage,
      //   arguments: {"type": "ride"},
      // );
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
        builder: (context) => const RideTypeSelectionSheet(),
      ).then((value) {
        if (value != null && value is Map && mounted) {
          Navigator.pushNamed(
            context,
            PageRoutes.selectSrcDstPage,
            arguments: value,
          );
        }
      });
    } else if (category.slug == "home-ride") {
      Navigator.pushNamed(
        context,
        PageRoutes.selectSrcDstPage,
        //arguments: {"type": "intercity"},
      );
    } else if (category.slug == "home-parcel") {
      Navigator.pushNamed(
        context,
        PageRoutes.selectSrcDstPage,
        arguments: {"type": "courier"},
      );
    } else if (category.slug == "home-service") {
      Navigator.pushNamed(
        context,
        PageRoutes.selectServicesPage,
        arguments: category,
      );
    } else {
      if (category.vendorType != null) {
        Navigator.pushNamed(
          context,
          PageRoutes.subCategoriesPage,
          arguments: category,
        );
      } else {
        Toaster.showToastBottom(
            AppLocalization.instance.getLocalizationFor("invalid_category"));
      }
    }
  }

  Widget _buildDynamicGrid(int itemCount) => Padding(
        padding: horizontalPadding,
        child: Column(
          children: _buildCustomRows(itemCount),
        ),
      );

  List<Widget> _buildCustomRows(int itemCount) {
    List<Widget> rows = [];

    switch (itemCount) {
      case 1:
        rows.add(_buildRow([0], 240, useBanner: true));
        break;
      case 2:
        rows.add(_buildRow([0, 1], 160, useBanner: true));
        break;
      case 3:
        rows.add(_buildRow([0, 1, 2], 160));
        break;
      case 4:
        rows.add(_buildRow([0, 1], 130, useBanner: true));
        rows.add(const SizedBox(height: 12));
        rows.add(_buildRow([2, 3], 130, useBanner: true));
        break;
      case 5:
        rows.add(_buildRow([0, 1], 130, useBanner: true));
        rows.add(const SizedBox(height: 12));
        rows.add(_buildRow([2, 3, 4], 130));
        break;
      case 6:
        rows.add(_buildRow([0, 1, 2], 130));
        rows.add(const SizedBox(height: 12));
        rows.add(_buildRow([3, 4, 5], 130));
        break;
      case 7:
        rows.add(_buildRow([0, 1, 2, 3], 130));
        rows.add(const SizedBox(height: 12));
        rows.add(_buildRow([4, 5, 6], 130));
        break;
    }

    return rows;
  }

  Widget _buildRow(List<int> indices, double height,
          {bool useBanner = false}) =>
      SizedBox(
        height: height,
        child: Row(
          children: List.generate(indices.length * 2 - 1, (i) {
            if (i.isEven) {
              // Item index
              final itemIndex = i ~/ 2;
              final categoryIndex = indices[itemIndex];
              return Flexible(
                flex: 1,
                child: _buildGridItem(categoryIndex, useBanner),
              );
            } else {
              // Spacing
              return const SizedBox(width: 12);
            }
          }),
        ),
      );

  Widget _buildGridItem(int index, bool useBanner) {
    final category = _categories![index];
    final imageUrl = useBanner ? category.imageBannerUrl : category.imageUrl;

    return GestureDetector(
      onTap: () => _onTapCategory(category),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          //const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              category.title,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          //const SizedBox(height: 4),
        ],
      ),
    );
  }
}
