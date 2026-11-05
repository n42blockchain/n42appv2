# Official release binaries and SHA-256 from the 4.8.7 Package.swift asset.
# CocoaPods trunk does not publish this release; keep the existing pod identity.
Pod::Spec.new do |s|
  s.name = 'TrustWalletCore'
  s.module_name = 'WalletCore'
  s.version = '4.8.7'
  s.summary = 'Official WalletCore 4.8.7 binary distribution'
  s.homepage = 'https://github.com/trustwallet/wallet-core'
  s.license = { :type => 'Apache-2.0' }
  s.author = 'Trust Wallet'
  s.source = { :http => 'https://github.com/trustwallet/wallet-core/releases/download/4.8.7/WalletCore.xcframework.zip',
               :sha256 => '7c2315811ddb08d9e49bb080a3008ce388f1fc4013cbcc3d6bfcc42fd657e831' }
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  s.vendored_frameworks = 'WalletCore.xcframework'
  s.libraries = 'c++'
  s.dependency 'WalletCoreSwiftProtobuf', '= 4.8.7'
end
