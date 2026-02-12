/// JavaScript string escape utilities for WebView injection safety.
///
/// All dynamic values inserted into JavaScript code via
/// `WebViewController.runJavaScript()` MUST be escaped using [escapeJs]
/// to prevent XSS / code injection attacks.
class JsEscapeUtils {
  JsEscapeUtils._();

  /// Escapes a string for safe insertion into a JavaScript string literal.
  ///
  /// Handles: backslash, single/double quotes, newlines, carriage returns,
  /// line/paragraph separators, and null bytes.
  ///
  /// Usage:
  /// ```dart
  /// final safe = JsEscapeUtils.escapeJs(userInput);
  /// controller.runJavaScript('doSomething("$safe");');
  /// ```
  static String escapeJs(String value) {
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      final ch = value[i];
      switch (ch) {
        case '\\':
          buffer.write('\\\\');
        case '"':
          buffer.write('\\"');
        case "'":
          buffer.write("\\'");
        case '\n':
          buffer.write('\\n');
        case '\r':
          buffer.write('\\r');
        case '\t':
          buffer.write('\\t');
        case '\u0000':
          buffer.write('\\0');
        case '\u2028': // Line separator
          buffer.write('\\u2028');
        case '\u2029': // Paragraph separator
          buffer.write('\\u2029');
        default:
          buffer.write(ch);
      }
    }
    return buffer.toString();
  }
}
