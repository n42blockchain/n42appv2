#!/usr/bin/env python3
"""Run the production Swift/Kotlin Near wire validators on host fixtures.

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
    good = {'signerId': 'alice.near', 'receiverId': 'bob.near', 'nonce': '4',
            'blockHash': '02' * 32, 'amount': '01' + '00' * 15}
    cases = [('valid', good, True)]
    for field in good:
        bad = dict(good); del bad[field]
        cases.append((f'missing {field}', bad, False))
        for value in [True, 1, 1.5, [], {}, '']:
            cases.append((f'{field} type {value!r}', {**good, field: value}, False))
    for value in ['0', '-1', '+1', '01', '1.0', '１', '1\n', '9223372036854775808']:
        cases.append((f'bad nonce {value!r}', {**good, 'nonce': value}, False))
    for value in ['1', '9223372036854775807']:
        cases.append((f'nonce {value}', {**good, 'nonce': value}, True))
    for field in ['signerId', 'receiverId']:
        for value in ['a', 'A.near', '-alice', 'alice-', 'alice..near', 'alice_-near', 'a' * 65, 'alice.near\n', 'alice.near\r', 'alice.near\u2028', 'alice.near\u0085', '😀', 'alice near', 'alice/near']:
            cases.append((f'bad {field} {value!r}', {**good, field: value}, False))
        for value in ['aa', 'a' * 64, 'alice.testnet', 'a-b_c.near']:
            cases.append((f'valid {field} {value}', {**good, field: value}, True))
    for field, size in [('blockHash', 32), ('amount', 16)]:
        for value in ['00' * (size - 1), '00' * (size + 1), '0x' + '00' * size, 'gg' * size, '１' * (size * 2)]:
            cases.append((f'bad {field} {value!r}', {**good, field: value}, False))
        for value in ['00' * size, 'FF' * size]:
            cases.append((f'valid {field}', {**good, field: value}, True))
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
        (swift, 'func signNearTransaction(', 'guard validNearSigningInput(txData)'),
        (android, 'fun signNearTransaction(', 'if (!validNearSigningInput(txData))'),
    ]:
        body = declaration(source, marker)
        assert body.index(guard) < body.index('privateKey ='), 'validate before key access/casts'
    with tempfile.TemporaryDirectory(prefix='n42-near-input-') as temp:
        temp = Path(temp)
        fixture = temp / 'cases.json'
        fixture.write_text(json.dumps(cases))
        swift_file = temp / 'main.swift'
        swift_file.write_text('import Foundation\nimport CoreFoundation\n' +
            declaration(swift, 'func validNearSigningInput(').replace('private func', 'func', 1) + '''
let cases = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[Any]]
for item in cases {
    precondition(validNearSigningInput(item[1] as! [String: Any]) == (item[2] as! Bool), item[0] as! String)
}
print("Swift Near input: \\(cases.count) passed")
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
        kt_file = temp / 'NearInput.kt'
        kt_file.write_text(declaration(android, 'fun validNearSigningInput(') + '\nfun main() {\n' + '\n'.join(
            f'check(validNearSigningInput({kotlin(data)}) == {kotlin(expected)}) {{ {kotlin(name)} }}'
            for name, data, expected in cases) + f'\nprintln("Kotlin Near input: {len(cases)} passed")\n}}\n')
        jar = temp / 'tests.jar'
        subprocess.run(['java', '-cp', classpath, 'org.jetbrains.kotlin.cli.jvm.K2JVMCompiler',
                        '-no-stdlib', '-no-reflect', '-classpath', classpath,
                        '-d', str(jar), str(kt_file)], check=True)
        subprocess.run(['java', '-cp', str(jar) + os.pathsep + classpath, 'NearInputKt'], check=True)


if __name__ == '__main__':
    main()
