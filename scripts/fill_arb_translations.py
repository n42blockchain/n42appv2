#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import re
import sys
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable

try:
  from deep_translator import GoogleTranslator
except ImportError as exc:  # pragma: no cover
  raise SystemExit(
      'deep-translator is required. Install it in a virtualenv before running.'
  ) from exc


PLACEHOLDER_RE = re.compile(r'\{[^\{\}\n]+\}')
PROTECTED_LITERAL_PATTERNS = (
    re.compile(r'https?://[^\s]+'),
    re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b'),
    re.compile(r'@[A-Za-z0-9._=-]+:[A-Za-z0-9.-]+\.[A-Za-z]{2,}'),
)
SEPARATOR_TOKEN = '\nZXQSEP0ZXQ\n'
MAX_BATCH_CHARS = 3200
RETRY_LIMIT = 3
RETRY_DELAY_SECONDS = 1.5


@dataclass(frozen=True)
class TargetSpec:
  base_path: Path
  target_path: Path
  translator_lang: str
  locale_code: str


def parse_args() -> argparse.Namespace:
  parser = argparse.ArgumentParser(
      description='Fill missing/English-identical ARB translations in place.'
  )
  parser.add_argument(
      '--root',
      type=Path,
      default=Path.cwd(),
      help='Repository root used to resolve relative paths.',
  )
  parser.add_argument(
      '--mode',
      choices=['wallet', 'chat', 'all'],
      default='all',
      help='Which ARB groups to process.',
  )
  parser.add_argument(
      '--locales',
      nargs='*',
      default=[],
      help='Optional locale filters, e.g. de ar pt_BR.',
  )
  parser.add_argument(
      '--sleep',
      type=float,
      default=0.3,
      help='Delay between translation batches to reduce rate limiting.',
  )
  parser.add_argument(
      '--force',
      action='store_true',
      help='Retranslate all message values in matching locale files.',
  )
  return parser.parse_args()


def main() -> int:
  args = parse_args()
  root = args.root.resolve()
  requested_locales = set(args.locales)

  specs = list(iter_specs(root, args.mode))
  if requested_locales:
    specs = [spec for spec in specs if spec.locale_code in requested_locales]

  if not specs:
    print('No matching locale targets found.', file=sys.stderr)
    return 1

  total_updated = 0
  for spec in specs:
    updated = fill_target(
        spec,
        sleep_seconds=args.sleep,
        force_translate=args.force,
    )
    total_updated += updated

  print(f'Updated {total_updated} translation entries across {len(specs)} files.')
  return 0


def iter_specs(root: Path, mode: str) -> Iterable[TargetSpec]:
  if mode in ('wallet', 'all'):
    wallet_dir = root / 'lib' / 'l10n'
    wallet_base = wallet_dir / 'intl_en.arb'
    for path in sorted(wallet_dir.glob('intl_*.arb')):
      if path == wallet_base:
        continue
      locale = path.stem.replace('intl_', '')
      if locale in {'zh', 'zh_TW'}:
        continue
      yield TargetSpec(
          base_path=wallet_base,
          target_path=path,
          translator_lang=to_translator_lang(locale),
          locale_code=locale,
      )

  if mode in ('chat', 'all'):
    chat_dir = (root / '..' / 'n42_chat' / 'lib' / 'l10n').resolve()
    chat_base = chat_dir / 'app_en.arb'
    for path in sorted(chat_dir.glob('app_*.arb')):
      if path == chat_base or path.name.startswith('app_localizations'):
        continue
      locale = path.stem.replace('app_', '')
      if locale in {'zh', 'zh_TW'}:
        continue
      yield TargetSpec(
          base_path=chat_base,
          target_path=path,
          translator_lang=to_translator_lang(locale),
          locale_code=locale,
      )


def to_translator_lang(locale: str) -> str:
  mapping = {
      'es_ES': 'es',
      'pt_BR': 'pt',
  }
  return mapping.get(locale, locale.replace('_', '-').lower())


def load_json(path: Path) -> dict[str, object]:
  return json.loads(path.read_text(encoding='utf-8'))


def fill_target(
    spec: TargetSpec,
    sleep_seconds: float,
    force_translate: bool,
) -> int:
  base = load_json(spec.base_path)
  target = load_json(spec.target_path)
  base_messages = {
      key: value for key, value in base.items() if not key.startswith('@')
  }
  target_messages = {
      key: value for key, value in target.items() if not key.startswith('@')
  }

  pending_keys = [
      key for key, base_value in base_messages.items()
      if should_translate(
          key,
          base_value,
          target_messages.get(key),
          force_translate=force_translate,
      )
  ]
  skipped_icu = [key for key in pending_keys if is_icu_string(str(base_messages[key]))]
  pending_keys = [key for key in pending_keys if key not in skipped_icu]

  print(
      f'[{spec.locale_code}] {spec.target_path.name}: '
      f'{len(pending_keys)} auto entries, {len(skipped_icu)} ICU entries'
  )

  translator = GoogleTranslator(source='en', target=spec.translator_lang)
  translated_values: dict[str, str] = {}
  if pending_keys:
    for batch_keys in build_batches(base_messages, pending_keys):
      translated_values.update(
          translate_batch(translator, base_messages, batch_keys)
      )
      time.sleep(sleep_seconds)

  if skipped_icu:
    translated_values.update(
        translate_icu_entries(
            translator=translator,
            base_messages=base_messages,
            keys=skipped_icu,
            sleep_seconds=sleep_seconds,
        )
    )

  merged = merge_output(
      base=base,
      target=target,
      translated_values=translated_values,
      locale_code=spec.locale_code,
  )
  spec.target_path.write_text(
      json.dumps(merged, ensure_ascii=False, indent=2) + '\n',
      encoding='utf-8',
  )
  return len(translated_values)


def should_translate(
    key: str,
    base_value: object,
    target_value: object | None,
    *,
    force_translate: bool,
) -> bool:
  if key.startswith('@'):
    return False
  if force_translate:
    return True
  if target_value is None:
    return True
  target_text = str(target_value).strip()
  if not target_text:
    return True
  return target_text == str(base_value)


def is_icu_string(text: str) -> bool:
  return 'plural,' in text or 'select,' in text


def build_batches(
    base_messages: dict[str, object],
    pending_keys: list[str],
) -> Iterable[list[str]]:
  batch: list[str] = []
  current_chars = 0
  for key in pending_keys:
    protected, _ = protect_tokens(str(base_messages[key]))
    addition = len(protected) + len(SEPARATOR_TOKEN)
    if batch and current_chars + addition > MAX_BATCH_CHARS:
      yield batch
      batch = []
      current_chars = 0
    batch.append(key)
    current_chars += addition
  if batch:
    yield batch


def translate_batch(
    translator: GoogleTranslator,
    base_messages: dict[str, object],
    batch_keys: list[str],
) -> dict[str, str]:
  protected_texts: list[str] = []
  replacements_by_key: dict[str, list[tuple[str, str]]] = {}

  for key in batch_keys:
    protected, replacements = protect_tokens(str(base_messages[key]))
    protected_texts.append(protected)
    replacements_by_key[key] = replacements

  translated = translate_with_retry(translator, SEPARATOR_TOKEN.join(protected_texts))
  parts = translated.split('ZXQSEP0ZXQ')
  if len(parts) != len(batch_keys):
    raise RuntimeError(
        f'Batch translation split mismatch for {batch_keys}: got {len(parts)} parts'
    )

  results: dict[str, str] = {}
  for key, part in zip(batch_keys, parts, strict=True):
    restored = restore_tokens(part.strip(), replacements_by_key[key])
    source = str(base_messages[key]).strip()
    if restored.strip() == source and should_retry_same_output(source):
      protected, replacements = protect_tokens(source)
      restored = restore_tokens(
          translate_with_retry(translator, protected).strip(),
          replacements,
      )
    results[key] = restored
  return results


def protect_tokens(text: str) -> tuple[str, list[tuple[str, str]]]:
  replacements: list[tuple[str, str]] = []

  def replace_match(match: re.Match[str]) -> str:
    token = f'ZXQPH{len(replacements)}ZXQ'
    replacements.append((token, match.group(0)))
    return token

  protected = text
  for pattern in PROTECTED_LITERAL_PATTERNS:
    protected = pattern.sub(replace_match, protected)
  protected = PLACEHOLDER_RE.sub(replace_match, protected)
  return protected, replacements


def restore_tokens(text: str, replacements: list[tuple[str, str]]) -> str:
  restored = text
  for token, original in replacements:
    restored = restored.replace(token, original)
  return restored


def translate_with_retry(translator: GoogleTranslator, text: str) -> str:
  last_error: Exception | None = None
  for attempt in range(RETRY_LIMIT):
    try:
      return translator.translate(text)
    except Exception as exc:  # pragma: no cover
      last_error = exc
      time.sleep(RETRY_DELAY_SECONDS * (attempt + 1))
  raise RuntimeError(f'Translation failed after retries: {last_error}')


def should_retry_same_output(source: str) -> bool:
  stripped = source.strip()
  if len(stripped) < 4:
    return False
  if not re.search(r'[a-z]', stripped):
    return False
  technical_prefixes = ('EIP-', 'v0.', 'UUID', 'FDV')
  if stripped.startswith(technical_prefixes):
    return False
  if re.fullmatch(r'[A-Z0-9+_.\- ]+', stripped):
    return False
  return True


def translate_icu_entries(
    translator: GoogleTranslator,
    base_messages: dict[str, object],
    keys: list[str],
    sleep_seconds: float,
) -> dict[str, str]:
  results: dict[str, str] = {}
  for key in keys:
    source = str(base_messages[key])
    match = re.fullmatch(
        r'\{count, plural, =1\{(.+?)\} other\{\{count\} (.+?)\}\} — (.+)',
        source,
    )
    if not match:
      continue
    singular_text, plural_suffix, tail = match.groups()
    singular = restore_tokens(
        translate_with_retry(translator, protect_tokens(singular_text)[0]),
        [],
    )
    plural = restore_tokens(
        translate_with_retry(translator, protect_tokens(f'ZXQPH0ZXQ {plural_suffix}')[0]),
        [('ZXQPH0ZXQ', '{count}')],
    )
    tail_text = translate_with_retry(translator, tail)
    results[key] = (
        '{count, plural, '
        f'=1{{{singular}}} '
        f'other{{{plural}}}'
        f'}} — {tail_text}'
    )
    time.sleep(sleep_seconds)
  return results


def merge_output(
    base: dict[str, object],
    target: dict[str, object],
    translated_values: dict[str, str],
    locale_code: str,
) -> dict[str, object]:
  merged: dict[str, object] = {}
  merged['@@locale'] = target.get('@@locale', locale_code)

  for key, base_value in base.items():
    if key == '@@locale':
      continue

    if key.startswith('@'):
      message_key = key[1:]
      if message_key in translated_values or message_key in target or message_key in base:
        merged[key] = target.get(key, base_value)
      continue

    if key in translated_values:
      merged[key] = translated_values[key]
    elif key in target:
      merged[key] = target[key]
    else:
      merged[key] = base_value

  for key, value in target.items():
    if key not in merged:
      merged[key] = value

  return merged


if __name__ == '__main__':
  raise SystemExit(main())
