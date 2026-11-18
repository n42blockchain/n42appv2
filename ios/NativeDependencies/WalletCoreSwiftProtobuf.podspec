# Official release binaries and SHA-256 from the 4.9.3 Package.swift asset.
# CocoaPods trunk does not publish this release; keep the existing pod identity.
Pod::Spec.new do |s|
  s.name = 'WalletCoreSwiftProtobuf'
  s.module_name = 'WalletCoreSwiftProtobuf'
  s.version = '4.9.3'
  s.summary = 'Official WalletCore 4.9.3 binary distribution'
  s.homepage = 'https://github.com/trustwallet/wallet-core'
  s.license = { :type => 'BSD-3-Clause' }
  s.author = 'Trust Wallet'
  s.source = { :http => 'https://github.com/trustwallet/wallet-core/releases/download/4.9.3/WalletCoreSwiftProtobuf.xcframework.zip',
               :sha256 => '90142ef3e7a1d4a257df172f507a3b766d6d9333c7fbc64af8e95fda30dd2f4a' }
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  s.vendored_frameworks = 'WalletCoreSwiftProtobuf.xcframework'
  s.libraries = 'c++'
end
