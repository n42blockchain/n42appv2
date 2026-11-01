// swift-tools-version: 5.9
import PackageDescription

let package = Package(
  name: "MobileVerifyCore",
  platforms: [.macOS(.v12), .iOS(.v13)],
  products: [.library(name: "MobileVerifyCore", targets: ["MobileVerifyCore"])],
  targets: [
    .target(name: "MobileVerifyCore", path: "Classes",
            exclude: ["FlutterMiningPlugin.swift", "MobileVerifyHandler.swift", "EvmsdkMobileVerifyBackend.swift"],
            sources: ["MobileVerifyMinerHost.swift", "MobileVerifySessionHost.swift"]),
    .testTarget(name: "MobileVerifyCoreTests", dependencies: ["MobileVerifyCore"], path: "Tests")
  ]
)
