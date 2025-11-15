import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/appointment.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';

import 'list_item_appointment.dart';

class OrdersTabAppointment extends StatelessWidget {
  final GlobalKey<OrdersTabAppointmentStatefulState> innerKey;
  const OrdersTabAppointment({
    super.key,
    required this.innerKey,
  });

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: OrdersTabAppointmentStateful(
          key: innerKey,
        ),
      );
}

class OrdersTabAppointmentStateful extends StatefulWidget {
  const OrdersTabAppointmentStateful({super.key});

  @override
  State<OrdersTabAppointmentStateful> createState() =>
      OrdersTabAppointmentStatefulState();
}

class OrdersTabAppointmentStatefulState
    extends State<OrdersTabAppointmentStateful>
    with AutomaticKeepAliveClientMixin {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final List<Appointment> _list = [];
  int _pageNo = 1;
  bool _isLoading = true;
  bool _allDone = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FetcherCubit>(context).initFetchAppointments(1, null);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is AppointmentsLoaded) {
          _pageNo = state.appointments.meta.current_page ?? 1;
          _allDone = state.appointments.meta.current_page ==
              state.appointments.meta.last_page;
          if (state.appointments.meta.current_page == 1) {
            _list.clear();
          }
          _list.addAll(state.appointments.data);
          _isLoading = false;
          setState(() {});
        }
        if (state is AppointmentsFail) {
          _isLoading = false;
          setState(() {});
        }
        if (state is AppointmentUpdateLoaded) {
          int eIndex = _list.indexOf(state.appointment);
          if (eIndex > 0) {
            _list[eIndex] = state.appointment;
            setState(() {});
          }
        }
      },
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        color: theme.primaryColor,
        onRefresh: () => BlocProvider.of<FetcherCubit>(context)
            .initFetchAppointments(1, null),
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
                        .initFetchAppointments(_pageNo + 1, null);
                  }
                  return ListItemAppointment(
                    appointment: _list[index],
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
                              .getLocalizationFor("empty_appointments"),
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
