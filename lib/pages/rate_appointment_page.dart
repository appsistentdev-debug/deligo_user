import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/appointment.dart';
import 'package:deligo/models/category.dart';
import 'package:deligo/models/rating_request.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/toaster.dart';
import 'package:deligo/widgets/widget_size.dart';

class RateAppointmentPage extends StatelessWidget {
  const RateAppointmentPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: RateAppointmentStateful(
            ModalRoute.of(context)!.settings.arguments as Appointment),
      );
}

class RateAppointmentStateful extends StatefulWidget {
  final Appointment appointment;
  const RateAppointmentStateful(this.appointment, {super.key});

  @override
  State<RateAppointmentStateful> createState() =>
      _RateAppointmentStatefulState();
}

class _RateAppointmentStatefulState extends State<RateAppointmentStateful> {
  Size? _headerSize;
  final TextEditingController _reviewController = TextEditingController();
  double _ratingServiceProvider = 3;

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
        if (state is RatingLoaded) {
          Toaster.showToastTop(
              AppLocalization.instance.getLocalizationFor("rating_submitted"));
          Navigator.pop(context);
        }
        if (state is RatingFail) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            FractionallySizedBox(
              heightFactor: 0.25,
              widthFactor: 1.0,
              child: WidgetSize(
                child: FutureBuilder<String?>(
                  future: _getBannerImage(),
                  builder: (context, asyncSnapshot) => CachedImage(
                    imageUrl: asyncSnapshot.data,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
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
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "${AppLocalization.instance.getLocalizationFor("serviceid")} ${widget.appointment.id}",
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              top: (_headerSize?.height ?? 0),
              height: MediaQuery.of(context).size.height -
                  (_headerSize?.height ?? 0) -
                  MediaQuery.of(context).viewInsets.bottom,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalization.instance
                                  .getLocalizationFor("how_quality_service"),
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: theme.hintColor),
                            ),
                            const SizedBox(height: 32),
                            RatingBar.builder(
                              initialRating: _ratingServiceProvider,
                              minRating: 1,
                              unratedColor: theme.hintColor,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: theme.primaryColor,
                              ),
                              onRatingUpdate: (rating) =>
                                  _ratingServiceProvider = rating,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              hintText: AppLocalization.instance
                                  .getLocalizationFor("write_review"),
                              controller: _reviewController,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text:
                          AppLocalization.instance.getLocalizationFor("submit"),
                      onTap: () {
                        Helper.clearFocus(context);
                        if (_reviewController.text.trim().length < 10 ||
                            _reviewController.text.trim().length > 140) {
                          Toaster.showToastTop(AppLocalization.instance
                              .getLocalizationFor("invalid_length_message"));
                          return;
                        }

                        BlocProvider.of<FetcherCubit>(context)
                            .initCreateRatingServiceProvider(
                                widget.appointment.id,
                                widget.appointment.provider?.id ?? -1,
                                RatingRequest(
                                    _ratingServiceProvider.toInt(),
                                    _reviewController.text.trim(),
                                    jsonEncode({
                                      "categories":
                                          widget.appointment.categories
                                    })));
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _getBannerImage() async {
    List<Category> categories = await LocalDataLayer().getCategoriesHome();
    for (Category c in categories) {
      if (c.slug == "home-service") {
        return c.imageBannerUrl;
      }
    }
    return null;
  }
}
