#!/usr/bin/env python3
"""Bind the new package failures to exact prior bytes and selected origins."""

import hashlib
import json
from pathlib import Path


def read(path: Path):
    return json.loads(path.read_text())


root = Path(__file__).resolve().parent
out = root / 'task-16f-owned-build2'
apk_path = out / 'apk-native-inventory.json'
aab_path = out / 'aab-native-inventory.json'
old_path = root / 'task-16f-native-relro-inventory.json'
prior35_path = root / 'task-16c-logs/go-v4-release-apk-native-audit.json'
apk, aab, old, prior35 = map(read, (apk_path, aab_path, old_path, prior35_path))

def require(condition, message):
    if not condition:
        raise SystemExit(message)


def indexed(data):
    result = {(item['abi'], item['name']): item for item in data['libraries']}
    require(len(result) == len(data['libraries']), 'duplicate ABI/library')
    return result


apk_members, aab_members = indexed(apk), indexed(aab)
require(apk_members.keys() == aab_members.keys(), 'APK/AAB native member set differs')
require(all(apk_members[key]['sha256'] == aab_members[key]['sha256'] for key in apk_members),
        'APK/AAB native bytes differ')
require(apk['checked_64bit'] == aab['checked_64bit'] == prior35['libraries_checked'] == 55,
        '64-bit count drift')
current_failed = {item['path'] for item in apk['failed_64bit']}
require(current_failed == {item['path'].replace('base/lib/', 'lib/') for item in aab['failed_64bit']},
        'APK/AAB failure set differs')
prior_failed = set(prior35['unaligned_libraries'])
require(current_failed <= prior_failed, 'new native failure appeared')
require(len(prior_failed) == 35 and len(current_failed) == 30, 'expected bounded count differs')
old_by_path = {item['apk_member']: item for item in old['libraries']}

groups = {
    'libflutter.so': ('Flutter release engine', '3.47.5'),
    'libTrustWalletCore.so': ('Trust Wallet Core', '4.8.4'),
    'libsurface_util_jni.so': ('AndroidX Camera Core', '1.6.1'),
    'libjingle_peerconnection_so.so': ('WebRTC Android', '150.7871.01'),
    'libsqlcipher.so': ('SQLCipher Android', '4.19.0'),
    'libuniffi_yttrium_wcpay.so': ('Reown Yttrium WCPay', '0.10.60'),
    'liblitertlm_jni.so': ('LiteRT-LM', '0.9.0-beta'),
    'libllm_inference_engine_jni.so': ('MediaPipe Tasks GenAI', '0.10.35'),
    'libimagegenerator_gpu.so': ('MediaPipe Vision Image Generator', '0.10.26.1'),
    'libmediapipe_tasks_vision_image_generator_jni.so': ('MediaPipe Vision Image Generator', '0.10.26.1'),
    'libmediapipe_tasks_vision_jni.so': ('MediaPipe Vision Image Generator', '0.10.26.1'),
    'libface_detector_v2_jni.so': ('ML Kit Face Detection', '16.1.7'),
    'libmlkit_google_ocr_pipeline.so': ('ML Kit Text Recognition', '17.0.0'),
    'libtranslate_jni.so': ('ML Kit Translate', '17.0.3'),
    'libbarhopper_v3.so': ('ML Kit Barcode', '17.3.0'),
    'libxeno_native.so': ('ML Kit Mediapipe Internal', '17.0.0-beta10'),
    'libgecko_embedding_model_jni.so': ('Localagents RAG', '0.3.0'),
    'libgemma_embedding_model_jni.so': ('Localagents RAG', '0.3.0'),
    'libsqlite_vector_store_jni.so': ('Localagents RAG', '0.3.0'),
    'libtext_chunker_jni.so': ('Localagents RAG', '0.3.0'),
    'libnoise.so': ('LiveKit Noise', '2.0.0'),
}
failures = []
for item in sorted(apk['failed_64bit'], key=lambda entry: entry['path']):
    old_item = old_by_path.get(item['path'])
    require(old_item is not None and old_item['sha256'] == item['sha256'],
            f'Unverified prior byte identity: {item["path"]}')
    require(not old_item['pass'] and old_item['sources'], f'Prior provenance missing: {item["path"]}')
    group, version = groups[item['name']]
    failures.append({
        'path': item['path'],
        'sha256': item['sha256'],
        'bytes': item['bytes'],
        'group': group,
        'selected_version': version,
        'load_segments': old_item['loads'],
        'gnu_relro': old_item['relro'],
        'origin_candidates_from_identical_prior_bytes': [
            {'archive_basename': Path(source['archive']).name,
             'member': source['member'], 'match': source['match']}
            for source in old_item['sources']
        ],
    })
result = {
    'apk_sha256': apk['sha256'],
    'aab_sha256': aab['sha256'],
    'prior_35_audit_sha256': hashlib.sha256(prior35_path.read_bytes()).hexdigest(),
    'prior_origin_inventory_sha256': hashlib.sha256(old_path.read_bytes()).hexdigest(),
    'native_members_identical': len(apk_members),
    'checked_64bit': 55,
    'prior_failures': 35,
    'current_failures': 30,
    'removed_failures': sorted(prior_failed - current_failed),
    'new_failures': sorted(current_failed - prior_failed),
    'failures': failures,
}
(out / 'remaining-failures.json').write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print('same-native-members', result['native_members_identical'])
print('prior/current', result['prior_failures'], result['current_failures'])
print('removed', *result['removed_failures'], sep='\n  ')
print('new', len(result['new_failures']))
