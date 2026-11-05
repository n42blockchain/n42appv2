#!/usr/bin/env python3
"""Run actual Solana Swift bridge methods with WalletCore on a booted simulator.

This isolates native signing from the app's Flutter/MLKit architecture settings.
It does not prove a full Runner build, Flutter-channel dispatch or device QA.
Requires simulator WalletCore/WalletCoreSwiftProtobuf frameworks from CocoaPods.
"""
import argparse
from pathlib import Path
import re
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def declaration(source, marker):
    start = source.index(marker)
    start = source.rfind('\n', 0, start) + 1
    # Ignore comments and strings while matching structural braces. Preserve
    # positions so the emitted methods are exact current production source.
    pattern = r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"'
    masked = re.sub(pattern, lambda m: ' ' * len(m[0]), source, flags=re.S)
    opening = masked.index('{', start)
    depth = 1
    end = opening + 1
    while depth:
        depth += (masked[end] == '{') - (masked[end] == '}')
        end += 1
    return source[start:end]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--simulator', required=True, help='Booted test simulator UDID')
    args = parser.parse_args()
    source = (ROOT / 'ios/Runner/WalletCorePlugin+Signing.swift').read_text()
    names = ['resolveSigningPrivateKey', 'signSolanaTransaction',
             'signWalletConnectSolana', 'solanaSignatureEnvelope']
    methods = '\n'.join(declaration(source, 'func ' + name + '(') for name in names)
    tests = declaration((ROOT / 'ios/RunnerTests/RunnerTests.swift').read_text(),
                        'final class SolanaRawSigningTests:')
    tests = tests.replace(': XCTestCase {', '{', 1)
    expected = {'testLegacyAndV0PreserveMessageAndOtherSignatures',
                'testNonSignerAndMalformedInputsReturnNil',
                'testOrdinarySolAndSplTransfersRemainUsable'}
    if set(re.findall(r'func (test\w+)\(', tests)) != expected:
        raise SystemExit('Update component harness to run the changed XCTest inventory')
    # Official 4.8.7 bundles Swift and C APIs in a single binary framework.
    # Prefer the installed binaries; never silently test cached older products.
    frameworks = []
    modules = ['WalletCore', 'WalletCoreSwiftProtobuf']
    for pod, module in [('TrustWalletCore', 'WalletCore'),
                        ('WalletCoreSwiftProtobuf', 'WalletCoreSwiftProtobuf')]:
        directory = ROOT / 'ios/Pods' / pod / (module + '.xcframework') / 'ios-arm64_x86_64-simulator'
        if not (directory / (module + '.framework')).exists():
            raise SystemExit(f'Missing installed simulator framework: {directory}; run pod install first')
        frameworks.append(directory)
    sdk = subprocess.check_output(['xcrun', '--sdk', 'iphonesimulator', '--show-sdk-path'], text=True).strip()
    with tempfile.TemporaryDirectory(prefix='n42-solana-native-') as temp:
        temp = Path(temp)
        bridge = temp / 'Bridge.swift'
        bridge.write_text('import Foundation\nimport WalletCore\nclass WalletCorePlugin {}\nextension WalletCorePlugin {\n' + methods + '\n}\n')
        runner = temp / 'Runner.swift'
        runner.write_text('import Foundation\nimport WalletCore\nimport CryptoKit\n' + tests + '\n' +
                          (ROOT / 'test/native/wallet_core_upgrade_checks.swift').read_text() + '\n' +
                          (ROOT / 'test/native/solana_component_harness.swift').read_text())
        binary = temp / 'native-tests'
        command = ['xcrun', '--sdk', 'iphonesimulator', 'swiftc', '-target', 'arm64-apple-ios16.0-simulator', '-sdk', sdk]
        for directory in frameworks:
            command += ['-F', str(directory), '-Xlinker', '-rpath', '-Xlinker', str(directory)]
        for module in [*modules, 'Security']:
            command += ['-framework', module]
        command += ['-lc++', str(bridge), str(runner), '-o', str(binary)]
        subprocess.run(command, check=True)
        subprocess.run(['xcrun', 'simctl', 'spawn', args.simulator, str(binary)], check=True)


if __name__ == '__main__':
    main()
