import 'package:deligo/localization/languages/english.dart';
import 'package:deligo/localization/languages/arabic.dart'; // arabic language updated by prateek 16th dec 2025
// import 'package:deligo/localization/languages/hindi.dart'; // updated hindi language by prateek 16th dec 2025
import 'package:deligo/localization/languages/french.dart';
import 'package:deligo/localization/languages/german.dart';
import 'package:deligo/localization/languages/indonesian.dart';
import 'package:deligo/localization/languages/italian.dart';
import 'package:deligo/localization/languages/portuguese.dart';
import 'package:deligo/localization/languages/romanian.dart';
import 'package:deligo/localization/languages/spanish.dart';
import 'package:deligo/localization/languages/swahili.dart';
import 'package:deligo/localization/languages/turkish.dart';
import 'package:deligo/utility/constants.dart';

class AppConfig {
// Sets the application's display name
  static String appName = "Deligo Dev";
// Base URL for your app’s API requests.
  static String baseUrl = "http://10.0.2.2:8000/";
//   Google Maps API key or other Google services
  static const String googleApiKey = "GOOGLE_MAP_API_KEY";
//   App ID for OneSignal push notification service.
  static String onesignalAppId = "928fb157-0085-4285-b10b-0c7a3898bd85";
//   Default UI theme for the app.
  static const String themeDefault = Constants.themeDark;
//   Default language/locale of the app
  static const String languageDefault = "en";
//   Flag to determine if the app is in "demo" mode
  static const bool isDemoMode = false;
//   Default center location for any map screen
  static const Map<String, double> mapCenterDefault = {
    "latitude": 28.6440836,
    "longitude": 77.0932313,
  };

  static final Map<String, AppLanguage> languagesSupported = {
    "en": AppLanguage("English", english()),
    // "hnd": AppLanguage("Hindi", hindi()),
    "ar": AppLanguage("عربى Arabic", arabic()), // arabic language updated by prateek 16th dec 2025
    "de": AppLanguage("Deutsch", german()),
    "pt": AppLanguage("Portugal", portuguese()),
    "fr": AppLanguage("Français", french()),
    "id": AppLanguage("Bahasa Indonesia", indonesian()),
    "es": AppLanguage("Español", spanish()),
    "it": AppLanguage("italiano", italian()),
    "tr": AppLanguage("Türk", turkish()),
    "sw": AppLanguage("Kiswahili", swahili()),
    "ro": AppLanguage("română", romanian()),
  };
  static FireConfig? fireConfig;
  static bool get isSocialAuthEnabled =>
      (fireConfig?.enableSocialAuthFacebook ?? false) ||
      (fireConfig?.enableSocialAuthGoogle ?? false);
}

class FireConfig {
  bool enableSocialAuthApple = false;
  bool enableSocialAuthGoogle = false;
  bool enableSocialAuthFacebook = false;

  bool get isSocialAuthEnabled =>
      enableSocialAuthApple ||
      enableSocialAuthGoogle ||
      enableSocialAuthFacebook;

  @override
  String toString() {
    return '(enableSocialAuthApple: $enableSocialAuthApple, enableSocialAuthGoogle: $enableSocialAuthGoogle, enableSocialAuthFacebook: $enableSocialAuthFacebook)';
  }
}

class AppLanguage {
  final String name;
  final Map<String, String> values;
  AppLanguage(this.name, this.values);
}
