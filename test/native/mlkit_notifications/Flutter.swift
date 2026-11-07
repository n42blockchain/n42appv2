// Test boundary only. Production GenericModelManager.swift is compiled unchanged.
@_exported import Foundation

public typealias FlutterResult = (Any?) -> Void
public let FlutterMethodNotImplemented = "not_implemented"

@objc public class FlutterMethodCall: NSObject {
  public let arguments: Any?
  public init(arguments: Any?) { self.arguments = arguments }
}

public class FlutterError: NSObject {
  public let code: String
  public init(code: String, message: String?, details: Any?) { self.code = code }
}
