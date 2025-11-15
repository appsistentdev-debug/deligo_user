import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/ride.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'list_item_ride.dart';

class OrdersTabRide extends StatelessWidget {
  final GlobalKey<OrdersTabRideStatefulState> innerKey;
  const OrdersTabRide({
    super.key,
    required this.innerKey,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: OrdersTabRideStateful(
          key: innerKey,
        ),
      );
}

class OrdersTabRideStateful extends StatefulWidget {
  const OrdersTabRideStateful({super.key});

  @override
  State<OrdersTabRideStateful> createState() => OrdersTabRideStatefulState();
}

class OrdersTabRideStatefulState extends State<OrdersTabRideStateful>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final List<Ride> _list = [];
  int _pageNo = 1;
  bool _isLoading = true;
  bool _allDone = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetcherCubit>(context).initFetchRides(1);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is RidesLoaded) {
          _pageNo = state.rides.meta.current_page ?? 1;
          _allDone =
              state.rides.meta.current_page == state.rides.meta.last_page;
          if (state.rides.meta.current_page == 1) {
            _list.clear();
          }
          _list.addAll(state.rides.data);
          _isLoading = false;
          setState(() {});
        }
        if (state is RidesFail) {
          _isLoading = false;
          setState(() {});
        }
      },
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: theme.primaryColor,
        onRefresh: () =>
            BlocProvider.of<FetcherCubit>(context).initFetchRides(1),
        child: _list.isNotEmpty
            ? ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _list.length,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  if ((index == _list.length - 1) && !_isLoading && !_allDone) {
                    _isLoading = true;
                    BlocProvider.of<FetcherCubit>(context)
                        .initFetchRides(_pageNo + 1);
                  }
                  return ListItemRide(
                    ride: _list[index],
                    theme: theme,
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
                            vertical: MediaQuery.of(context).size.width * 0.5),
                        child: ErrorFinalWidget.errorWithRetry(
                          context: context,
                          message: AppLocalization.instance
                              .getLocalizationFor("no_rides"),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Future<void>? refresh() {
    if (_isLoading) {
      return null;
    }
    return _refreshIndicatorKey.currentState?.show();
  }
}
