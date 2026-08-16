import Flutter
import UIKit
import UserNotifications

/// The device end of push, kept to plumbing: what a notification means is Dart's business.
///
/// Registered as a Flutter application life cycle delegate rather than written onto the app
/// delegate, so plugins keep receiving the same callbacks.
class PushChannel: NSObject, FlutterApplicationLifeCycleDelegate {
  private let channel: FlutterMethodChannel

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(name: "spendable/push", binaryMessenger: messenger)

    super.init()

    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "register" else {
        result(FlutterMethodNotImplemented)

        return
      }

      self?.register(result)
    }
  }

  func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    channel.invokeMethod("token", arguments: deviceToken.map { String(format: "%02x", $0) }.joined())
  }

  func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    // The simulator has no APNs, so this is the ordinary path there and not worth surfacing.
    NSLog("push registration failed: %@", error.localizedDescription)
  }

  /// A silent push. iOS gives the app seconds rather than a callback to wait on, so the fetch
  /// result is reported as soon as Dart has been told.
  func application(
    _ application: UIApplication,
    didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) -> Bool {
    channel.invokeMethod("refresh", arguments: nil)
    completionHandler(.newData)

    return true
  }

  /// An alert that arrived while the app was open: show it, and refresh behind it.
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    channel.invokeMethod("refresh", arguments: nil)
    completionHandler([.banner, .sound])
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    channel.invokeMethod("opened", arguments: nil)
    completionHandler()
  }

  private func register(_ result: @escaping FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
      DispatchQueue.main.async {
        // Registered whatever the answer: a silent push needs no permission, and it is what
        // refreshes the app in the background.
        UIApplication.shared.registerForRemoteNotifications()

        result(granted)
      }
    }
  }
}
