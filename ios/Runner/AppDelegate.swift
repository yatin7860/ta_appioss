import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

    private var locationChannel: FlutterMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // REGISTER FLUTTER PLUGINS
        GeneratedPluginRegistrant.register(with: self)

        // WAIT UNTIL FLUTTER UI IS READY
        DispatchQueue.main.async { [weak self] in

            guard let self = self else {
                return
            }

            // GET FLUTTER ROOT CONTROLLER
            guard let controller =
            self.window?.rootViewController
                as? FlutterViewController else {

                print("FlutterViewController not found")
                return
            }

            // CREATE METHOD CHANNEL
            self.locationChannel = FlutterMethodChannel(
                name: "native/location",
                binaryMessenger: controller.binaryMessenger
            )

            // HANDLE FLUTTER METHOD CALLS
            self.locationChannel?.setMethodCallHandler {

                (
                    call: FlutterMethodCall,
                    result: @escaping FlutterResult
                ) in

                switch call.method {

                case "startTracking":

                    print("START TRACKING CALLED")

                    LocationManager.shared.startTracking()

                    result("Tracking Started")

                case "stopTracking":

                    print("STOP TRACKING CALLED")

                    LocationManager.shared.stopTracking()

                    result("Tracking Stopped")

                default:

                    result(FlutterMethodNotImplemented)
                }
            }
        }

        // IMPORTANT:
        // RETURN TRUE FOR STABLE IOS LIFECYCLE
        return true
    }

    // =====================================================
    // APP ENTERED BACKGROUND
    // =====================================================

    override func applicationDidEnterBackground(
        _ application: UIApplication
    ) {

        super.applicationDidEnterBackground(application)

        print("App entered background")
    }

    // =====================================================
    // APP ENTERED FOREGROUND
    // =====================================================

    override func applicationWillEnterForeground(
        _ application: UIApplication
    ) {

        super.applicationWillEnterForeground(application)

        print("App entered foreground")
    }

    // =====================================================
    // APP TERMINATED
    // =====================================================

    override func applicationWillTerminate(
        _ application: UIApplication
    ) {

        print("App will terminate")
    }
}