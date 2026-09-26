// Run with: dart run scripts/audit_ui_literals.dart [output.json]
// Uses the analyzer supplied by the repository's build_runner tooling.
// Reports literal arguments at UI sinks, including interpolation and domain labels.
// Review candidates before counting them as untranslated: brands, numeric data,
// protocol messages and already-localized interpolation are intentionally included.
import 'dart:io';
import 'dart:convert';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';

class Audit extends RecursiveAstVisitor<void> {
  final String file;
  final List<Map<String, Object>> results;
  final LineInfo lineInfo;
  Audit(this.file, this.results, this.lineInfo);
  @override
  void visitArgumentList(ArgumentList node) {
    final parent = node.parent;
    final source = parent.toString();
    for (final arg in node.arguments) {
      final expression = arg.argumentExpression;
      final label = arg is NamedArgument ? arg.name.lexeme : '';
      final knownLabel = [
        'label',
        'hintText',
        'title',
        'subtitle',
        'message',
        'tooltip',
        'semanticLabel',
        'errorText',
        'text',
      ].contains(label);
      final knownCall = RegExp(
        r'^(?:const )?(?:Text\(|TextSpan\(|_label\(|_showSnack\(|ToastUtils\.show\(|showToast\()',
      ).hasMatch(source);
      if (!knownLabel && !knownCall) {
        continue;
      }
      final literal = expression is StringLiteral ? expression.toSource() : '';
      if (literal.isEmpty ||
          !RegExp(r'[A-Za-z\u4e00-\u9fff]{2}').hasMatch(literal)) {
        continue;
      }
      results.add({
        'file': file,
        'line': lineInfo.getLocation(expression.offset).lineNumber,
        'text': literal,
      });
    }
    super.visitArgumentList(node);
  }
}

void main(List<String> args) {
  final results = <Map<String, Object>>[];
  for (final file in Directory(
    'lib',
  ).listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.dart') ||
        file.path.contains('/generated/') ||
        file.path.endsWith('.g.dart') ||
        file.path.endsWith('.freezed.dart')) {
      continue;
    }
    final unit = parseString(
      content: file.readAsStringSync(),
      throwIfDiagnostics: false,
    );
    unit.unit.accept(Audit(file.path, results, unit.lineInfo));
  }
  results.sort((a, b) {
    final byFile = (a['file']! as String).compareTo(b['file']! as String);
    return byFile != 0
        ? byFile
        : (a['line']! as int).compareTo(b['line']! as int);
  });
  File(args.isEmpty ? 'build/ui-literal-inventory.json' : args.first)
    ..parent.createSync(recursive: true)
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(results));
  print('${results.length} UI literal candidates');
}
