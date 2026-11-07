import Foundation
import Flutter
import MLKitCommon

class TranslationModel: RemoteModel {}
class OtherModel: RemoteModel {}

func check(_ value: @autoclosure () -> Bool, _ message: String) {
  if !value() { fputs("FAIL: \(message)\n", stderr); exit(1) }
}
func call(_ wifi: Bool? = nil) -> FlutterMethodCall {
  var args: [String: Any] = ["task": "download"]
  if let wifi = wifi { args["wifi"] = wifi }
  return FlutterMethodCall(arguments: args)
}
func notify(_ model: RemoteModel, success: Bool = true) {
  NotificationCenter.default.post(
    name: success ? .mlkitModelDownloadDidSucceed : .mlkitModelDownloadDidFail,
    object: nil,
    userInfo: [ModelDownloadUserInfoKey.remoteModel.rawValue: model]
  )
}
let sdk = ModelManager.modelManager()
let model = TranslationModel(name: "es")
let manager = GenericModelManager()
var replies: [Any?] = []
let name = CommandLine.arguments[1]

switch name {
case "equivalent-success":
  manager.manage(model: model, call: call()) { replies.append($0) }
  notify(TranslationModel(name: "es"))
  check(replies.count == 1 && replies[0] as? String == "success", "copied model completion")
case "unrelated-notifications":
  manager.manage(model: model, call: call()) { replies.append($0) }
  notify(TranslationModel(name: "fr"))
  notify(OtherModel(name: "es"))
  NotificationCenter.default.post(name: .mlkitModelDownloadDidSucceed, object: nil)
  check(replies.isEmpty, "unrelated or malformed notification must not finish request")
  notify(TranslationModel(name: "es"))
  check(replies.count == 1, "matching completion remains available")
case "failure":
  manager.manage(model: model, call: call()) { replies.append($0) }
  notify(TranslationModel(name: "es"), success: false)
  check(replies.count == 1 && replies[0] as? String == "error", "matching failure")
case "duplicate-events":
  manager.manage(model: model, call: call()) { replies.append($0) }
  notify(model); notify(model); notify(model, success: false)
  check(replies.count == 1 && replies[0] as? String == "success", "exactly one result")
case "concurrent-models":
  var other: [Any?] = []
  manager.manage(model: model, call: call()) { replies.append($0) }
  manager.manage(model: TranslationModel(name: "fr"), call: call()) { other.append($0) }
  notify(TranslationModel(name: "fr"), success: false)
  check(replies.isEmpty && other.count == 1 && other[0] as? String == "error", "failure routes to its model")
  notify(TranslationModel(name: "es"))
  check(replies.count == 1 && replies[0] as? String == "success", "concurrent request survives")
case "duplicate-request":
  manager.manage(model: model, call: call()) { replies.append($0) }
  manager.manage(model: model, call: call()) { replies.append($0) }
  check((replies.first as? FlutterError)?.code == "download_in_progress", "duplicate request rejected")
  check(sdk.started.count == 1, "one SDK download")
  notify(model)
  check(replies.count == 2, "original request still completes")
case "duplicate-reentrant":
  manager.manage(model: model, call: call()) { replies.append($0) }
  manager.manage(model: model, call: call()) { _ in
    manager.manage(model: TranslationModel(name: "fr"), call: call()) { replies.append($0) }
  }
  notify(TranslationModel(name: "fr")); notify(model)
  check(replies.count == 2, "result callback may reenter manager without deadlock")
case "cached":
  sdk.cached.insert("es")
  manager.manage(model: model, call: call()) { replies.append($0) }
  notify(model)
  check(replies.count == 1 && sdk.started.isEmpty, "cached model completes without download")
case "deinit-cancels":
  var temporary: GenericModelManager? = GenericModelManager()
  let wasReleased = { [weak observed = temporary] in observed == nil }
  temporary!.manage(model: model, call: call()) { replies.append($0) }
  temporary = nil
  check(wasReleased(), "observers must not retain manager")
  check(replies.count == 1 && (replies[0] as? FlutterError)?.code == "cancelled", "pending result cancelled")
  notify(model)
  check(replies.count == 1, "late notification ignored after disposal")
case "wifi-policy":
  for (wifi, expectedCellular) in [(true as Bool?, false), (false as Bool?, true), (nil, false)] {
    manager.manage(model: model, call: call(wifi)) { _ in }
    check(sdk.conditions.last!.allowsCellularAccess == expectedCellular, "Wi-Fi policy must reach SDK")
    notify(model)
  }
case "synchronous-completion":
  sdk.onDownload = { notify($0) }
  manager.manage(model: model, call: call()) { replies.append($0) }
  check(replies.count == 1, "synchronous SDK notification does not deadlock")
default:
  fatalError("Unknown test")
}
print("PASS: \(name)")
