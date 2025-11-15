import 'package:deligo/bloc/fetcher_cubit.dart';
import 'package:deligo/config/colors.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/coupon.dart';
import 'package:deligo/utility/helper.dart';
import 'package:deligo/widgets/error_final_widget.dart';
import 'package:deligo/widgets/loader.dart';
import 'package:deligo/widgets/regular_app_bar.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CouponPage extends StatelessWidget {
  const CouponPage({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    return BlocProvider(
      create: (context) => FetcherCubit(),
      child: CouponStateful(
          pick: arguments != null &&
              arguments.containsKey("pick") &&
              arguments["pick"] == true),
    );
  }
}

class CouponStateful extends StatefulWidget {
  final bool pick;
  const CouponStateful({super.key, required this.pick});

  @override
  State<CouponStateful> createState() => CouponStatefulState();
}

class CouponStatefulState extends State<CouponStateful> {
  late FetcherCubit _fetcherCubit;
  bool isLoading = true;
  List<Coupon> coupons = [];

  @override
  void initState() {
    _fetcherCubit = BlocProvider.of<FetcherCubit>(context);
    super.initState();
    _fetcherCubit.initFetchCoupons();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return BlocListener<FetcherCubit, FetcherState>(
      listener: (context, state) {
        if (state is CouponsLoaded) {
          coupons = state.coupons;
          isLoading = false;
          setState(() {});
        }
        if (state is CouponsFail) {
          isLoading = false;
          setState(() {});
        }
      },
      child: Scaffold(
        appBar: RegularAppBar(
          title: AppLocalization.instance.getLocalizationFor("couponCodes"),
        ),
        body: coupons.isNotEmpty
            ? ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 0),
                separatorBuilder: (context, index) => Divider(
                  //height: 8,
                  thickness: 8,
                  color: theme.cardColor,
                ),
                itemCount: coupons.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    if (widget.pick) {
                      Navigator.pop(context, coupons[index]);
                    } else {
                      Clipboard.setData(
                              ClipboardData(text: coupons[index].code))
                          .then(
                        (value) => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${coupons[index].title} ${AppLocalization.instance.getLocalizationFor("copied")}.",
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      if (index == 0)
                        Divider(
                          thickness: 12,
                          color: theme.cardColor,
                        ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    coupons[index].title,
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${AppLocalization.instance.getLocalizationFor("till")} ${Helper.setupDate(coupons[index].expires_at, true)}",
                                    style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        color: theme.dividerColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                color: darken(theme.primaryColor),
                                strokeWidth: 1,
                                padding: EdgeInsets.zero,
                                //dashPattern: [10, 5],
                                radius: Radius.circular(8),
                              ),
                              child: Container(
                                width: 110,
                                decoration: BoxDecoration(
                                  color:
                                      theme.primaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  coupons[index].code,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            //const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      if (index == coupons.length - 1)
                        Divider(
                          thickness: 8,
                          color: theme.cardColor,
                        ),
                    ],
                  ),
                ),
              )
            : isLoading
                ? Loader.circularProgressIndicatorPrimary(context)
                : Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: ErrorFinalWidget.errorWithRetry(
                      context: context,
                      message: AppLocalization.instance
                          .getLocalizationFor("empty_coupons"),
                      actionText:
                          AppLocalization.instance.getLocalizationFor("okay"),
                      action: () => Navigator.pop(context),
                    ),
                  ),
      ),
    );
  }
}
