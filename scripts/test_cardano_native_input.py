#!/usr/bin/env python3
"""Run the production Swift/Kotlin Cardano wire validators on host fixtures.

Does not execute WalletCore, a MethodChannel, a device, or a network request.
Kotlin compiler artifacts must already exist in the local Gradle cache.
"""
import copy
import json
import os
from pathlib import Path
import subprocess
import tempfile
from test_solana_native import declaration

ROOT = Path(__file__).resolve().parents[1]


def vectors():
    good = {'toAddress': 'addr_fixture', 'amount': '1000000', 'ttl': '123456',
            'utxos': [{'txHash': 'ab' * 32, 'outputIndex': 0,
                       'amount': '2000000', 'address': 'addr_owner'}]}
    cases = [('valid', good, True)]
    for field in good:
        bad = copy.deepcopy(good)
        del bad[field]
        cases.append((f'missing {field}', bad, False))
    for value in ['', True, [], {}, 1]:
        bad = copy.deepcopy(good)
        bad['toAddress'] = value
        cases.append((f'recipient {value!r}', bad, False))
    for field in ['amount', 'ttl']:
        for value in ['', '0', '-1', '01', '+1', '1.5', '9223372036854775808',
                      '1\n', True, 1, 1.5, [], {}]:
            bad = copy.deepcopy(good)
            bad[field] = value
            cases.append((f'{field} {value!r}', bad, False))
    for field, values in {
        'txHash': ['', 'ab', 'gg' * 32, '0x' + 'ab' * 32, True],
        'outputIndex': [-1, 4294967296, True, 1.0, 1.5, '1'],
        'amount': ['', '0', '-1', '01', '9223372036854775808', [], True],
        'address': ['', True, []],
    }.items():
        for value in values:
            bad = copy.deepcopy(good)
            bad['utxos'][0][field] = value
            cases.append((f'utxo {field} {value!r}', bad, False))
        bad = copy.deepcopy(good)
        del bad['utxos'][0][field]
        cases.append((f'utxo missing {field}', bad, False))
    for value in [[], {}, ['bad'], [True]]:
        bad = copy.deepcopy(good)
        bad['utxos'] = value
        cases.append((f'utxos {value!r}', bad, False))
    bad = copy.deepcopy(good)
    bad['utxos'].append(copy.deepcopy(bad['utxos'][0]))
    bad['utxos'][1]['txHash'] = 'AB' * 32
    cases.append(('duplicate case-insensitive outpoint', bad, False))
    boundary = copy.deepcopy(good)
    boundary['amount'] = boundary['ttl'] = '9223372036854775807'
    boundary['utxos'][0]['outputIndex'] = 4294967295
    cases.append(('integer boundaries', boundary, True))
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
        (swift, 'func signCardanoTransaction(', 'guard validCardanoSigningInput(txData)'),
        (android, 'fun signCardanoTransaction(', 'if (!validCardanoSigningInput(txData))'),
    ]:
        body = declaration(source, marker)
        assert body.index(guard) < body.index('privateKey ='), 'validate before key access/casts'
    with tempfile.TemporaryDirectory(prefix='n42-cardano-input-') as temp:
        temp = Path(temp)
        fixture = temp / 'cases.json'
        fixture.write_text(json.dumps(cases))
        swift_file = temp / 'main.swift'
        swift_file.write_text('import Foundation\nimport CoreFoundation\n' +
            declaration(swift, 'func validCardanoSigningInput(').replace('private func', 'func', 1) + '''
let cases = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: CommandLine.arguments[1]))) as! [[Any]]
for item in cases {
    precondition(validCardanoSigningInput(item[1] as! [String: Any]) == (item[2] as! Bool), item[0] as! String)
}
print("Swift Cardano input: \\(cases.count) passed")
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
        kt_file = temp / 'CardanoInput.kt'
        kt_file.write_text(declaration(android, 'fun validCardanoSigningInput(') + '\nfun main() {\n' + '\n'.join(
            f'check(validCardanoSigningInput({kotlin(data)}) == {kotlin(expected)}) {{ {kotlin(name)} }}'
            for name, data, expected in cases) + f'\nprintln("Kotlin Cardano input: {len(cases)} passed")\n}}\n')
        jar = temp / 'tests.jar'
        subprocess.run(['java', '-cp', classpath, 'org.jetbrains.kotlin.cli.jvm.K2JVMCompiler',
                        '-no-stdlib', '-no-reflect', '-classpath', classpath,
                        '-d', str(jar), str(kt_file)], check=True)
        subprocess.run(['java', '-cp', str(jar) + os.pathsep + classpath, 'CardanoInputKt'], check=True)


if __name__ == '__main__':
    main()
