import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/assets.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/appointment.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/models/chat.dart';
import 'package:deligo/utility/constants.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/string_extensions.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_divider.dart';

class AppointmentInfoPage extends StatelessWidget {
  const AppointmentInfoPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: AppointmentInfoStateful(
            ModalRoute.of(context)!.settings.arguments as Appointment),
      );
}

class AppointmentInfoStateful extends StatefulWidget {
  final Appointment appointment;
  const AppointmentInfoStateful(this.appointment, {super.key});

  @override
  State<AppointmentInfoStateful> createState() =>
      _AppointmentInfoStatefulState();
}

class _AppointmentInfoStatefulState extends State<AppointmentInfoStateful> {
  late FetcherCubit _fetcherCubit;
  late Appointment _ap;
  bool _hasRated = false;

  @override
  void initState() {
    _ap = widget.appointment;
    _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
    super.initState();
    if (!_ap.isPast) {
      _fetcherCubit.initRegisterAppointmentUpdates(_ap.id);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ap.status == "complete") {
        LocalDataLayer()
            .getAppointmentIdRated(_ap.id)
            .then((value) => setState(() => _hasRated = value));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) async {
        if (state is AppointmentUpdateLoading) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }
        if (state is AppointmentUpdateLoaded) {
          _ap = state.appointment;
          if (_ap.status == "complete") {
            _hasRated = await LocalDataLayer().getAppointmentIdRated(_ap.id);
          }
          setState(() {});
          if (_ap.isPast) {
            _fetcherCubit.initUnRegisterAppointmentUpdates();
          }
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
              width: double.infinity,
              height: 400,
            ),
            SafeArea(
                child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 4, bottom: 0),
                  // height: MediaQuery.of(context).size.height * 0.15,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                            ),
                          ),
                          if (_ap.status == "complete" && !_hasRated)
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                PageRoutes.rateAppointmentPage,
                                arguments: _ap,
                              ).then((value) => LocalDataLayer()
                                  .getAppointmentIdRated(_ap.id)
                                  .then((value) =>
                                      setState(() => _hasRated = value))),
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: theme.scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(6),
                                margin: EdgeInsetsDirectional.only(end: 16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star),
                                    const SizedBox(width: 2),
                                    Text(AppLocalization.instance
                                        .getLocalizationFor(
                                            "rate_appointment")),
                                  ],
                                ),
                              ),
                            )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            Assets.assetsProvider,
                            height: 60,
                            width: 60,
                          ),
                          Text.rich(
                            TextSpan(
                              text: AppLocalization.instance
                                  .getLocalizationFor("appointment_status"),
                              children: [
                                TextSpan(
                                  text:
                                      " ${AppLocalization.instance.getLocalizationFor("appointment_status_${_ap.status}")}.",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.scaffoldBackgroundColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.scaffoldBackgroundColor),
                          ),
                          const SizedBox(
                            width: 60,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: theme.disabledColor,
                    child: ListView(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: theme.scaffoldBackgroundColor,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                        BorderRadiusGeometry.circular(8),
                                    child: CachedImage(
                                      imageUrl: _ap.provider?.imageUrl,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.2,
                                      width: MediaQuery.of(context).size.width *
                                          0.2,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -8,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 4.0,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF009D06),
                                          borderRadius:
                                              BorderRadius.circular(16.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const Icon(Icons.star,
                                                color: Colors.white,
                                                size: 16.0),
                                            const SizedBox(width: 4.0),
                                            Text(
                                              _ap.provider?.ratingsString ?? "",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14.0,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _ap.address ?? "",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.hintColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _ap.provider?.categoriesParentString ??
                                          "",
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _ap.provider?.name ?? "",
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () => Helper.launchURL(
                                        "tel:${_ap.provider?.user?.mobile_number}"),
                                    child: CircleAvatar(
                                      backgroundColor: theme.cardColor,
                                      child: Icon(
                                        Icons.call,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      PageRoutes.messagePage,
                                      arguments: {
                                        "chat": Chat(
                                          myId:
                                              "${_ap.user?.id}${Constants.roleUser}",
                                          chatId:
                                              "${_ap.provider?.user?.id}${Constants.roleProvider}",
                                          chatImage: widget
                                              .appointment.provider?.imageUrl,
                                          chatName: _ap.provider?.name,
                                          chatStatus: _ap.categoryText ?? "",
                                        ),
                                        "subtitle":
                                            "${AppLocalization.instance.getLocalizationFor("serviceid").capitalizeFirst()} #${_ap.id}",
                                      },
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: theme.cardColor,
                                      child: Icon(
                                        Icons.message_rounded,
                                        color: theme.primaryColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_ap.categories?.isNotEmpty ?? false)
                          Container(
                            padding: const EdgeInsets.all(20.0),
                            color: theme.scaffoldBackgroundColor,
                            child: Column(
                              children: [
                                for (Category c in _ap.categories ?? [])
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              c.title,
                                              style: theme.textTheme.bodyMedium!
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight.w500),
                                            ),
                                          ),
                                          Text(
                                            "${AppSettings.currencyIcon} ${Helper.formatNumber(_ap.provider?.feeFor(c) ?? 0)}",
                                            style: theme.textTheme.bodyMedium,
                                          )
                                        ],
                                      ),
                                      const CustomDivider(),
                                    ],
                                  ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        AppLocalization.instance
                                            .getLocalizationFor("total"),
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      _ap.amountFormatted ?? "0",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                        Container(
                          color: theme.scaffoldBackgroundColor,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalization.instance
                                        .getLocalizationFor("bookedFor"),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  Text(
                                    _ap.scheduled_at_formatted ?? "",
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // const CustomDivider(),
                              // Row(
                              //   children: [
                              //     Text(locale.estimateCost,
                              //         style: theme.textTheme.bodyMedium),
                              //     const Spacer(),
                              //     Text(r"$5.00",
                              //         style: theme.textTheme.bodyMedium),
                              //     Text("/hr",
                              //         style: theme.textTheme.labelSmall
                              //             ?.copyWith(color: theme.hintColor)),
                              //   ],
                              // ),
                              // const SizedBox(height: 8),
                              const CustomDivider(),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                horizontalTitleGap: 8,
                                minVerticalPadding: 0,
                                leading: Image.asset(
                                  Assets.pinsIcLocation,
                                  height: 30,
                                ),
                                title: Text(
                                  AppLocalization.instance
                                      .getLocalizationFor("serviceAddress"),
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(color: theme.hintColor),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _ap.address ?? "",
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          color: theme.scaffoldBackgroundColor,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalization.instance
                                        .getLocalizationFor("serviceid"),
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _ap.id.toString(),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalization.instance
                                        .getLocalizationFor("bookedOn"),
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _ap.created_at_formatted ?? "",
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_ap.status == "pending")
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 80,
                              vertical: 40,
                            ),
                            child: CustomButton(
                              onTap: () => ConfirmDialog.showConfirmation(
                                      context,
                                      Text(AppLocalization.instance
                                          .getLocalizationFor(
                                              "cancel_ap_title")),
                                      Text(AppLocalization.instance
                                          .getLocalizationFor(
                                              "cancel_ap_message")),
                                      AppLocalization.instance
                                          .getLocalizationFor("no"),
                                      AppLocalization.instance
                                          .getLocalizationFor("yes"))
                                  .then((value) {
                                if (value != null && value == true) {
                                  _fetcherCubit.initUpdateAppointment(
                                      _ap.id, {"status": "cancelled"});
                                }
                              }),
                              text: AppLocalization.instance
                                  .getLocalizationFor("cancelBooking"),
                              buttonColor: const Color(0xFFF1D7D6),
                              textColor: Colors.red,
                            ),
                          ),
                        if (_ap.status == "pending") const SizedBox(height: 25),
                      ],
                    ),
                  ),
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fetcherCubit.initUnRegisterAppointmentUpdates();
    super.dispose();
  }
}
