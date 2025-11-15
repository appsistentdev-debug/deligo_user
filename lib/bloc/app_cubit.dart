// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:deligo/config/app_config.dart';
import 'package:deligo/models/setting.dart';
import 'package:deligo/models/user_data.dart';
import 'package:deligo/network/remote_repository.dart';
import 'package:deligo/utility/cart_manager.dart';
import 'package:deligo/utility/constants.dart';
import 'package:deligo/utility/locale_data_layer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  late RemoteRepository _repository;

  AppCubit() : super(Uninitialized());

  Future<void> initApp() async {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    if (AppConfig.onesignalAppId.isNotEmpty) {
      OneSignal.initialize(AppConfig.onesignalAppId);
      //await OneSignal.shared.promptUserForPushNotificationPermission();
      //_addOnesignalEvents();
    }
    _repository = RemoteRepository();
    bool initialised = await LocalDataLayer().initAppSettings();
    await _setupFireConfig();
    if (initialised) {
      await emitAuthenticationState();
      _setupSettings(initialised);
    } else {
      await _setupSettings(initialised);
    }
    CartManager();
    FlutterNativeSplash.remove();
  }

  Future<void> _setupSettings(bool alreadyInitialized) async {
    try {
      List<Setting> settings = await _repository.fetchSettings();
      await LocalDataLayer().saveSettings(settings);
      if (!alreadyInitialized) await emitAuthenticationState();
    } catch (e) {
      if (kDebugMode) {
        print("getSettings: $e");
        print("something went wrong in emitAuthenticationState");
      }
      await LocalDataLayer().clearPrefKey(LocalDataLayer.settingsKey);
      emit(FailureState("network_issue"));
    }
  }

  Future<void> emitAuthenticationState() async {
    emit(Uninitialized());

    UserData? userData;
    try {
      userData = await _repository.getUser();
      await LocalDataLayer().setUserMe(userData!);
      //userData = await LocalDataLayer().getUserMe();
    } catch (e) {
      if (kDebugMode) {
        print("emitAuthenticationState: $e");
      }
    }

    bool isDemoShowLangs = false;
    if (AppConfig.isDemoMode) {
      isDemoShowLangs = await LocalDataLayer().getHasLanguageSelectionPromted();
      await LocalDataLayer().setHasLanguageSelectionPromted();
    }

    if (userData != null) {
      //await LocalDataLayer().setUserMe(userData);
      emit(Authenticated(isDemoShowLangs));
      _setupUserLanguageAndOneSignalPlayerId();
    } else {
      await LocalDataLayer().clearPrefsUser();
      emit(Unauthenticated(isDemoShowLangs));
    }
  }

  Future<void> initAuthenticated() async {
    emit(Uninitialized());
    Future.delayed(
        const Duration(milliseconds: 500), () => emit(Authenticated(false)));
    _setupUserLanguageAndOneSignalPlayerId();
  }

  Future<void> logOut() async {
    emit(Uninitialized());
    Future.delayed(const Duration(milliseconds: 500), () async {
      await _repository.logout();
      emit(Unauthenticated(false));
    });
  }

  Future<void> _setupUserLanguageAndOneSignalPlayerId() async {
    try {
      await OneSignal.Notifications.requestPermission(true);

      String currLang = await LocalDataLayer().getCurrentLanguage();
      UserData? updatedUserData = await _repository.updateUser({
        "notification":
            "{\"${Constants.roleUser}\":\"${OneSignal.User.pushSubscription.id!}\"}",
        "language": currLang,
      });
      if (updatedUserData != null) {
        await LocalDataLayer().setUserMe(updatedUserData);
        await FirebaseDatabase.instance
            .ref()
            .child(Constants.refUsersFcmIds)
            .child(("${updatedUserData.id}${Constants.roleUser}"))
            .set(OneSignal.User.pushSubscription.id!);
      }
    } catch (e) {
      if (kDebugMode) {
        print("userLanguageAndPlayerId: $e");
      }
    }
  }

  // void _addOnesignalEvents() async {
  //   OneSignal.shared.setNotificationWillShowInForegroundHandler(
  //       (OSNotificationReceivedEvent event) {
  //     if (kDebugMode) {
  //       print('FOREGROUND HANDLER CALLED WITH: $event');
  //     }
  //   });
  //   OneSignal.shared
  //       .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
  //     if (kDebugMode) {
  //       print('NOTIFICATION OPENED HANDLER CALLED WITH: $result');
  //     }
  //   });
  // }

  Future<void> _setupFireConfig() async {
    if (AppConfig.fireConfig == null) {
      try {
        AppConfig.fireConfig = FireConfig();
        await FirebaseRemoteConfig.instance.setDefaults({
          "enableSocialAuthApple": false,
          "enableSocialAuthFacebook": false,
          "enableSocialAuthGoogle": false,
        });
        await FirebaseRemoteConfig.instance.fetch();
        await FirebaseRemoteConfig.instance.activate();

        AppConfig.fireConfig!.enableSocialAuthFacebook =
            FirebaseRemoteConfig.instance.getBool("enableSocialAuthFacebook");
        AppConfig.fireConfig!.enableSocialAuthGoogle =
            FirebaseRemoteConfig.instance.getBool("enableSocialAuthGoogle");
        AppConfig.fireConfig!.enableSocialAuthApple =
            FirebaseRemoteConfig.instance.getBool("enableSocialAuthApple");
      } catch (e) {
        if (kDebugMode) {
          print("setupFireConfig: $e");
        }
      }
    }
    if (kDebugMode) {
      print("FireConfig: ${AppConfig.fireConfig}");
    }
  }
}
