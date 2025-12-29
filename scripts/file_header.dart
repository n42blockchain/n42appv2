// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei
// Repository: https://github.com/AmazWallet/n42appv2

/// Batch File Header Insertion Script
///
/// Usage:
///   dart run scripts/file_header.dart
///   dart run scripts/file_header.dart --dry-run
///   dart run scripts/file_header.dart --path=lib/features
///
/// This script adds standardized copyright headers to all Dart files.

import 'dart:io';

/// The standard file header to be inserted
const String fileHeader = '''
// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

''';

/// Patterns to skip (generated files, etc.)
final List<RegExp> skipPatterns = [
  RegExp(r'\.g\.dart$'),
  RegExp(r'\.freezed\.dart$'),
  RegExp(r'\.gr\.dart$'),
  RegExp(r'\.pb\.dart$'),
  RegExp(r'\.pbenum\.dart$'),
  RegExp(r'\.pbjson\.dart$'),
  RegExp(r'\.pbserver\.dart$'),
  RegExp(r'generated[/\\]'),
  RegExp(r'\.dart_tool[/\\]'),
];

/// Check if file should be skipped
bool shouldSkip(String path) {
  for (final pattern in skipPatterns) {
    if (pattern.hasMatch(path)) {
      return true;
    }
  }
  return false;
}

/// Check if file already has the header
bool hasHeader(String content) {
  return content.startsWith('// Copyright 2021-2026 N42 Inc.');
}

/// Process a single Dart file
Future<bool> processFile(File file, {bool dryRun = false}) async {
  final path = file.path;
  
  if (shouldSkip(path)) {
    return false;
  }
  
  final content = await file.readAsString();
  
  if (hasHeader(content)) {
    return false;
  }
  
  // Remove any existing copyright headers (common patterns)
  String cleanedContent = content;
  
  // Remove old headers if they exist
  final oldHeaderPatterns = [
    RegExp(r'^// Copyright.*?\n(?:// .*?\n)*\n?', multiLine: true),
    RegExp(r'^/\*\*?\s*\n(?:\s*\*.*?\n)*\s*\*/\s*\n', multiLine: true),
  ];
  
  for (final pattern in oldHeaderPatterns) {
    if (pattern.hasMatch(cleanedContent)) {
      cleanedContent = cleanedContent.replaceFirst(pattern, '');
    }
  }
  
  // Add new header
  final newContent = fileHeader + cleanedContent.trimLeft();
  
  if (!dryRun) {
    await file.writeAsString(newContent);
  }
  
  return true;
}

/// Main entry point
Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  String targetPath = 'lib';
  
  // Parse --path argument
  for (final arg in args) {
    if (arg.startsWith('--path=')) {
      targetPath = arg.substring(7);
    }
  }
  
  print('File Header Insertion Script');
  print('============================');
  print('Target: $targetPath');
  print('Dry run: $dryRun');
  print('');
  
  final directory = Directory(targetPath);
  if (!await directory.exists()) {
    print('Error: Directory not found: $targetPath');
    exit(1);
  }
  
  int processed = 0;
  int skipped = 0;
  int alreadyHasHeader = 0;
  
  await for (final entity in directory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final result = await processFile(entity, dryRun: dryRun);
      if (result) {
        processed++;
        print('${dryRun ? "[DRY] " : ""}Updated: ${entity.path}');
      } else if (shouldSkip(entity.path)) {
        skipped++;
      } else {
        alreadyHasHeader++;
      }
    }
  }
  
  print('');
  print('Summary:');
  print('  Processed: $processed');
  print('  Skipped (generated): $skipped');
  print('  Already has header: $alreadyHasHeader');
  
  if (dryRun) {
    print('');
    print('This was a dry run. No files were modified.');
    print('Remove --dry-run to apply changes.');
  }
}

