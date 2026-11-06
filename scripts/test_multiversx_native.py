#!/usr/bin/env python3
"""Execute the production Swift MultiversX signer on a booted simulator.
No app, device, network or independent cryptographic conformance claim."""
import argparse
from pathlib import Path
import subprocess
import tempfile
from test_solana_native import declaration

ROOT = Path(__file__).resolve().parents[1]

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--simulator', required=True)
    args = parser.parse_args()
    source = (ROOT / 'ios/Runner/WalletCorePlugin+Signing.swift').read_text()
    methods = '\n'.join(declaration(source, 'func ' + name + '(').replace('private func', 'func', 1)
        for name in ['validMultiversXSigningInput', 'resolveSigningPrivateKey', 'signMultiversXTransaction'])
    with tempfile.TemporaryDirectory(prefix='n42-multiversx-native-') as temp:
        temp = Path(temp)
        bridge = temp / 'Bridge.swift'
        bridge.write_text('import Foundation\nimport WalletCore\nclass WalletCorePlugin {}\nextension WalletCorePlugin {\n'+methods+'\n}')
        sdk = subprocess.check_output(['xcrun','--sdk','iphonesimulator','--show-sdk-path'],text=True).strip()
        binary = temp / 'native-tests'
        command = ['xcrun','--sdk','iphonesimulator','swiftc','-target','arm64-apple-ios16.0-simulator','-sdk',sdk]
        for pod, module in [('TrustWalletCore','WalletCore'),('WalletCoreSwiftProtobuf','WalletCoreSwiftProtobuf')]:
            directory = ROOT / 'ios/Pods' / pod / (module+'.xcframework') / 'ios-arm64_x86_64-simulator'
            command += ['-F',str(directory),'-Xlinker','-rpath','-Xlinker',str(directory),'-framework',module]
        command += ['-framework','Security','-lc++',str(bridge),str(ROOT/'test/native/multiversx_component_harness.swift'),'-o',str(binary)]
        subprocess.run(command,check=True)
        subprocess.run(['xcrun','simctl','spawn',args.simulator,str(binary)],check=True)

if __name__ == '__main__':
    main()
