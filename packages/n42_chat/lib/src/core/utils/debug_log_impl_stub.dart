import 'dart:io';

void debugLog(String message) {
  assert(() {
    stderr.writeln(message);
    return true;
  }());
}
