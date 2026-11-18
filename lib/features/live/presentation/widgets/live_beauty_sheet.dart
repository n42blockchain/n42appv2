import 'package:flutter/material.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/generated/l10n.dart';

import '../../domain/live_beauty_settings.dart';

class LiveBeautySheet extends StatefulWidget {
  const LiveBeautySheet({
    super.key,
    required this.initial,
    required this.onChanged,
    required this.onCompareChanged,
  });

  final LiveBeautySettings initial;
  final ValueChanged<LiveBeautySettings> onChanged;
  final ValueChanged<bool> onCompareChanged;

  @override
  State<LiveBeautySheet> createState() => _LiveBeautySheetState();
}

class _LiveBeautySheetState extends State<LiveBeautySheet> {
  late LiveBeautySettings _settings = widget.initial;

  void _update(LiveBeautySettings next) {
    setState(() => _settings = next);
    widget.onChanged(next);
  }

  String _filterLabel(S s, LiveFilterPreset filter) => switch (filter) {
    LiveFilterPreset.none => s.g_ui3_live_filter_original,
    LiveFilterPreset.natural => s.g_ui3_live_filter_natural,
    LiveFilterPreset.warm => s.g_ui3_live_filter_warm,
    LiveFilterPreset.cool => s.g_ui3_live_filter_cool,
    LiveFilterPreset.vivid => s.g_ui3_live_filter_vivid,
    LiveFilterPreset.mono => s.g_ui3_live_filter_mono,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(s.g_ui3_live_beauty, style: AppTypography.title),
                const Spacer(),
                TextButton(
                  onPressed: () => _update(const LiveBeautySettings.off()),
                  child: Text(s.g_ui3_live_beauty_reset),
                ),
              ],
            ),
            _BeautySlider(
              label: s.g_ui3_live_smooth,
              value: _settings.smooth,
              onChanged: (value) => _update(_settings.copyWith(smooth: value)),
            ),
            _BeautySlider(
              label: s.g_ui3_live_brighten,
              value: _settings.brightness,
              onChanged: (value) =>
                  _update(_settings.copyWith(brightness: value)),
            ),
            _BeautySlider(
              label: s.g_ui3_live_rosy,
              value: _settings.rosy,
              onChanged: (value) => _update(_settings.copyWith(rosy: value)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 68,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: LiveFilterPreset.values.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final filter = LiveFilterPreset.values[index];
                  final selected = filter == _settings.filter;
                  return Semantics(
                    button: true,
                    selected: selected,
                    label: s.g_ui3_live_filter_named(_filterLabel(s, filter)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _update(
                        _settings.copyWith(
                          filter: filter,
                          filterStrength: filter == LiveFilterPreset.none
                              ? 0
                              : (_settings.filterStrength == 0
                                    ? 0.35
                                    : _settings.filterStrength),
                        ),
                      ),
                      child: Container(
                        width: 62,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceContainer,
                          border: Border.all(
                            color: selected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(_filterLabel(s, filter)),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_settings.filter != LiveFilterPreset.none)
              _BeautySlider(
                label: s.g_ui3_live_filter,
                value: _settings.filterStrength,
                onChanged: (value) =>
                    _update(_settings.copyWith(filterStrength: value)),
              ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: Listener(
                onPointerDown: (_) => widget.onCompareChanged(true),
                onPointerUp: (_) => widget.onCompareChanged(false),
                onPointerCancel: (_) => widget.onCompareChanged(false),
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.compare),
                  label: Text(s.g_ui3_live_hold_compare),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeautySlider extends StatelessWidget {
  const _BeautySlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 44, child: Text(label)),
        Expanded(
          child: Slider(
            value: value,
            onChanged: onChanged,
            semanticFormatterCallback: (value) => '${(value * 100).round()}%',
          ),
        ),
        SizedBox(
          width: 36,
          child: Text('${(value * 100).round()}', textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
