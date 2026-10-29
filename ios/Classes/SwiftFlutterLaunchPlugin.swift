import Flutter
import UIKit

public class SwiftFlutterLaunchPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_launch", binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterLaunchPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

    if ("launchWathsApp" == call.method) {
      let args = call.arguments as? [String: Any]
      let phone = args?["phone"] as? String
      let message = args?["message"] as? String

      var components = URLComponents()
      components.scheme = "whatsapp"
      components.host = "send"
      components.queryItems = [
        URLQueryItem(name: "phone", value: phone ?? ""),
        URLQueryItem(name: "text", value: message ?? "")
      ]

      guard let url = components.url else {
        result(false)
        return
      }

      // openURL(_:) foi descontinuado e no iOS 18+ não abre mais nada (retorna false silenciosamente)
      UIApplication.shared.open(url, options: [:]) { success in
        result(success)
      }
      return
    }

    if ("hasApp" == call.method) {
      let args = call.arguments as? [String: Any]
      let name = args?["name"] as? String

       switch name ?? "0" {
         case "whatsapp":
           result(schemeAvailable(scheme: "whatsapp://send"))
           break
         default:
             result(false)
         break
       }
      return
    }

    result(FlutterMethodNotImplemented)
  }

  public func schemeAvailable(scheme: String) -> Bool {
    let urlStringEncoded = scheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let URL = NSURL(string: urlStringEncoded!)

    if UIApplication.shared.canOpenURL(URL! as URL) {
      return true
    }

    return false
  }
}
