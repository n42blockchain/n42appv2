#!/usr/bin/env node
/*
 * i18n ARB 批量注入脚本（可复用）。
 *
 * 用法: node scripts/i18n/inject_arb.js scripts/i18n/<batch>.json
 *
 * batch JSON 结构:
 *   { "g_key_name": { "en": "...", "zh_TW": "...", "ja": "...", ... }, ... }
 *
 * - 对每个 lib/l10n/intl_<lang>.arb，把每个 key 的对应语言译文追加到文件末尾。
 * - 缺失语言回退 en。
 * - 含占位符 {x} 的 key，仅在 intl_en.arb 追加 @key metadata（intl_utils 据此生成带参方法）。
 * - 已存在的 key 跳过（幂等，可重复运行）。
 * - 纯文本 append（仅动末尾），保持既有内容 diff 最小。
 */
const fs = require('fs');
const path = require('path');

const L10N_DIR = path.join(__dirname, '..', '..', 'lib', 'l10n');
const LANGS = fs
  .readdirSync(L10N_DIR)
  .filter((f) => /^intl_.*\.arb$/.test(f))
  .map((f) => f.replace(/^intl_/, '').replace(/\.arb$/, ''));

const batchPath = process.argv[2];
if (!batchPath) {
  console.error('usage: node inject_arb.js <batch.json>');
  process.exit(1);
}
const trans = JSON.parse(fs.readFileSync(batchPath, 'utf8'));
const keys = Object.keys(trans);

function placeholders(str) {
  const set = new Set();
  for (const m of str.matchAll(/\{(\w+)\}/g)) set.add(m[1]);
  return [...set];
}

let totalAdded = 0;
for (const lang of LANGS) {
  const file = path.join(L10N_DIR, `intl_${lang}.arb`);
  let txt = fs.readFileSync(file, 'utf8').replace(/﻿/, '');
  const existing = JSON.parse(txt); // validate + detect existing keys
  const toAdd = keys.filter((k) => !(k in existing));
  if (toAdd.length === 0) continue;

  let body = txt.replace(/\s*\}\s*$/, ''); // drop trailing }
  if (!body.trimEnd().endsWith(',')) body = body.trimEnd() + ',';

  const lines = [];
  for (const key of toAdd) {
    const en = trans[key].en;
    const val = trans[key][lang] != null ? trans[key][lang] : en;
    lines.push(`  ${JSON.stringify(key)}: ${JSON.stringify(val)},`);
    if (lang === 'en') {
      const phs = placeholders(en);
      if (phs.length) {
        const meta = { placeholders: Object.fromEntries(phs.map((p) => [p, {}])) };
        lines.push(`  ${JSON.stringify('@' + key)}: ${JSON.stringify(meta)},`);
      }
    }
  }
  let block = lines.join('\n').replace(/,\s*$/, '');
  fs.writeFileSync(file, `${body.trimEnd()}\n${block}\n}\n`);
  totalAdded += toAdd.length;
  console.log(`  intl_${lang}.arb  +${toAdd.length}`);
}
console.log(`done: ${keys.length} keys across ${LANGS.length} locales (+${totalAdded} entries)`);
