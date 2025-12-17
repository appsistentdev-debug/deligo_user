// - updated by Awanish : 11 dec 2025
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:deligo/bloc/connectivity_cubit.dart';
import 'app.dart';
import 'bloc/app_cubit.dart';
import 'bloc/language_cubit.dart';
import 'flavors.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

// OneSignal Import-- updated by Awanish : 11 dec 2025
import 'package:onesignal_flutter/onesignal_flutter.dart';


// fvm flutter run --flavor deligo
Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Set app flavor
  F.appFlavor = Flavor.values.firstWhere((element) => element.name == appFlavor);

  // --- Firebase ---
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // --- OneSignal Initialization (Required for SDK 5.x) ---- updated by Awanish : 11 dec 2025
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("928fb157-0085-4285-b10b-0c7a3898bd85");

  // Ask user for permission (Android 13+)
  OneSignal.Notifications.requestPermission(true);

  // Show debug info
  final app = Firebase.app();
  debugPrint(' Firebase App Initialized: ${app.name}');
  debugPrint('Project ID: ${app.options.projectId}');
  debugPrint('App ID: ${app.options.appId}');
  debugPrint('API Key: ${app.options.apiKey}');
  debugPrint('Storage Bucket: ${app.options.storageBucket}');

  // --- Splash ---
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Lock orientation-- updated by Awanish : 11 dec 2025
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarContrastEnforced: true,
  ));

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(create: (context) => AppCubit()),
        BlocProvider(create: (context) => ConnectivityCubit()),
      ],
      child: const App(),
    ),
  );
}


// - updated by Awanish : 11 dec 2025
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_native_splash/flutter_native_splash.dart';

// import 'package:deligo/bloc/connectivity_cubit.dart';
// import 'app.dart';
// import 'bloc/app_cubit.dart';
// import 'bloc/language_cubit.dart';
// import 'flavors.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';

// // OneSignal Import-- updated by Awanish : 11 dec 2025
// import 'package:onesignal_flutter/onesignal_flutter.dart';

// // razorpay integration - updated by prateek 12 dec 2025
// // ---------------------------------------------------
// import 'package:razorpay_flutter/razorpay_flutter.dart';
// import 'dart:convert';
// import 'package:http/http.dart';
// // ---------------------------------------------------

// // fvm flutter run --flavor deligo
// Razorpay? razorpay; // razorpay global instance

// Future<void> main() async {
//   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

//   // Set app flavor
//   F.appFlavor = Flavor.values.firstWhere((element) => element.name == appFlavor);

//   // --- Firebase ---
//   await Firebase.initializeApp();
//   await FirebaseAppCheck.instance.activate(
//     androidProvider: AndroidProvider.debug,
//   );

//   // --- OneSignal Initialization (Required for SDK 5.x) ---- updated by Awanish : 11 dec 2025
//   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//   OneSignal.initialize("ONESIGNAL_APP_ID_CUSTOMER");

//   // Ask user for permission (Android 13+)
//   OneSignal.Notifications.requestPermission(true);

//   // Show debug info
//   final app = Firebase.app();
//   debugPrint(' Firebase App Initialized: ${app.name}');
//   debugPrint('Project ID: ${app.options.projectId}');
//   debugPrint('App ID: ${app.options.appId}');
//   debugPrint('API Key: ${app.options.apiKey}');
//   debugPrint('Storage Bucket: ${app.options.storageBucket}');

//   // --- Splash ---
//   FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

//   // Lock orientation-- updated by Awanish : 11 dec 2025
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitDown,
//     DeviceOrientation.portraitUp,
//   ]);

//   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
//     statusBarIconBrightness: Brightness.dark,
//     systemNavigationBarColor: Colors.white,
//     systemNavigationBarContrastEnforced: true,
//   ));

//   // -------------------------------------------------------------
//   // 🚀 Razorpay initialization - added by prateek 12 dec 2025
//   razorpay = Razorpay();

//   razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//   razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//   razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

//   debugPrint("🔥 Razorpay Initialized Successfully");
//   // -------------------------------------------------------------

//   runApp(
//     MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => LanguageCubit()),
//         BlocProvider(create: (context) => AppCubit()),
//         BlocProvider(create: (context) => ConnectivityCubit()),
//       ],
//       child: const App(),
//     ),
//   );
// }

// // -------------------------------------------------------------
// // 🔥 Razorpay Callbacks - added by prateek 12 dec 2025
// void _handlePaymentSuccess(PaymentSuccessResponse response) {
//   debugPrint("💰 Payment Success! Payment ID: ${response.paymentId}");
//   debugPrint("Order ID: ${response.orderId}");

//   // TODO: Call backend API to verify
// }

// void _handlePaymentError(PaymentFailureResponse response) {
//   debugPrint("❌ Payment Failed: ${response.code} - ${response.message}");
// }

// void _handleExternalWallet(ExternalWalletResponse response) {
//   debugPrint("📦 External Wallet Selected: ${response.walletName}");
// }
// -------------------------------------------------------------
