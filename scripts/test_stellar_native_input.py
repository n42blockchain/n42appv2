#!/usr/bin/env python3
"""Run the production Swift/Kotlin Stellar wire validators on host fixtures.

Does not execute WalletCore, a MethodChannel, a device, or a network request.
Kotlin compiler artifacts must already exist in the local Gradle cache.
"""
import json
import os
from pathlib import Path
import subprocess
import tempfile
from test_solana_native import declaration

ROOT = Path(__file__).resolve().parents[1]


def vectors():
    good = {'toAddress': 'Gfixture', 'amount': '12500000', 'fee': '100', 'sequence': '8'}
    cases = [('valid minimal', good, True)]
    for field in good:
        bad = dict(good); del bad[field]
        cases.append((f'missing {field}', bad, False))
    for field in ['amount', 'sequence', 'fee']:
        limit = 2147483647 if field == 'fee' else 9223372036854775807
        for value in ['', '0', '-1', '01', '+1', '1.5', str(limit + 1), '1\n', '１', True, 1, 1.5, [], {}]:
            cases.append((f'{field} {value!r}', {**good, field: value}, False))
        cases.append((f'{field} boundary', {**good, field: str(limit)}, True))
    for value in ['', True, [], {}, 1]:
        cases.append((f'recipient {value!r}', {**good, 'toAddress': value}, False))
    for value in ['', 'a' * 28, '中' * 9, '😀' * 7]:
        cases.append((f'valid memo {value!r}', {**good, 'memo': value}, True))
    for value in ['a' * 29, '中' * 10, '😀' * 8, True, 1, [], {}]:
        cases.append((f'invalid memo {value!r}', {**good, 'memo': value}, False))
    for value in ['', True, 1, [], {}]:
        cases.append((f'network {value!r}', {**good, 'passphrase': value}, False))
    cases.append(('custom network', {**good, 'passphrase': 'Custom network'}, True))
    return cases


def kotlin(value):
    if isinstance(value, bool):
        return str(value).lower()
    if isinstance(value, str):
        return json.dumps(value).replace('$', '\\$')
    if isinstance(value, dict):
        return 'mapOf<String, Any>(' + ','.join(
            f'{kotlin(k)} to {kotlin(v)}' for k, v in value.items()) + ')'
    if isinstance(value, list):
        return 'listOf<Any>(' + ','.join(map(kotlin, value)) + ')'
    return str(value) + ('L' if isinstance(value, int) and not -2147483648 <= value <= 2147483647 else '')


def main():
    cases = vectors()
    swift = (ROOT / 'ios/Runner/WalletCorePlugin+Signing.swift').read_text()
    android = (ROOT / 'android/app/src/main/kotlin/ai/n42/www/walletcore/TransactionSignerHandler.kt').read_text()
    for source, marker, guard in [
        (swift, 'func signStellarTransaction(', 'guard validStellarSigningInput(txData)'),
        (android, 'fun signStellarTransaction(', 'if (!validStellarSigningInput(txData))'),
    ]:
        body = declaration(source, marker)
        assert body.index(guard) < body.index('privateKey ='), 'validate before key access/casts'
    with tempfile.TemporaryDirectory(prefix='n42-stellar-input-') as temp:
        temp = Path(temp)
        fixture = temp / 'cases.json'
        fixture.write_text(json.dumps(cases))
        swift_file = temp / 'main.swift'
        swift_file.write_text('import Foundation\nimport CoreFoundation\n' +
            declaration(swift, 'func validStellarSigningInput(').replace('private func', 'func', 1) + '''
let cases = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[Any]]
for item in cases {
    precondition(validStellarSigningInput(item[1] as! [String: Any]) == (item[2] as! Bool), item[0] as! String)
}
print("Swift Stellar input: \\(cases.count) passed")
''')
        binary = temp / 'swift-tests'
        subprocess.run(['xcrun', 'swiftc', str(swift_file), '-o', str(binary)], check=True)
        subprocess.run([str(binary), str(fixture)], check=True)
        cache = Path.home() / '.gradle/caches/modules-2/files-2.1'
        jars = []
        for artifact, version in [
            ('org.jetbrains.kotlin/kotlin-compiler-embeddable', '2.2.10'),
            ('org.jetbrains.kotlin/kotlin-stdlib', '2.2.10'),
            ('org.jetbrains.kotlin/kotlin-script-runtime', '2.2.10'),
            ('org.jetbrains.kotlin/kotlin-reflect', '1.6.10'),
            ('org.jetbrains.kotlinx/kotlinx-coroutines-core-jvm', '1.8.0'),
            ('org.jetbrains/annotations', '13.0'),
        ]:
            matches = list((cache / artifact / version).glob('*/*.jar'))
            if not matches:
                raise SystemExit(f'Missing cached Kotlin test dependency: {artifact} {version}')
            jars.append(str(matches[0]))
        classpath = os.pathsep.join(jars)
        kt_file = temp / 'StellarInput.kt'
        kt_file.write_text(declaration(android, 'fun validStellarSigningInput(') + '\nfun main() {\n' + '\n'.join(
            f'check(validStellarSigningInput({kotlin(data)}) == {kotlin(expected)}) {{ {kotlin(name)} }}'
            for name, data, expected in cases) + f'\nprintln("Kotlin Stellar input: {len(cases)} passed")\n}}\n')
        jar = temp / 'tests.jar'
        subprocess.run(['java', '-cp', classpath, 'org.jetbrains.kotlin.cli.jvm.K2JVMCompiler',
                        '-no-stdlib', '-no-reflect', '-classpath', classpath,
                        '-d', str(jar), str(kt_file)], check=True)
        subprocess.run(['java', '-cp', str(jar) + os.pathsep + classpath, 'StellarInputKt'], check=True)


if __name__ == '__main__':
    main()
