import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';

/// One adjustable accessibility control; compact labels remain a drag target.
class ContactIndexBar extends StatefulWidget {
  final List<String> letters;
  final ValueChanged<String> onLetterTap;
  const ContactIndexBar({
    super.key,
    required this.letters,
    required this.onLetterTap,
  });
  @override
  State<ContactIndexBar> createState() => _ContactIndexBarState();
}

class _ContactIndexBarState extends State<ContactIndexBar> {
  int _selected = 0;
  bool _dragging = false;

  void _select(int index) {
    if (widget.letters.isEmpty) return;
    final next = index.clamp(0, widget.letters.length - 1);
    setState(() => _selected = next);
    widget.onLetterTap(widget.letters[next]);
  }

  String _label(String letter) => letter == '🔍'
      ? S.of(context)!.commonSearch
      : letter == '☆'
      ? S.of(context)!.contactStarredFriends
      : letter;

  @override
  Widget build(BuildContext context) {
    if (widget.letters.isEmpty) return const SizedBox.shrink();
    final index = _selected.clamp(0, widget.letters.length - 1);
    final primary = Theme.of(context).colorScheme.primary;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxHeight <
                widget.letters.length * AppDimensions.spacing
            ? 2
            : 1;
        final rows = (widget.letters.length / columns).ceil();
        final height = math.min(
          constraints.maxHeight,
          rows * AppDimensions.spacing,
        );
        void selectAt(Offset position) {
          if (height <= 0 || constraints.maxWidth <= 0) return;
          final column = (position.dx / (constraints.maxWidth / columns))
              .floor()
              .clamp(0, columns - 1);
          final row = (position.dy / (height / rows)).floor().clamp(
            0,
            rows - 1,
          );
          final next = column * rows + row;
          if (next < widget.letters.length) _select(next);
        }

        return Center(
          child: SizedBox(
            height: height,
            child: Semantics(
              label: S.of(context)!.contactIndexLabel,
              value: _label(widget.letters[index]),
              increasedValue: index < widget.letters.length - 1
                  ? _label(widget.letters[index + 1])
                  : null,
              decreasedValue: index > 0
                  ? _label(widget.letters[index - 1])
                  : null,
              onIncrease: index < widget.letters.length - 1
                  ? () => _select(index + 1)
                  : null,
              onDecrease: index > 0 ? () => _select(index - 1) : null,
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (event) => selectAt(event.localPosition),
                onVerticalDragStart: (event) {
                  setState(() => _dragging = true);
                  selectAt(event.localPosition);
                },
                onVerticalDragUpdate: (event) => selectAt(event.localPosition),
                onVerticalDragEnd: (_) => setState(() => _dragging = false),
                onVerticalDragCancel: () => setState(() => _dragging = false),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Row(
                      children: List.generate(
                        columns,
                        (column) => Expanded(
                          child: Column(
                            children: List.generate(rows, (row) {
                              final n = column * rows + row;
                              if (n >= widget.letters.length)
                                return const Expanded(child: SizedBox());
                              return Expanded(
                                child: Center(
                                  child:
                                      widget.letters[n] == '🔍' ||
                                          widget.letters[n] == '☆'
                                      ? Icon(
                                          widget.letters[n] == '🔍'
                                              ? Icons.search
                                              : Icons.star_outline,
                                          size: 14,
                                          color: n == index
                                              ? primary
                                              : context.textSupporting,
                                        )
                                      : Text(
                                          widget.letters[n],
                                          textScaler: TextScaler.noScaling,
                                          style: AppTextStyles.captionSmall
                                              .copyWith(
                                                color: n == index
                                                    ? primary
                                                    : context.textSupporting,
                                                fontWeight: n == index
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                              ),
                                        ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                    if (_dragging)
                      Positioned(
                        right: AppDimensions.buttonHeight,
                        top: 0,
                        child: IgnorePointer(
                          child: Material(
                            color: primary,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                AppDimensions.spacing,
                              ),
                              child: Text(
                                widget.letters[index],
                                style: AppTextStyles.headlineLarge.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
