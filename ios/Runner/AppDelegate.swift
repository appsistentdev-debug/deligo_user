// import UIKit
// import Flutter
// import GoogleMaps // update by Prateek

// @main
// @objc class AppDelegate: FlutterAppDelegate {
//   override func application(
//     _ application: UIApplication,
//     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//   ) -> Bool {
//     GMSServices.provideAPIKey("AIzaSyCQNbOlbjGZVm2UaHgu11Nu5YQM3APhYrQ") // add this line with your iOS key update by Prateek
//     GeneratedPluginRegistrant.register(with: self)
//     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//   }
// }

import UIKit
import Flutter
import GoogleMaps          // Google Maps
import OneSignalFramework  // OneSignal

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // Google Maps API Key
    GMSServices.provideAPIKey("GOOGLE_MAP_API_KEY")

    // OneSignal Debug Logs (optional)
    OneSignal.Debug.setLogLevel(.LL_VERBOSE)

    // OneSignal Initialization
    OneSignal.initialize("ONESIGNAL_APP_ID_CUSTOMER")

    // Ask for push notification permission (IMPORTANT for iOS)
    OneSignal.Notifications.requestPermission({ accepted in
      print("User accepted notifications: \(accepted)")
    }, fallbackToSettings: true)

    // Register plugins
    GeneratedPluginRegistrant.register(with: self)

    return super.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
  }
}

