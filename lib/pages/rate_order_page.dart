import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/order.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/custom_button.dart';
import 'package:deligo/widgets/custom_divider.dart';
import 'package:deligo/widgets/custom_text_field.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/toaster.dart';
import 'package:deligo/widgets/widget_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RateOrderPage extends StatelessWidget {
  const RateOrderPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
        create: (context) => FetcherCubit(),
        child: RateOrderStateful(
            ModalRoute.of(context)!.settings.arguments as Order),
      );
}

class RateOrderStateful extends StatefulWidget {
  final Order order;
  const RateOrderStateful(this.order, {super.key});

  @override
  State<RateOrderStateful> createState() => _RateOrderStatefulState();
}

class _RateOrderStatefulState extends State<RateOrderStateful> {
  Size? _headerSize;
  final TextEditingController _reviewController = TextEditingController();
  double _ratingVendor = 3;
  double _ratingDelivery = 3;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is RateOrderLoading) {
          Loader.showLoader(context);
        } else {
          Loader.dismissLoader(context);
        }
        if (state is RateOrderLoaded) {
          Toaster.showToastTop(
              AppLocalization.instance.getLocalizationFor("rating_submitted"));
          Navigator.pop(context);
        }
        if (state is RateOrderFail) {
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
                child: CachedImage(
                  imageUrl: widget.order.category?.imageBannerUrl,
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
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      widget.order.category?.title ??
                          "${AppLocalization.instance.getLocalizationFor("orderid")} ${widget.order.id}",
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
                                  .getLocalizationFor("how_quality"),
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: theme.hintColor),
                            ),
                            const SizedBox(height: 32),
                            RatingBar.builder(
                              initialRating: _ratingVendor,
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
                                  _ratingVendor = rating,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              hintText: AppLocalization.instance
                                  .getLocalizationFor("write_review"),
                              controller: _reviewController,
                              maxLines: 2,
                            ),
                            Container(
                              margin: const EdgeInsets.all(32),
                              child: const CustomDivider(withoutPadding: true),
                            ),
                            Text(
                              AppLocalization.instance
                                  .getLocalizationFor("how_delivery"),
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: theme.hintColor),
                            ),
                            const SizedBox(height: 16),
                            RatingBar.builder(
                              initialRating: _ratingDelivery,
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
                                  _ratingDelivery = rating,
                            ),
                          ],
                        ),
                      ),
                    ),
                    //const SizedBox(height: 20),
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
                            .initRateOrder(widget.order, {
                          "rating": _ratingVendor,
                          "review": _reviewController.text.trim(),
                        }, {
                          "rating": _ratingDelivery,
                          "review": "$_ratingDelivery review.",
                        });
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
}
