import UIKit
import Flutter
import Fabric
import Crashlytics
import Firebase
import FirebaseAuth
import UserNotifications
import FirebaseInstanceID

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    GeneratedPluginRegistrant.register(with: self)
    
    let controller = window.rootViewController as! FlutterViewController

    let flavorChannel = FlutterMethodChannel(
       name: "flavor",
       binaryMessenger: controller.binaryMessenger)

    flavorChannel.setMethodCallHandler({(call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
       let flavor = Bundle.main.infoDictionary?["App - Flavor"]
       result(flavor)
    })
    
    Fabric.with([Crashlytics.self])
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let firebaseAuth = Auth.auth()
    firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
  }
}
