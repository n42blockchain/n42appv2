# Official release binaries and SHA-256 from the 4.8.7 Package.swift asset.
# CocoaPods trunk does not publish this release; keep the existing pod identity.
Pod::Spec.new do |s|
  s.name = 'WalletCoreSwiftProtobuf'
  s.module_name = 'WalletCoreSwiftProtobuf'
  s.version = '4.8.7'
  s.summary = 'Official WalletCore 4.8.7 binary distribution'
  s.homepage = 'https://github.com/trustwallet/wallet-core'
  s.license = { :type => 'BSD-3-Clause' }
  s.author = 'Trust Wallet'
  s.source = { :http => 'https://github.com/trustwallet/wallet-core/releases/download/4.8.7/WalletCoreSwiftProtobuf.xcframework.zip',
               :sha256 => 'b39fa0f3968fcdab0ab5a44c26d3e16d6f1277f5df6f7db008cdf65890204f67' }
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  s.vendored_frameworks = 'WalletCoreSwiftProtobuf.xcframework'
  s.libraries = 'c++'
end
