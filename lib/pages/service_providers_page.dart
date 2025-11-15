import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/models/service_provider.dart';
import 'package:deligo/pages/list_item_service_provider.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';

class ServiceProvidersPage extends StatelessWidget {
  const ServiceProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    return BlocProvider(
      create: (context) => FetcherCubit(),
      child: ServiceProvidersStateful(
        category: args is Category ? args : null,
      ),
    );
  }
}

class ServiceProvidersStateful extends StatefulWidget {
  final Category? category;
  const ServiceProvidersStateful({
    super.key,
    this.category,
  });

  @override
  State<ServiceProvidersStateful> createState() =>
      _ServiceProvidersStatefulState();
}

class _ServiceProvidersStatefulState extends State<ServiceProvidersStateful> {
  //final TextEditingController _controller = TextEditingController();
  //final FocusNode _focusNode = FocusNode();
  final List<ServiceProvider> _list = [];
  int _pageNo = 1;
  bool _isLoading = true;
  bool _allDone = false;
  //Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (widget.category?.id != null) {
      BlocProvider.of<FetcherCubit>(context).initFetchServiceProviders(
        pageNo: 1,
        categoryId: widget.category?.id,
      );
    } else {
      _isLoading = false;
    }
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (widget.category?.id == null) {
    //     _focusNode.requestFocus();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is ServiceProvidersLoaded) {
          _pageNo = state.serviceProviders.meta.current_page ?? 1;
          _allDone = state.serviceProviders.meta.current_page ==
              state.serviceProviders.meta.last_page;
          if (state.serviceProviders.meta.current_page == 1) {
            _list.clear();
          }
          _list.addAll(state.serviceProviders.data);
          _isLoading = false;
          setState(() {});
        }
        if (state is ServiceProvidersFail) {
          _isLoading = false;
          setState(() {});
        }
      },
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
                        widget.category?.title ??
                            AppLocalization.instance
                                .getLocalizationFor("service_providers"),
                        style: theme.textTheme.headlineSmall!
                            .copyWith(fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
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
                      // CustomTextField(
                      //   bgColor: theme.scaffoldBackgroundColor,
                      //   hintText: AppLocalization.instance
                      //       .getLocalizationFor("search"),
                      //   prefixIcon: Icon(
                      //     Icons.search,
                      //     color: theme.primaryColorDark,
                      //     size: 24,
                      //   ),
                      //   suffixIcon: _controller.text.trim().isNotBlank
                      //       ? IconButton(
                      //           onPressed: () => _clearSearch(),
                      //           icon: Icon(
                      //             Icons.close,
                      //             color: theme.primaryColorDark,
                      //             size: 24,
                      //           ),
                      //         )
                      //       : null,
                      //   focusNode: _focusNode,
                      //   onChanged: _onSearchChanged,
                      //   controller: _controller,
                      // ),
                      // if (_list.isNotEmpty &&
                      //     (_list.first.id > 0 ||
                      //         (_list.length > 1 && _list[1].id > 0)))
                      //   Align(
                      //     alignment: Alignment.centerLeft,
                      //     child: Padding(
                      //       padding: const EdgeInsets.only(top: 16),
                      //       child: Text(
                      //         "${AppLocalization.instance.getLocalizationFor("service_providers")} ${AppLocalization.instance.getLocalizationFor("nearMe")}",
                      //         textAlign: TextAlign.start,
                      //         style: theme.textTheme.titleLarge!.copyWith(
                      //             fontSize: 18, fontWeight: FontWeight.bold),
                      //       ),
                      //     ),
                      //   ),
                      Expanded(
                        child: RefreshIndicator(
                          color: theme.primaryColor,
                          onRefresh: () async {
                            if (widget.category?.id != null

                                // || widget.vendorType != null ||
                                // _controller.text.trim().isNotEmpty
                                ) {
                              await BlocProvider.of<FetcherCubit>(context)
                                  .initFetchServiceProviders(
                                pageNo: 1,
                                categoryId: widget.category?.id,
                              );
                            }
                          },
                          child: _list.isNotEmpty
                              ? ListView.separated(
                                  padding: const EdgeInsets.only(top: 32),
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
                                          .initFetchServiceProviders(
                                        pageNo: _pageNo + 1,
                                        categoryId: widget.category?.id,
                                      );
                                    }
                                    return ListItemServiceProvider(
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
                                          child:
                                              ErrorFinalWidget.errorWithRetry(
                                            context: context,
                                            message: AppLocalization.instance
                                                .getLocalizationFor(
                                                    "no_service_providers_found"),
                                            // message: AppLocalization.instance
                                            //     .getLocalizationFor(_controller
                                            //             .text
                                            //             .trim()
                                            //             .isNotEmpty
                                            //         ? "no_vendors_found"
                                            //         : "search_empty_hint"),
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
    // _focusNode.dispose();
    // _debounce?.cancel();
    // _controller.dispose();
    super.dispose();
  }

  // void _onSearchChanged(String query) {
  //   if (_debounce?.isActive ?? false) _debounce!.cancel();

  //   _debounce = Timer(const Duration(seconds: 2), () {
  //     Helper.clearFocus(context);
  //     if (query.trim().length >= 3 || query.trim().isEmpty) {
  //       if (query.trim().isEmpty) {
  //         _clearSearch();
  //       } else {
  //         _isLoading = true;
  //         _allDone = false;
  //         _list.clear();
  //         setState(() {});
  //         BlocProvider.of<FetcherCubit>(context).initFetchServiceProviders(
  //           pageNo: 1,
  //           categoryId: widget.category?.id,
  //           query: query.trim(),
  //         );
  //       }
  //     }
  //   });
  // }

  // void _clearSearch() {
  //   _list.clear();
  //   _pageNo = 1;
  //   _isLoading = false;
  //   _allDone = false;
  //   _controller.clear();
  //   if (widget.category?.id != null) {
  //     _isLoading = true;
  //     BlocProvider.of<FetcherCubit>(context).initFetchServiceProviders(
  //       pageNo: 1,
  //       categoryId: widget.category?.id,
  //     );
  //   }
  //   setState(() {});
  // }
}
