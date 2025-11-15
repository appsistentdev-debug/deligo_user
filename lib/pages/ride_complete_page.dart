import 'package:deligo/utility/locale_data_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/assets.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/rating_request.dart';
import 'package:deligo/models/ride.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/toaster.dart';

class RideCompletePage extends StatelessWidget {
  const RideCompletePage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: RideCompleteStateful(
            ModalRoute.of(context)!.settings.arguments as Ride),
      );
}

class RideCompleteStateful extends StatefulWidget {
  final Ride ride;

  const RideCompleteStateful(this.ride, {super.key});

  @override
  State<RideCompleteStateful> createState() => _RideCompleteStatefulState();
}

class _RideCompleteStatefulState extends State<RideCompleteStateful> {
  late FetcherCubit _fetcherCubit;

  Ride get ride => widget.ride;
  double eRating = -1;

  @override
  void initState() {
    _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => LocalDataLayer()
        .getRatedRide(ride.id)
        .then((value) => setState(() => eRating = value)));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is RatingLoading) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }
        if (state is RatingLoaded || state is RatingFail) {
          if (state is RatingLoaded) {
            Toaster.showToastCenter(
              AppLocalization.instance.getLocalizationFor("rating_submitted"),
            );
          }
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.primaryColor,
          automaticallyImplyLeading: false,
          title: Text(
            "ID #${widget.ride.id}",
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.cardColor,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: InkWell(
                onTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: CircleAvatar(
                  backgroundColor: theme.cardColor,
                  child: Icon(
                    Icons.close,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            //const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.only(top: 20),
              color: theme.primaryColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CachedImage(
                    imageUrl: ride.vehicle_type?.image_url,
                    imagePlaceholder: Assets.deliveryTypeCar,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                  Text(
                    AppLocalization.instance
                        .getLocalizationFor("ride_status_${ride.status}"),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.cardColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    width: 80,
                  )
                ],
              ),
            ),
            Divider(
              thickness: 6,
              height: 6,
              color: theme.cardColor,
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalization.instance.getLocalizationFor(
                  eRating == -1 ? "howWasDriverService" : "youRated"),
              style: theme.textTheme.titleSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(
              child: RatingBar.builder(
                ignoreGestures: eRating != -1,
                initialRating: eRating == -1 ? 1 : eRating,
                minRating: 1,
                unratedColor: theme.hintColor,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: theme.primaryColor,
                ),
                onRatingUpdate: (rating) =>
                    _fetcherCubit.initCreateRatingDriver(
                  widget.ride.id,
                  widget.ride.driver?.id ?? -1,
                  RatingRequest(
                      rating.toInt(), getReview(rating.toInt()), null),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Divider(
              thickness: 6,
              height: 6,
              color: theme.cardColor,
            ),
            const SizedBox(height: 34),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: AlignmentDirectional.centerStart,
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedImage(
                          imageUrl: widget.ride.driver?.user?.imageUrl,
                          imagePlaceholder: Assets.assetsPlaceholderProfile,
                          height: 50,
                          width: 50,
                        ),
                      ),
                      Positioned(
                        left: -2,
                        bottom: -10,
                        right: -2,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color(0xFF009D06),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 3,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 10,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                widget.ride.driver?.ratings
                                        ?.toStringAsFixed(1) ??
                                    "0",
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ride.driver?.user?.name ?? "",
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 6),
                      if (widget.ride.driver?.vehicle_number != null)
                        Text(
                          widget.ride.driver?.vehicle_number ?? "",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        widget.ride.vehicle_type?.title ?? "",
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: theme.hintColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Divider(
              thickness: 6,
              height: 6,
              color: theme.cardColor,
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: theme.primaryColor,
                        child: Icon(
                          Icons.location_on,
                          size: 13,
                          color: theme.scaffoldBackgroundColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(
                        5,
                        (index) => Column(
                          children: [
                            CircleAvatar(
                              radius: 2,
                              backgroundColor: theme.hintColor,
                            ),
                            const SizedBox(height: 6)
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: theme.primaryColor,
                        child: Icon(
                          Icons.navigation,
                          size: 13,
                          color: theme.scaffoldBackgroundColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalization.instance
                              .getLocalizationFor("pickupLocation"),
                          style:
                              theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.ride.address_from,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 26),
                        Text(
                          AppLocalization.instance
                              .getLocalizationFor("dropOffLocation"),
                          style:
                              theme.textTheme.bodySmall?.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.ride.address_to,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 6,
              height: 6,
              color: theme.cardColor,
            ),
            const SizedBox(height: 20),
            if (widget.ride.getMetaValue("package_type") != null)
              buildAmountTile(
                  theme,
                  AppLocalization.instance.getLocalizationFor("packageType"),
                  widget.ride.getMetaValue("package_type") ?? ""),
            if (widget.ride.getMetaValue("package_type") != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: theme.cardColor,
                ),
              ),
            buildAmountTile(
                theme,
                AppLocalization.instance.getLocalizationFor("rideCost"),
                widget.ride.fareFormatted ?? ""),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: theme.cardColor,
              ),
            ),
            if (widget.ride.discount != null && widget.ride.discount != 0) ...[
              buildAmountTile(
                  theme,
                  AppLocalization.instance.getLocalizationFor("discount"),
                  "${AppSettings.currencyIcon} ${(widget.ride.discount ?? 0).toStringAsFixed(2)}"),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: theme.cardColor,
                ),
              ),
            ],
            buildAmountTile(
                theme,
                AppLocalization.instance.getLocalizationFor("paymentMethod"),
                widget.ride.payment?.paymentMethod?.title ?? ""),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: theme.cardColor,
              ),
            ),
            buildAmountTile(
                theme,
                AppLocalization.instance.getLocalizationFor("bookedOn"),
                widget.ride.ride_on_formatted ?? ""),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Padding buildAmountTile(ThemeData theme, String title, String amount) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall,
              ),
            ),
            Text(
              amount,
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
      );

  String getReview(int rating) {
    switch (rating) {
      case 1:
        return "Very Bad";
      case 2:
        return "Bad";
      case 3:
        return "Average";
      case 4:
        return "Good";
      case 5:
        return "Very Good";
      default:
        return "N/A";
    }
  }
}
