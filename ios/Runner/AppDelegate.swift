import UIKit
import Flutter
import GoogleMaps
import Fabric
import Crashlytics

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBx8brcoVisQ4_5FUD-xJlS1i4IwjSS-Hc")
    GeneratedPluginRegistrant.register(with: self)
    Fabric.with([Crashlytics.self])
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
