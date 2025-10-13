import Flutter
import UIKit

public class DeeplinkSdkPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var initialLink: String?
    private var latestLink: String?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let methodChannel = FlutterMethodChannel(
            name: "deeplink_sdk",
            binaryMessenger: registrar.messenger()
        )
        let eventChannel = FlutterEventChannel(
            name: "deeplink_sdk/events",
            binaryMessenger: registrar.messenger()
        )
        
        let instance = DeeplinkSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: methodChannel)
        eventChannel.setStreamHandler(instance)
        
        // Register for application delegate callbacks
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getInitialLink":
            result(initialLink)
        case "getLatestLink":
            result(latestLink)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - FlutterStreamHandler
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        if let link = latestLink {
            events(link)
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
    
    // MARK: - Deep Link Handling
    
    private func handleDeepLink(_ url: String) {
        if initialLink == nil {
            initialLink = url
        }
        latestLink = url
        eventSink?(url)
    }
}

// MARK: - UIApplicationDelegate

extension DeeplinkSdkPlugin {
    
    // Handle URL schemes
    public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        handleDeepLink(url.absoluteString)
        return true
    }
    
    // Handle Universal Links (iOS 9+)
    public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                handleDeepLink(url.absoluteString)
                return true
            }
        }
        return false
    }
    
    // Handle launch options
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        if let url = launchOptions[UIApplication.LaunchOptionsKey.url] as? URL {
            handleDeepLink(url.absoluteString)
        } else if let activityDictionary = launchOptions[UIApplication.LaunchOptionsKey.userActivityDictionary] as? [AnyHashable: Any] {
            for key in activityDictionary.keys {
                if let userActivity = activityDictionary[key] as? NSUserActivity {
                    if let url = userActivity.webpageURL {
                        handleDeepLink(url.absoluteString)
                        break
                    }
                }
            }
        }
        return true
    }
}
