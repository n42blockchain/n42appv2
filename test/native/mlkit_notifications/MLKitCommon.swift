// Controllable SDK boundary; notifications, locking and production Swift are real.
@_exported import Foundation

open class RemoteModel: NSObject {
  public let name: String
  public init(name: String) { self.name = name }
}

public struct ModelDownloadUserInfoKey {
  public let rawValue: String
  public static let remoteModel = ModelDownloadUserInfoKey(rawValue: "remoteModel")
}

public extension Notification.Name {
  static let mlkitModelDownloadDidSucceed = Notification.Name("model_success")
  static let mlkitModelDownloadDidFail = Notification.Name("model_failure")
}

public class ModelDownloadConditions {
  public let allowsCellularAccess: Bool
  public let allowsBackgroundDownloading: Bool
  public init(allowsCellularAccess: Bool, allowsBackgroundDownloading: Bool) {
    self.allowsCellularAccess = allowsCellularAccess
    self.allowsBackgroundDownloading = allowsBackgroundDownloading
  }
}

public class ModelManager {
  private static let shared = ModelManager()
  public static func modelManager() -> ModelManager { shared }
  public var cached: Set<String> = []
  public var started: [RemoteModel] = []
  public var conditions: [ModelDownloadConditions] = []
  public var onDownload: ((RemoteModel) -> Void)?
  public func isModelDownloaded(_ model: RemoteModel) -> Bool { cached.contains(model.name) }
  @discardableResult
  public func download(_ model: RemoteModel, conditions: ModelDownloadConditions) -> Progress {
    started.append(model)
    self.conditions.append(conditions)
    onDownload?(model)
    return Progress(totalUnitCount: 1)
  }
  public func deleteDownloadedModel(_ model: RemoteModel, completion: (Error?) -> Void) {
    cached.remove(model.name)
    completion(nil)
  }
}
