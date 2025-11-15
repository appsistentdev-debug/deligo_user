import 'package:buy_this_app/buy_this_app.dart';
import 'package:deligo/bloc/app_cubit.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/config/assets.dart';
import 'package:deligo/config/page_routes.dart';
import 'package:deligo/localization/app_localization.dart';
import 'package:deligo/models/user_data.dart';
import 'package:deligo/models/wallet.dart';
import 'package:deligo/network/remote_repository.dart';
import 'package:deligo/widgets/option_tile.dart';
import 'package:deligo/utility/app_settings.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:deligo/widgets/cached_image.dart';
import 'package:deligo/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BottomTabAccount extends StatelessWidget {
  const BottomTabAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final List<(IconData, String, VoidCallback?)> options = [
      (
        Icons.location_on,
        AppLocalization.instance.getLocalizationFor("savedAddresses"),
        () => Navigator.pushNamed(context, PageRoutes.savedAddressPage),
      ),
      (
        Icons.discount,
        AppLocalization.instance.getLocalizationFor("offers"),
        () => Navigator.pushNamed(context, PageRoutes.couponPage),
      ),
      (
        Icons.mail,
        AppLocalization.instance.getLocalizationFor("supportFaqs"),
        () => Navigator.pushNamed(context, PageRoutes.supportPage),
      ),
      (
        Icons.question_answer,
        AppLocalization.instance.getLocalizationFor("faqs"),
        () => Navigator.pushNamed(context, PageRoutes.faqPage),
      ),
      (
        Icons.language,
        AppLocalization.instance.getLocalizationFor("changeLanguage"),
        () => Navigator.pushNamed(context, PageRoutes.languagePage),
      ),
      (
        Icons.assignment,
        AppLocalization.instance.getLocalizationFor("termsConditions"),
        () => Navigator.pushNamed(context, PageRoutes.tncPage),
      ),
      (
        Icons.logout,
        AppLocalization.instance.getLocalizationFor("logout"),
        () => ConfirmDialog.showConfirmation(
                    context,
                    Text(AppLocalization.instance.getLocalizationFor("logout")),
                    Text(AppLocalization.instance
                        .getLocalizationFor("logout_msg")),
                    AppLocalization.instance.getLocalizationFor("no"),
                    AppLocalization.instance.getLocalizationFor("yes"))
                .then((value) {
              if (value != null && value == true) {
                //Navigator.pop(context);
                BlocProvider.of<AppCubit>(context).logOut();
              }
            }),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: null,
        title: Text(
          AppLocalization.instance.getLocalizationFor("account"),
          style: theme.textTheme.headlineLarge
              ?.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (AppConfig.isDemoMode)
            BuyThisApp.button(
              height: 38,
              AppConfig.appName,
              'https://dashboard.vtlabs.dev/projects/envato-referral-buy-link?project_slug=cab_book_flutter',
              target: Target.WhatsApp,
              color: const Color(0xffF80048),
            ),
          if (AppConfig.isDemoMode)
            const SizedBox(
              width: 36,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const UserMeGlance(),
            const SizedBox(height: 16),
            const WalletMeGlance(),
            const SizedBox(height: 16),
            Text(
              AppLocalization.instance.getLocalizationFor("accountOptions"),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.unselectedWidgetColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (context, index) => const SizedBox(),
                itemBuilder: (context, index) => OptionTile(
                    title: options[index].$2,
                    icon: options[index].$1,
                    onTap: options[index].$3),
              ),
            ),
            if (AppConfig.isDemoMode)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: BuyThisApp.developerRowVerbose(
                  theme.scaffoldBackgroundColor,
                  theme.primaryColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class WalletMeGlance extends StatefulWidget {
  const WalletMeGlance({super.key});

  @override
  State<WalletMeGlance> createState() => _WalletMeGlanceState();
}

class _WalletMeGlanceState extends State<WalletMeGlance> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return FutureBuilder<Wallet?>(
      future: RemoteRepository().balanceWallet(),
      builder: (BuildContext context, AsyncSnapshot<Wallet?> snapshotBalance) =>
          GestureDetector(
        onTap: () => Navigator.pushNamed(context, PageRoutes.walletPage)
            .then((value) => setState(() {})),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            // color: theme.primaryColorLight,
            image: DecorationImage(
              image: const AssetImage('assets/wallet_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: theme.cardColor,
                ),
                padding: const EdgeInsets.all(9),
                child: Icon(
                  Icons.flash_on,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalization.instance.getLocalizationFor("wallet"),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.cardColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${AppSettings.currencyIcon} ${snapshotBalance.data?.balance.toStringAsFixed(0) ?? 0}",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.cardColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UserMeGlance extends StatefulWidget {
  const UserMeGlance({super.key});

  @override
  State<UserMeGlance> createState() => _UserMeGlanceState();
}

class _UserMeGlanceState extends State<UserMeGlance> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    double width = MediaQuery.of(context).size.width;
    return FutureBuilder<UserData?>(
      future: LocalDataLayer().getUserMe(),
      builder: (BuildContext context, AsyncSnapshot<UserData?> snapshot) =>
          GestureDetector(
        onTap: () => Navigator.pushNamed(context, PageRoutes.profilePage)
            .then((value) => setState(() {})),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snapshot.data?.name ?? "",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  snapshot.data?.mobile_number ?? "",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(width * 0.025),
              child: CachedImage(
                imageUrl: snapshot.data?.imageUrl,
                imagePlaceholder: Assets.assetsPlaceholderProfile,
                height: width * 0.2,
                width: width * 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
