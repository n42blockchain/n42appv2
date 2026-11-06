#!/usr/bin/env python3
"""Run the production Swift/Kotlin MultiversX wire validators on host fixtures.

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
    good = {'toAddress': 'erd1fixture', 'amount': '1250000000000000000', 'nonce': '0',
            'gasPrice': '1000000000', 'gasLimit': '50000', 'chainId': '1', 'version': '1'}
    cases = [('valid minimal', good, True)]
    for field in good:
        bad = dict(good); del bad[field]
        cases.append((f'missing {field}', bad, False))
    for field in ['amount', 'nonce', 'gasPrice', 'gasLimit', 'version']:
        for value in ['', '-1', '01', '+1', '1.5', '1\n', '１', True, 1, 1.5, [], {}]:
            cases.append((f'{field} {value!r}', {**good, field: value}, False))
        cases.append((f'{field} zero', {**good, field: '0'}, field in ['nonce', 'amount']))
        if field != 'amount':
            limit = 2147483647 if field == 'version' else 9223372036854775807
            cases.append((f'{field} max', {**good, field: str(limit)}, True))
            cases.append((f'{field} overflow', {**good, field: str(limit + 1)}, False))
    cases.append(('amount above int64', {**good, 'amount': '10000000000000000000'}, True))
    for value in ['', True, [], {}, 1]:
        cases.append((f'recipient {value!r}', {**good, 'toAddress': value}, False))
    for value in ['', 'hello', '你好🙂']:
        cases.append((f'data {value!r}', {**good, 'data': value}, True))
    for value in [True, 1, [], {}]:
        cases.append((f'invalid data {value!r}', {**good, 'data': value}, False))
    for value in ['', True, 1, [], {}]:
        cases.append((f'network {value!r}', {**good, 'chainId': value}, False))
    for value in ['T','D','custom-local']:
        cases.append((f'network {value}', {**good, 'chainId': value}, True))
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
        (swift, 'func signMultiversXTransaction(', 'guard validMultiversXSigningInput(txData)'),
        (android, 'fun signMultiversXTransaction(', 'if (!validMultiversXSigningInput(txData))'),
    ]:
        body = declaration(source, marker)
        assert body.index(guard) < body.index('privateKey ='), 'validate before key access/casts'
    with tempfile.TemporaryDirectory(prefix='n42-multiversx-input-') as temp:
        temp = Path(temp)
        fixture = temp / 'cases.json'
        fixture.write_text(json.dumps(cases))
        swift_file = temp / 'main.swift'
        swift_file.write_text('import Foundation\nimport CoreFoundation\n' +
            declaration(swift, 'func validMultiversXSigningInput(').replace('private func', 'func', 1) + '''
let cases = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[Any]]
for item in cases {
    precondition(validMultiversXSigningInput(item[1] as! [String: Any]) == (item[2] as! Bool), item[0] as! String)
}
print("Swift MultiversX input: \\(cases.count) passed")
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
        kt_file = temp / 'MultiversXInput.kt'
        kt_file.write_text(declaration(android, 'fun validMultiversXSigningInput(') + '\nfun main() {\n' + '\n'.join(
            f'check(validMultiversXSigningInput({kotlin(data)}) == {kotlin(expected)}) {{ {kotlin(name)} }}'
            for name, data, expected in cases) + f'\nprintln("Kotlin MultiversX input: {len(cases)} passed")\n}}\n')
        jar = temp / 'tests.jar'
        subprocess.run(['java', '-cp', classpath, 'org.jetbrains.kotlin.cli.jvm.K2JVMCompiler',
                        '-no-stdlib', '-no-reflect', '-classpath', classpath,
                        '-d', str(jar), str(kt_file)], check=True)
        subprocess.run(['java', '-cp', str(jar) + os.pathsep + classpath, 'MultiversXInputKt'], check=True)


if __name__ == '__main__':
    main()
