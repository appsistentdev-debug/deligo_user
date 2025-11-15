import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/order.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'list_item_order.dart';

class OrdersTabDelivery extends StatelessWidget {
  final GlobalKey<OrdersTabDeliveryStatefulState> innerKey;
  final String? vendorType;
  const OrdersTabDelivery({super.key, required this.innerKey, this.vendorType});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: OrdersTabDeliveryStateful(
          key: innerKey,
          vendorType: vendorType,
        ),
      );
}

class OrdersTabDeliveryStateful extends StatefulWidget {
  final String? vendorType;
  const OrdersTabDeliveryStateful({super.key, this.vendorType});

  @override
  State<OrdersTabDeliveryStateful> createState() =>
      OrdersTabDeliveryStatefulState();
}

class OrdersTabDeliveryStatefulState extends State<OrdersTabDeliveryStateful>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final List<Order> _list = [];
  int _pageNo = 1;
  bool _isLoading = true;
  bool _allDone = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetcherCubit>(context).initFetchOrders(
      1,
      vendorType: widget.vendorType,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is OrdersLoaded) {
          _pageNo = state.orders.meta.current_page ?? 1;
          _allDone =
              state.orders.meta.current_page == state.orders.meta.last_page;
          if (state.orders.meta.current_page == 1) {
            _list.clear();
          }
          _list.addAll(state.orders.data);
          _isLoading = false;
          setState(() {});
        }
        if (state is OrdersFail) {
          _isLoading = false;
          setState(() {});
        }
      },
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: theme.primaryColor,
        onRefresh: () => BlocProvider.of<FetcherCubit>(context).initFetchOrders(
          1,
          vendorType: widget.vendorType,
        ),
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
                    BlocProvider.of<FetcherCubit>(context).initFetchOrders(
                      _pageNo + 1,
                      vendorType: widget.vendorType,
                    );
                  }
                  return ListItemOrder(
                    order: _list[index],
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
                              .getLocalizationFor("no_orders"),
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
