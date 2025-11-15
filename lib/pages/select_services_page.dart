import 'package:deligo/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/models/service_provider.dart';
import 'package:deligo/pages/list_item_service_provider.dart';
import 'package:deligo/utility/constants.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/widget_size.dart';

class SelectServicesPage extends StatelessWidget {
  const SelectServicesPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: SelectServicesStateful(
            ModalRoute.of(context)!.settings.arguments as Category),
      );
}

class SelectServicesStateful extends StatefulWidget {
  final Category category;
  const SelectServicesStateful(this.category, {super.key});

  @override
  State<SelectServicesStateful> createState() => _SelectServicesStatefulState();
}

class _SelectServicesStatefulState extends State<SelectServicesStateful> {
  Size? _headerSize;
  final List<ServiceProvider> _list = [];
  int _pageNo = 1;
  bool _isLoading = true;
  bool _allDone = false;
  List<Category> _listCategories = [];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetcherCubit>(context).initFetchCategories(
      scope: Constants.scopeServices,
      parent: 1,
    );
    BlocProvider.of<FetcherCubit>(context).initFetchServiceProviders(pageNo: 1);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is CategoriesLoaded) {
          _listCategories = state.categories;
          if (_list.firstOrNull != ServiceProvider.placeholder) {
            _list.insert(0, ServiceProvider.placeholder);
          }
          setState(() {});
        }
        if (state is ServiceProvidersLoaded) {
          _pageNo = state.serviceProviders.meta.current_page ?? 1;
          _allDone = state.serviceProviders.meta.current_page ==
              state.serviceProviders.meta.last_page;
          if (state.serviceProviders.meta.current_page == 1) {
            _list.clear();
          }
          _list.addAll(state.serviceProviders.data);
          if (_list.firstOrNull != ServiceProvider.placeholder) {
            _list.insert(0, ServiceProvider.placeholder);
          }
          _isLoading = false;
          setState(() {});
        }
        if (state is ServiceProvidersFail) {
          if (_list.firstOrNull != ServiceProvider.placeholder) {
            _list.insert(0, ServiceProvider.placeholder);
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
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                    ),
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
                      hintText:
                          AppLocalization.instance.getLocalizationFor("search"),
                      prefixIcon: Icon(Icons.search,
                          color: theme.primaryColorDark, size: 24),
                      readOnly: true,
                      onTap: () => Navigator.pushNamed(
                          context, PageRoutes.serviceProvidersPage),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: RefreshIndicator(
                        color: Theme.of(context).primaryColor,
                        onRefresh: () => BlocProvider.of<FetcherCubit>(context)
                            .initFetchServiceProviders(
                          pageNo: 1,
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
                                        .initFetchServiceProviders(
                                      pageNo: _pageNo + 1,
                                    );
                                  }
                                  // int index =
                                  //     i < _list.length ? i : _list.length - 1;
                                  return _list[index] ==
                                          ServiceProvider.placeholder
                                      ? _categoriesWidget()
                                      : ListItemServiceProvider(
                                          service_provider: _list[index],
                                          theme: theme,
                                        );
                                },
                              )
                            : _isLoading
                                ? Loader.circularProgressIndicatorPrimary(
                                    context)
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
                                                  "no_service_providers_found"),
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

  Widget _categoriesWidget() {
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
              onTap: () => Navigator.pushNamed(
                context,
                PageRoutes.serviceProvidersPage,
                arguments: _listCategories[index],
              ),
              child: GridTile(
                footer: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Center(
                      child: Text(
                    _listCategories[index].title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: blackColor,
                        ),
                  )),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
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
              AppLocalization.instance.getLocalizationFor("providersNearMe"),
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
