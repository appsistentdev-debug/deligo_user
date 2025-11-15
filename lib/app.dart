import 'package:buy_this_app/buy_this_app.dart';
import 'package:deligo/bloc/connectivity_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:deligo/bloc/app_cubit.dart';
import 'package:deligo/bloc/language_cubit.dart';

import 'config/assets.dart';
import 'config/page_routes.dart';
import 'config/style.dart';
import 'localization/app_localization.dart';
import 'pages/auth_sign_in_page.dart';
import 'pages/bottom_navigation_page.dart';
import 'pages/secondary_splash_page.dart';
import 'pages/select_language_page.dart';
import 'widgets/error_final_widget.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    _initializeApp();
    super.initState();
  }

  Future<void> _initializeApp() async {
    BlocProvider.of<ConnectivityCubit>(context).monitorInternet();
    await BlocProvider.of<AppCubit>(context).initApp();
    await BlocProvider.of<LanguageCubit>(context).getCurrentLanguage();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) => MaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            BuyThisApp.delegate,
          ],
          supportedLocales: AppLocalization.getSupportedLocales(),
          locale: locale,
          theme: appTheme,
          darkTheme: darkAppTheme,
          themeMode: ThemeMode.system,
          routes: PageRoutes().routes(),
          home: BlocBuilder<AppCubit, AppState>(
            builder: (context, appState) {
              switch (appState.runtimeType) {
                case Authenticated:
                  return (appState as Authenticated).isDemoShowLangs
                      ? const SelectLanguagePage(null, true)
                      : const BottomNavigationPage();
                case Unauthenticated:
                  return (appState as Unauthenticated).isDemoShowLangs
                      ? const SelectLanguagePage(null, true)
                      : const AuthSignInPage();
                case FailureState:
                  return BlocListener<ConnectivityCubit, ConnectivityState>(
                    listener: (context, state) {
                      if (state.isConnected) {
                        _initializeApp();
                      }
                    },
                    child: Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 48),
                      child: ErrorFinalWidget.errorWithRetry(
                        context: context,
                        message: AppLocalization.instance
                            .getLocalizationFor("network_issue"),
                        imageAsset: Assets.emptyOrders,
                        actionText:
                            AppLocalization.instance.getLocalizationFor("okay"),
                        action: () => SystemNavigator.pop(),
                      ),
                    ),
                  );
                default:
                  return const SecondarySplashPage();
              }
            },
          ),
        ),
      );
}
