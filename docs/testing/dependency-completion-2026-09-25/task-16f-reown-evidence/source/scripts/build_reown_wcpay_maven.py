#!/usr/bin/env python3
"""Stage the pinned WCPay 0.10.60 AAR with only four relinked JNI members."""

import argparse
import copy
from hashlib import md5, sha1, sha256, sha512
import json
from pathlib import Path
import shutil
import xml.etree.ElementTree as ET
from zipfile import ZipFile


ABIS = ('arm64-v8a', 'armeabi-v7a', 'x86', 'x86_64')
MODULE = 'yttrium-wcpay'
VERSION = '0.10.60'
AAR = f'{MODULE}-{VERSION}.aar'
PINNED_OFFICIAL = {
    AAR: '07b139f458f9eda49445649cf2496b020b8664e0b0c9c7ca30c89a06259b75e8',
    f'{MODULE}-{VERSION}.pom': '1092df0f34ecb578abcfef1ab23ec6fe8dee0b99ddbcb2693fadb76c03e126fe',
    f'{MODULE}-{VERSION}.module': 'c82d81c852af42d42cc913a1364733882dddec175fb19c8f1369a9856921cfad',
}
PINNED_CANDIDATE = {
    'arm64-v8a': 'a89f233ea9a99d4cfb7591bc87bc468adae422c118e452524fcacb38467d9bff',
    'armeabi-v7a': '7fe6289eb4717de1896c1d3b24ed1f8c2aa97886903bcc22790db1f8fc003f2b',
    'x86': '2357fb466421faf309042d1cbc11c3b8bef4fb92ee864f1a9272774a08a3332b',
    'x86_64': '36a95b0e288c1dd78f3db0086c51b5bee5a5fe0203fda2ce3c48c79667416bf4',
}
PINNED_SOURCE_MANIFEST = 'ebdbf3a660255fc0a10a5880c570303d6b674b3363af7fc0fff67542d00f8e52'
PINNED_BINDING_COMPARISON = '019a6381210642ea2fc8e49081693f4d45671be13a23eba58e137ffdbe4d03fc'
PINNED_BINDINGS = {
    'yttrium.kt': '92458f5d5dcc13410f27b733b6c8771164a7e392118ca83313928642b64766ad',
    'uniffi_yttrium.kt': '5bf20f4f39126830d1ecc00f43498c079ae06f1fc8dcd5db4141d0c97f168f84',
}


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return sha256(Path(path).read_bytes()).hexdigest()


def verify_pom(pom_bytes):
    root = ET.fromstring(pom_bytes)
    ns = {'m': 'http://maven.apache.org/POM/4.0.0'}
    dependencies = root.findall('m:dependencies/m:dependency', ns)
    jna = [item for item in dependencies
           if item.findtext('m:groupId', namespaces=ns) == 'net.java.dev.jna'
           and item.findtext('m:artifactId', namespaces=ns) == 'jna']
    require(len(jna) == 1, 'POM must retain exactly one JNA dependency')
    entry = jna[0]
    require(entry.findtext('m:version', namespaces=ns) == '5.17.0'
            and entry.findtext('m:type', namespaces=ns) == 'aar'
            and entry.findtext('m:classifier', namespaces=ns) == 'android',
            'POM JNA Android 5.17.0 dependency changed')
    return len(dependencies)


def verify_module_metadata(metadata, official_aar):
    variants = metadata.get('variants', [])
    expected = {'releaseVariantReleaseApiPublication',
                'releaseVariantReleaseRuntimePublication'}
    require({item.get('name') for item in variants} == expected,
            'unexpected WCPay variants')
    for variant in variants:
        files = [item for item in variant.get('files', []) if item.get('name') == AAR]
        require(len(files) == 1 and files[0].get('url') == AAR,
                'missing or duplicate module AAR entry')
        require(files[0].get('size') == official_aar.stat().st_size and
                files[0].get('sha256') == digest(official_aar),
                'official module AAR hash mismatch')
        jna = [item for item in variant.get('dependencies', [])
               if item.get('group') == 'net.java.dev.jna'
               and item.get('module') == 'jna']
        require(len(jna) == 1 and jna[0].get('version', {}).get('requires') == '5.17.0',
                f'JNA dependency missing in {variant.get("name")}')


def repackage_aar(official, candidate_dir, destination):
    official, candidate_dir, destination = map(Path, (official, candidate_dir, destination))
    require(official.resolve() != destination.resolve(), 'cannot overwrite official AAR')
    replacement = {}
    for abi in ABIS:
        path = candidate_dir / 'libs' / abi / 'libuniffi_yttrium_wcpay.so'
        require(path.is_file() and not path.is_symlink(), f'missing candidate: {abi}')
        require(digest(path) == PINNED_CANDIDATE[abi], f'candidate hash mismatch: {abi}')
        replacement[f'jni/{abi}/libuniffi_yttrium_wcpay.so'] = path.read_bytes()
    destination.parent.mkdir(parents=True, exist_ok=True)
    with ZipFile(official) as baseline, ZipFile(destination, 'w') as maintained:
        names = baseline.namelist()
        require(len(names) == len(set(names)), 'duplicate official ZIP member')
        require({name for name in names if name.endswith('.so')} == set(replacement),
                'official native member set differs')
        for entry in baseline.infolist():
            maintained.writestr(entry, replacement.get(entry.filename, baseline.read(entry)))
    with ZipFile(official) as baseline, ZipFile(destination) as maintained:
        require(baseline.namelist() == maintained.namelist(), 'ZIP member list changed')
        for name in baseline.namelist():
            old, new = baseline.read(name), maintained.read(name)
            if name in replacement:
                require(new == replacement[name] and new != old,
                        f'candidate member mismatch or unchanged: {name}')
            else:
                require(new == old, f'unrelated AAR member changed: {name}')
    return {'changed_members': list(replacement),
            'total_members': len(names),
            'official_sha256': digest(official),
            'maintained_sha256': digest(destination)}


def rewrite_module_metadata(original, maintained_aar):
    result = copy.deepcopy(original)
    data = Path(maintained_aar).read_bytes()
    changed = []
    for variant in result['variants']:
        entry = next(item for item in variant['files'] if item['name'] == AAR)
        entry.update({'size': len(data), 'sha512': sha512(data).hexdigest(),
                      'sha256': sha256(data).hexdigest(),
                      'sha1': sha1(data).hexdigest(), 'md5': md5(data).hexdigest()})
        changed.append(variant['name'])
    require(set(changed) == {'releaseVariantReleaseApiPublication',
                             'releaseVariantReleaseRuntimePublication'},
            'missing AAR variant')
    return result


def verify_candidate_evidence(candidate_dir):
    source_manifest = candidate_dir / 'manifest.json'
    comparison = candidate_dir / 'corrected-binding-comparison.json'
    require(digest(source_manifest) == PINNED_SOURCE_MANIFEST,
            'candidate source manifest mismatch')
    require(digest(comparison) == PINNED_BINDING_COMPARISON,
            'corrected binding comparison mismatch')
    source = json.loads(source_manifest.read_text())
    require(source.get('source_commit') == 'fc2dc73ae1e1af2b29363c6d239c0e3a19ec8f7c',
            'candidate source commit mismatch')
    require(set(item['abi'] for item in source['targets'].values()) == set(ABIS),
            'candidate ABI set mismatch')
    for item in source['targets'].values():
        require(item['stripped_sha256'] == PINNED_CANDIDATE[item['abi']],
                f'candidate manifest hash mismatch: {item["abi"]}')
    bindings = json.loads(comparison.read_text())
    require(set(bindings) == set(PINNED_BINDINGS), 'binding file set mismatch')
    for name, expected in PINNED_BINDINGS.items():
        entry = bindings[name]
        require(entry.get('byte_equal') is True and
                entry.get('candidate_sha256') == expected and
                entry.get('release_sha256') == expected,
                f'official binding mismatch: {name}')
        matches = list((candidate_dir / 'bindings-corrected').rglob(name))
        require(len(matches) == 1 and digest(matches[0]) == expected,
                f'corrected binding bytes mismatch: {name}')


def build_repo(official_dir, candidate_dir, output_root):
    official_dir, candidate_dir, output_root = map(Path, (official_dir, candidate_dir, output_root))
    verify_candidate_evidence(candidate_dir)
    for name, expected in PINNED_OFFICIAL.items():
        path = official_dir / name
        require(path.is_file() and not path.is_symlink() and digest(path) == expected,
                f'official artifact mismatch: {name}')
    official_aar = official_dir / AAR
    pom = official_dir / f'{MODULE}-{VERSION}.pom'
    metadata = json.loads((official_dir / f'{MODULE}-{VERSION}.module').read_text())
    pom_dependencies = verify_pom(pom.read_bytes())
    verify_module_metadata(metadata, official_aar)
    destination = output_root / 'com/github/reown-com/yttrium' / MODULE / VERSION
    require(not destination.exists(), f'output already exists: {destination}')
    destination.mkdir(parents=True)
    report = repackage_aar(official_aar, candidate_dir, destination / AAR)
    updated = rewrite_module_metadata(metadata, destination / AAR)
    (destination / f'{MODULE}-{VERSION}.module').write_text(json.dumps(updated, indent=2) + '\n')
    shutil.copyfile(pom, destination / pom.name)
    report['output_files'] = {path.name: digest(path) for path in sorted(destination.iterdir())}
    report['pom_dependencies'] = pom_dependencies
    report['api_dependencies'] = len(updated['variants'][0]['dependencies'])
    report['runtime_dependencies'] = len(updated['variants'][1]['dependencies'])
    report['candidate_manifest_sha256'] = digest(candidate_dir / 'manifest.json')
    report['binding_comparison_sha256'] = digest(candidate_dir / 'corrected-binding-comparison.json')
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--official-dir', required=True, type=Path)
    parser.add_argument('--candidate-dir', required=True, type=Path)
    parser.add_argument('--output-root', required=True, type=Path)
    args = parser.parse_args()
    print(json.dumps(build_repo(args.official_dir, args.candidate_dir,
                                args.output_root), indent=2))


if __name__ == '__main__':
    main()
