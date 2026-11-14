# Official release binaries and SHA-256 from the 4.9.3 Package.swift asset.
# CocoaPods trunk does not publish this release; keep the existing pod identity.
Pod::Spec.new do |s|
  s.name = 'TrustWalletCore'
  s.module_name = 'WalletCore'
  s.version = '4.9.3'
  s.summary = 'Official WalletCore 4.9.3 binary distribution'
  s.homepage = 'https://github.com/trustwallet/wallet-core'
  s.license = { :type => 'Apache-2.0' }
  s.author = 'Trust Wallet'
  s.source = { :http => 'https://github.com/trustwallet/wallet-core/releases/download/4.9.3/WalletCore.xcframework.zip',
               :sha256 => '3d818079cac68bdfbf30d853ff15e2281c3a126a4ca6a830a878873155700f82' }
  s.ios.deployment_target = '15.0'
  s.swift_version = '5.0'
  s.vendored_frameworks = 'WalletCore.xcframework'
  s.libraries = 'c++'
  s.dependency 'WalletCoreSwiftProtobuf', '= 4.9.3'
end
