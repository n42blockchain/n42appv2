import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Expanded textfield support @someone #subjects with highlighting display.
class RichInput extends TextField {
  const RichInput({
    super.key,
    RichInputController? super.controller,
    super.focusNode,
    super.decoration = const InputDecoration(),
    super.keyboardType,
    super.textInputAction,
    super.textCapitalization = TextCapitalization.none,
    super.style,
    super.strutStyle,
    super.textAlign = TextAlign.start,
    super.textAlignVertical,
    super.textDirection,
    super.readOnly = false,
    super.toolbarOptions,
    super.showCursor,
    super.autofocus = false,
    super.obscureText = false,
    super.autocorrect = true,
    super.smartDashesType,
    super.smartQuotesType,
    super.enableSuggestions = true,
    super.maxLines = 1,
    super.minLines,
    super.expands = false,
    super.maxLength,
    bool maxLengthEnforced = true,
    super.onChanged,
    super.onEditingComplete,
    super.onSubmitted,
    super.inputFormatters,
    super.enabled,
    super.cursorWidth = 2.0,
    super.cursorRadius,
    super.cursorColor,
    super.selectionHeightStyle = BoxHeightStyle.tight,
    super.selectionWidthStyle = BoxWidthStyle.tight,
    super.keyboardAppearance,
    super.scrollPadding = const EdgeInsets.all(20),
    super.dragStartBehavior = DragStartBehavior.start,
    super.enableInteractiveSelection = true,
    super.onTap,
    super.buildCounter,
    super.scrollController,
    super.scrollPhysics,
  });
}

/// Expanded from TextEditingController,add insertBlock,insertText method and data property.
class RichInputController extends TextEditingController {
  final List<RichBlock> _blocks = [];
  RegExp? _exp;
  TextEditingValue? _focusValue;

  RichInputController({super.text});

  /// Insert a rich media [RichBlock] in the cursor position
  void insertBlock(RichBlock block) {
    if (_blocks.indexWhere((element) => element.text == block.text) < 0) {
      _blocks.add(block);
      _exp = RegExp(_blocks.map((e) => RegExp.escape(e._key)).join('|'));
    }
    insertText(block._key);
  }

  /// Insert text in the cursor position
  void insertText(String text) {
    TextSelection selection = value.selection;
    if (selection.baseOffset == -1) {
      if (_focusValue != null) {
        selection = _focusValue!.selection;
      } else {
        final String str = this.text + text;
        value = value.copyWith(
          text: str,
          selection: selection.copyWith(
            baseOffset: str.length,
            extentOffset: str.length,
          ),
        );
        return;
      }
    }

    String str = selection.textBefore(this.text);
    str += text;
    str += selection.textAfter(this.text);

    value = value.copyWith(
      text: str,
      selection: selection.copyWith(
        baseOffset: selection.baseOffset + text.length,
        extentOffset: selection.baseOffset + text.length,
      ),
    );
  }

  @override
  void clear() {
    _blocks.clear();
    super.clear();
  }

  @override
  set value(TextEditingValue newValue) {
    super.value = _formatValue(value, newValue);
    if (newValue.selection.baseOffset != -1) {
      _focusValue = newValue;
    } else if (_focusValue != null &&
        _focusValue!.selection.baseOffset > newValue.text.length) {
      _focusValue = null;
    }
  }

  TextEditingValue _formatValue(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue == newValue ||
        newValue.text.length >= oldValue.text.length ||
        newValue.selection.baseOffset == -1) {
      return newValue;
    }
    final oldText = oldValue.text;
    final delLength = oldText.length - newValue.text.length;
    String? char;
    int? offset;
    if (delLength == 1) {
      char = oldText.substring(
          newValue.selection.baseOffset, newValue.selection.baseOffset + 1);
      offset = newValue.selection.baseOffset;
    } else if (delLength == 2) {
      // two characters will be deleted on huawei
      char = oldText.substring(
          newValue.selection.baseOffset + 1, newValue.selection.baseOffset + 2);
      offset = newValue.selection.baseOffset + 1;
    }

    if (_specialChar == char) {
      final newText = newValue.text;
      final oldStr = oldText.substring(0, offset);
      final delStr = "$oldStr{#del#}";
      String str = delStr;
      for (var element in _blocks) {
        str = str.replaceFirst("${element.text}{#del#}", "");
      }
      if (str != delStr && str != oldStr) {
        str += newValue.selection.textInside(newText) +
            newValue.selection.textAfter(newText);

        final len = newText.length - str.length;
        return newValue.copyWith(
          text: str,
          selection: newValue.selection.copyWith(
            baseOffset: newValue.selection.baseOffset - len,
            extentOffset: newValue.selection.baseOffset - len,
          ),
        );
      }
    }
    return newValue;
  }

  /// Get extended data information
  String get data {
    String str = text;
    for (var element in _blocks) {
      str = str.replaceAll(element._key, element.data);
    }
    return str;
  }

  ///Get blocks
  List<RichBlock> get blocks => _blocks;

  clearBlocks() {
    _blocks.clear();
  }



  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
        TextStyle? style,
        required bool withComposing}) {
    if (!value.composing.isValid || !withComposing) {
      return _getTextSpan(text, style);
    }

    final TextStyle? composingStyle = style?.merge(
      const TextStyle(decoration: TextDecoration.underline),
    );
    return TextSpan(
      style: style,
      children: <TextSpan>[
        _getTextSpan(value.composing.textBefore(value.text), style),
        TextSpan(
          style: composingStyle,
          text: value.composing.textInside(value.text),
        ),
        _getTextSpan(value.composing.textAfter(value.text), style),
      ],
    );
  }

  TextSpan _getTextSpan(String text, TextStyle? style) {
    if (_exp == null || text.isEmpty) {
      return TextSpan(style: style, text: text);
    }

    final List<TextSpan> children = [];

    text.splitMapJoin(
      _exp!,
      onMatch: (m) {
        final key = m[0];

        RichBlock? block;
        for (var element in _blocks) {
          if (element._key == key) {
            block = element;
          }
        }

        if (block != null) {
          children.add(
            TextSpan(
              text: key,
              style: block.style,
            ),
          );
        }
        return "$key";
      },
      onNonMatch: (span) {
        if (span != "") {
          children.add(TextSpan(text: span, style: style));
        }
        return span;
      },
    );
    return TextSpan(style: style, children: children);
  }
}

const String _specialChar = "\u200B";
final _filterCharacters = RegExp("[٩|۶]");

/// Rich Media Data Blocks
class RichBlock {
  final String text;
  final String data;
  final TextStyle style;
  final String _key;
  final dynamic value;

  RichBlock({
    required String text,
    required this.data,
    this.style = const TextStyle(color: Colors.blue),
    this.value,
  })  : text = text.replaceAll(_filterCharacters, ""),
        _key = "${text.replaceAll(_filterCharacters, "")}$_specialChar";
}