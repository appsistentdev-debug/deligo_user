import 'dart:convert';

import 'package:deligo/widgets/portfolio_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/bloc/payment_cubit.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/address.dart';
import 'package:deligo/models/review.dart';
import 'package:deligo/models/service_provider.dart';
import 'package:deligo/models/service_provider_category.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_divider.dart';
import 'package:deligo/widgets/custom_shadow.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/toaster.dart';

import 'date_time_picker_sheet.dart';
import 'list_item_service_provider_review.dart';

class ServiceProviderPage extends StatelessWidget {
  const ServiceProviderPage({super.key});

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    return BlocProvider(
      create: (context) => FetcherCubit(),
      child: ServiceProviderStateful(
        service_provider: args as ServiceProvider,
      ),
    );
  }
}

class ServiceProviderStateful extends StatefulWidget {
  final ServiceProvider service_provider;
  const ServiceProviderStateful({
    super.key,
    required this.service_provider,
  });

  @override
  State<ServiceProviderStateful> createState() =>
      _ServiceProviderStatefulState();
}

class _ServiceProviderStatefulState extends State<ServiceProviderStateful> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is AppointmentCreateLoading) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }
        if (state is AppointmentCreateLoaded) {
          Toaster.showToastBottom(getLocalizationFor("appointment_created"));

          Navigator.pushNamed(
            context,
            PageRoutes.processPaymentPage,
            arguments: state.paymentData,
          ).then((value) async {
            bool paid = value != null && value is PaymentStatus && value.isPaid;
            Toaster.showToastCenter(AppLocalization.instance.getLocalizationFor(
                paid ? "payment_success_message" : "payment_fail_message"));
            if (paid) {
              await LocalDataLayer().setTabUpdate(1, "refresh_appointments");
              Navigator.popUntil(context, (route) => route.isFirst);
            } else {
              Navigator.popUntil(context, (route) => route.isFirst);
            }
          });
        }
        if (state is AppointmentCreateFail) {
          Toaster.showToastCenter(getLocalizationFor(state.messageKey));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(Icons.arrow_back_ios_new),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.service_provider.name ?? "",
                            style: theme.textTheme.titleMedium!.copyWith(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.service_provider.address ?? "",
                            style: theme.textTheme.bodySmall!
                                .copyWith(color: theme.hintColor),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(8),
                      child: CachedImage(
                        imageUrl: widget.service_provider.imageUrl,
                        height: 100,
                        width: 100,
                      ),
                    ),
                  ],
                ),
              ),
              const CustomDivider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "${widget.service_provider.ratings_count} ${AppLocalization.instance.getLocalizationFor("ratings")}",
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Colors.green.shade700,
                              size: 28,
                            ),
                            const SizedBox(width: 4),
                            Text(widget.service_provider.ratingsString,
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center)
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalization.instance
                              .getLocalizationFor("job_done"),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Colors.grey),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.work,
                              color: Colors.green.shade700,
                              size: 28,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.service_provider.subcategories.length}",
                              style: Theme.of(context).textTheme.titleMedium,
                            )
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const CustomDivider(),
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TabBar(
                              tabs: [
                                Tab(
                                    text: AppLocalization.instance
                                        .getLocalizationFor("services")),
                                Tab(
                                    text: AppLocalization.instance
                                        .getLocalizationFor("portfolio")),
                                Tab(
                                    text: AppLocalization.instance
                                        .getLocalizationFor("reviews")),
                              ],
                              indicatorColor: theme.primaryColor,
                              labelColor: theme.primaryColor,
                              labelStyle: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              unselectedLabelStyle: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      CustomShadow(height: 16),
                      Expanded(
                        child: ColoredBox(
                          color: Colors.white,
                          child: TabBarView(
                            children: [
                              ServiceProviderServices(
                                  widget.service_provider.id,
                                  widget.service_provider.subcategories),
                              ServiceProviderPortfolio(
                                  widget.service_provider.portfolios ?? []),
                              ServiceProviderReviews(
                                  widget.service_provider.id),
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
}

class ServiceProviderReviews extends StatefulWidget {
  final int providerId;
  const ServiceProviderReviews(this.providerId, {super.key});

  @override
  State<ServiceProviderReviews> createState() => _ServiceProviderReviewsState();
}

class _ServiceProviderReviewsState extends State<ServiceProviderReviews>
    with AutomaticKeepAliveClientMixin {
  final List<Review> _list = [];
  int _pageNo = 1;
  bool _isLoading = true;
  bool _allDone = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetcherCubit>(context)
        .initFetchServiceProviderReviews(widget.providerId, 1);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is ServiceProviderReviewsLoaded) {
          _pageNo = state.reviews.meta.current_page ?? 1;
          _allDone =
              state.reviews.meta.current_page == state.reviews.meta.last_page;
          if (state.reviews.meta.current_page == 1) {
            _list.clear();
          }
          _list.addAll(state.reviews.data);
          _isLoading = false;
          setState(() {});
        }
        if (state is ServiceProviderReviewsFail) {
          _isLoading = false;
          setState(() {});
        }
      },
      child: RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: () => BlocProvider.of<FetcherCubit>(context)
            .initFetchServiceProviderReviews(widget.providerId, 1),
        child: _list.isNotEmpty
            ? Container(
                color: theme.scaffoldBackgroundColor,
                child: ListView.separated(
                  //padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: _list.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  separatorBuilder: (context, index) => CustomDivider(),
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    top: 8,
                  ),
                  itemBuilder: (context, index) {
                    if ((index == _list.length - 1) &&
                        !_isLoading &&
                        !_allDone) {
                      _isLoading = true;
                      BlocProvider.of<FetcherCubit>(context)
                          .initFetchServiceProviderReviews(
                        widget.providerId,
                        _pageNo + 1,
                      );
                    }
                    return ListItemServiceProviderReview(
                      review: _list[index],
                      theme: theme,
                    );
                  },
                ),
              )
            : _isLoading
                ? Loader.circularProgressIndicatorPrimary(context)
                : Container(
                    color: theme.scaffoldBackgroundColor,
                    child: ListView(
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
                                .getLocalizationFor("empty_reviews"),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class ServiceProviderPortfolio extends StatelessWidget {
  final List<String> portfolios;
  const ServiceProviderPortfolio(this.portfolios, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: ListView(
          children: [
            if (portfolios.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 64,
                    vertical: MediaQuery.of(context).size.width * 0.5),
                child: ErrorFinalWidget.errorWithRetry(
                  context: context,
                  message: AppLocalization.instance
                      .getLocalizationFor("empty_portfolios"),
                ),
              )
            else
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    for (var i = 0; i < portfolios.length; i++)
                      StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: (i % 3 == 0) ? 1.5 : 1.2,
                        child: PortfolioItem(imageUrl: portfolios[i]),
                      ),
                  ],
                ),
              ),
          ],
        ),
      );
}

class ServiceProviderServices extends StatefulWidget {
  final int providerId;
  final List<ServiceProviderCategory> services;
  const ServiceProviderServices(this.providerId, this.services, {super.key});

  @override
  State<ServiceProviderServices> createState() =>
      _ServiceProviderServicesState();
}

class _ServiceProviderServicesState extends State<ServiceProviderServices>
    with AutomaticKeepAliveClientMixin {
  final List<ServiceProviderCategory> servicesSelected = [];
  DateTime? dateSelected;
  TimeOfDay? timeSelected;

  @override
  bool get wantKeepAlive => true;

  double get _total {
    double toReturn = 0;
    for (ServiceProviderCategory spc in servicesSelected) {
      toReturn += spc.fee;
    }
    return toReturn;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: widget.services.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              if (servicesSelected.contains(widget.services[index])) {
                servicesSelected.remove(widget.services[index]);
              } else {
                servicesSelected.add(widget.services[index]);
              }
              setState(() {});
            },
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.cardColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  leading: Icon(
                    servicesSelected.contains(widget.services[index])
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    color: theme.primaryColor,
                  ),
                  title: Text(
                    widget.services[index].category.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: Text(
                    "${AppSettings.currencyIcon} ${widget.services[index].fee}",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: servicesSelected.contains(widget.services[index])
                          ? theme.primaryColor
                          : Colors.grey.shade400,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ),
        ),
      ),
      bottomNavigationBar: servicesSelected.isNotEmpty
          ? CustomButton(
              margin: EdgeInsets.all(16),
              onTap: () async {
                //selected services check
                if (servicesSelected.isEmpty) {
                  Toaster.showToastCenter(AppLocalization.instance
                      .getLocalizationFor("select_services"));
                  return;
                }

                //address check
                Address? sa = await LocalDataLayer().getSavedAddress();
                if (sa == null) {
                  dynamic nsa = await Navigator.pushNamed(
                    context,
                    PageRoutes.savedAddressPage,
                    arguments: {"pick": true},
                  );
                  if (nsa is Address) {
                    sa = nsa;
                  }
                }
                if (sa == null) return;

                //datetime check
                Map? dtMap = await showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) => DateTimePickerSheet(
                    title: AppLocalization.instance
                        .getLocalizationFor("desiredDateTime"),
                    date: dateSelected,
                    time: timeSelected,
                  ),
                );
                if (dtMap != null) {
                  dateSelected = dtMap["date"];
                  timeSelected = dtMap["time"];
                  DateTime dateTime = DateTime(
                      dateSelected!.year,
                      dateSelected!.month,
                      dateSelected!.day,
                      timeSelected!.hour,
                      timeSelected!.minute);
                  if (!dateTime.isAfter(DateTime.now())) {
                    Toaster.showToastCenter(
                        getLocalizationFor("date_time_passed"));
                    return;
                  }

                  //appointment request
                  Map<String, dynamic> apr = {};
                  apr["amount"] = _total;
                  apr["payment_method_slug"] = "cod";
                  apr["address"] = sa.formatted_address;
                  apr["latitude"] = sa.latitude;
                  apr["longitude"] = sa.longitude;
                  apr["date"] = DateFormat("yyyy-MM-dd").format(dateTime);
                  apr["time_from"] = DateFormat("HH:mm").format(dateTime);
                  apr["time_to"] = DateFormat("HH:mm")
                      .format(dateTime.add(const Duration(minutes: 30)));

                  Map<String, dynamic> aprMeta = {};
                  aprMeta["categories"] =
                      servicesSelected.map((e) => e.category).toList();
                  // if (_noteController.text.trim().isNotEmpty) {
                  //   aprMeta["notes"] = _noteController.text.trim();
                  // }
                  apr["meta"] = jsonEncode(aprMeta);
                  BlocProvider.of<FetcherCubit>(context)
                      .initCreateAppointment(widget.providerId, apr);
                }
              },
            )
          : null,
    );
  }
}
