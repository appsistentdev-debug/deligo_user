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

//fvm flutter run --flavor deligo
Future<void> main() async {
  F.appFlavor =
      Flavor.values.firstWhere((element) => element.name == appFlavor);
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  final app = Firebase.app();
  debugPrint(' Firebase App Initialized: ${app.name}');
  debugPrint('😂 Firebase App Options:');
  debugPrint('Project ID: ${app.options.projectId}');
  debugPrint('App ID: ${app.options.appId}');
  debugPrint('API Key: ${app.options.apiKey}');
  debugPrint('Storage Bucket: ${app.options.storageBucket}');

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]).then((_) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarContrastEnforced: true,
    ));
    runApp(MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LanguageCubit()),
        BlocProvider(create: (context) => AppCubit()),
        BlocProvider(create: (context) => ConnectivityCubit()),
      ],
      child: const App(),
    ));
  });
}
